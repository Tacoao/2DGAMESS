using Godot;
using System;
using System.Numerics;
using System.Security.Cryptography;


public partial class Perso : CharacterBody2D
{
	//Mouvement Variable
	//Run Variable
	private float acceleration = 5000.0f; // acceleration du personnage
	private Boolean dashing = false;
	private Boolean canDash = true;//peut dash 
	private const float DASH_SPEED = 10000.0f;// vitesse du dash
	private Timer dashTimer;//temp du dash
	private Timer canDashTimer;//temp avant prochain dash
							   //Jump Variable
	private float jumpHeight = 700.0f; //Hauteur du saut
	private float jumpTimeToPeak = 0.3f;//Temp t avant hauteur max du saut atteinte ici jumpHeight
	private float jumpTimeToFall = 0.2f;//Temp t avant de descendre
	private float jumpVelocity = 0.0f;//Vitesse du saut
	private float jumpForce = 1.2f;//Force du saut
	private float jumpGravity = 0.0f;//Gravité appliqué aux saut
	private float fallGravity = 0.0f;//gravité de chute
	private float maxfallGravity = 10000.0f;//Gravité max lors de la chute
	private int jumpBufferCounter = 15;//Permet de rendre les saut plus fluide
	private int jumpBufferTime = 15;
	private int jumpCounter = 0;
	private int cayotteTime = 15;//	Temp d'erreur 
	private int cayotteCounter = 0;//nombre d'erreur 
	private bool bowMod = false;

	private AnimationTree animationTree; //abimation Tree

	private AnimatedSprite2D animatedSprite2D;//Texture du personnage

	private RayCast2D wallDetect;//detecteur de wall

	private Godot.Vector2 HookPosition = new Godot.Vector2();
	private Godot.Vector2 motion = new Godot.Vector2();

	private float RopeLenght = 500;

	private float CurrentRopeLenght;
	private Node2D rope;
	public bool hooked = false;

	private float previousDirection = 0.0f;

	//Animation Link

	private string idleLink = "parameters/conditions/idle";
	private string runLink = "parameters/conditions/is_moving";
	private string isTurningLink = "parameters/conditions/is_turning";
	public override void _Ready()
	{
		GD.Print("Script Loaded");
		wallDetect = GetNode<RayCast2D>("wallDetect");
		dashTimer = GetNode<Timer>("dashTimer");
		canDashTimer = GetNode<Timer>("canDashTimer");
		animatedSprite2D = GetNode<AnimatedSprite2D>("Sprite2D");
		animationTree = GetNode<AnimationTree>("AnimationTree");
		animationTree.Active = true;
		wallDetect.Enabled = true;
		jumpVelocity = ((2.0f * jumpHeight) / jumpTimeToPeak) * -1.0f;
		jumpGravity = ((-2.0f * jumpHeight) / (jumpTimeToPeak * jumpTimeToPeak)) * -1.0f;
		fallGravity = ((-2.0f * jumpHeight) / (jumpTimeToFall * jumpTimeToFall)) * -1.0f;
		motion = Velocity;
		this.CurrentRopeLenght = RopeLenght;
	}

	public override void _Process(double delta)
	{
		UpdateAnimationParameters();
	}


	public override void _PhysicsProcess(double delta)
	{
		//Application de la bonne Gravité
		motion.Y += getGravity() * (float)delta;
		//Logique si contact avec le mur
		if (wallDetect.IsColliding())
		{
			var collider = wallDetect.GetCollider();
			if (collider is Node colliderNode)
			{
				if (colliderNode.Name == "TileMap")
				{
					maxfallGravity = 1000;
				}
			}
		}
		else
		{
			maxfallGravity = 5000;
		}
		if (motion.Y > maxfallGravity)
		{
			motion.Y = maxfallGravity;
		}
		if (IsOnFloor())
		{
			cayotteCounter = cayotteTime;
			jumpCounter = 0;
		}
		if (!IsOnFloor())
		{
			if (cayotteCounter > cayotteTime)
			{
				cayotteCounter -= 1;
			}
			if (jumpBufferCounter > 0)
			{
				if (wallDetect.IsColliding())
				{
					var collider = wallDetect.GetCollider();
					if (collider is Node colliderNode)
					{
						if (colliderNode.Name == "TileMap")
						{
							cayotteCounter = 1;
							if (animatedSprite2D.FlipH)
							{
								GD.Print("push");
								motion.X += 5000;
							}
							else
							{
								motion.X -= 5000;
							}
						}
					}
				}
				else if (jumpCounter < 1)
				{
					cayotteCounter = 1;
					jumpCounter += 1;
				}

			}
		}

		if (Input.IsActionJustPressed("Jump_Only"))
		{
			jumpBufferCounter = jumpBufferTime;
		}
		if (jumpBufferCounter > 0)
		{
			jumpBufferCounter -= 1;
		}
		if (jumpBufferCounter > 0 && cayotteCounter > 0)
		{
			jumpBufferCounter = 0;
			cayotteCounter = 0;
			Jump();
		}




		HandleMovementInput(delta);

		//Crochet Systeme
		if (BowMod())
		{
			hook();
			QueueRedraw();
			if (hooked)
			{
				Swing(delta);
				motion += new Godot.Vector2(0.975f, 0.975f);
			}
		}

		Velocity = motion;

		MoveAndSlide();
	}

	//Mouvement Handler
	private void HandleMovementInput(double delta)
	{
		StringName left = new StringName("left");
		StringName right = new StringName("right");

		// Get direction from input: -1 for left, 1 for right, 0 for no input
		float direction = Input.GetActionStrength(right) - Input.GetActionStrength(left);
		if (Mathf.Sign(direction) != Mathf.Sign(previousDirection) && direction != 0)
		{
			// La direction a changé, déclenchez l'animation "turn around"
			animationTree.Set(isTurningLink, true);
		}
		else
		{
			// La direction n'a pas changé, désactivez l'animation "turn around"
			animationTree.Set(isTurningLink, false);
		}

		// Mettez à jour la direction précédente
		previousDirection = direction;
		// Use Mathf.Sign to handle direction more robustly
		if (Mathf.Abs(direction) > 0)
		{
			if (Input.IsActionJustPressed("dash") && canDash == true)
			{
				dashing = true;
				canDash = false;
				dashTimer.Start();
				canDashTimer.Start();

			}
			animatedSprite2D.FlipH = direction < 0;
			if (dashing)
			{
				//dashParticle.Emitting = true;
				//animatedSprite2D.Visible=false;
				motion.X = direction * DASH_SPEED;

			}
			else
			{

				motion.X = acceleration * direction;
				float temp = direction;
				if (temp != direction)
				{
					animationTree.Set(isTurningLink, true);
				}
				else
				{
					animationTree.Set(isTurningLink, false);
				}


			}

			wallDetect.RotationDegrees = direction > 0 ? 0.0f : 180.0f;
		}
		else
		{
			// Smoothly decelerate to a stop using linear interpolation
			motion.X = Mathf.Lerp(motion.X, 0, 0.2f);
		}

	}
	//Fonction de  Saut
	public void Jump()
	{
		motion.Y = jumpVelocity * jumpForce;
	}

	//Gravity Handler
	public float getGravity()
	{
		if (motion.Y < 0)
		{
			return jumpGravity;
		}
		else
		{
			return fallGravity;

		}
	}



	public bool GetHooked()
	{
		return hooked;
	}


	//Crochet
	public void hook()
	{
		GetNode<Node2D>("RayCast/RayCast2D").LookAt(GetGlobalMousePosition());
		if (Input.IsActionJustPressed("hook"))
		{
			HookPosition = GetHookPosition();
			if (HookPosition != Godot.Vector2.Zero)
			{
				this.hooked = true;
				CurrentRopeLenght = GlobalPosition.DistanceTo(HookPosition);
			}
		}
		if (Input.IsActionJustReleased("hook") && hooked)
		{
			hooked = false;

		}
	}


	//Récupere la position du Crochet
	public Godot.Vector2 GetHookPosition()
	{
		foreach (RayCast2D rayCast2D in GetNode<Node2D>("RayCast").GetChildren())
		{
			if (rayCast2D.IsColliding())
			{
				return rayCast2D.GetCollisionPoint();
			}
		}
		return Godot.Vector2.Zero;
	}


	//Fonction Balancement
	public void Swing(double delta)
	{
		Godot.Vector2 radius = GlobalPosition - HookPosition;
		if (motion.Length() < 0.01 || radius.Length() < 10)
		{
			return;
		}
		double angle = Math.Acos(radius.Dot(motion) / (radius.Length() * motion.Length()));
		float rad = (float)Math.Cos(angle) * motion.Length();
		motion += radius.Normalized() * -rad;
		if (GlobalPosition.DistanceTo(HookPosition) > CurrentRopeLenght)
		{
			GlobalPosition = HookPosition + radius.Normalized() * CurrentRopeLenght;
		}
		motion += (HookPosition - GlobalPosition).Normalized() * 15000 * (float)delta;
	}

	private void _on_dash_timer_timeout()
	{
		dashing = false;
		//dashParticle.Emitting = false;
		animatedSprite2D.Visible = true;
	}

	private void _on_can_dash_timer_timeout()
	{
		canDash = true;
	}

	private Boolean BowMod()
	{
		if (Input.IsActionJustPressed("bowMod") && bowMod == false)
		{
			return bowMod = true;
		}
		else if (Input.IsActionJustPressed("bowMod") && bowMod == true)
		{
			return bowMod = false;
		}
		return bowMod;
	}

	public void UpdateAnimationParameters()
	{
		if (Velocity == Godot.Vector2.Zero)
		{
			animationTree.Set(idleLink, true);
			animationTree.Set(runLink, false);

		}
		else
		{
			animationTree.Set(idleLink, false);
			animationTree.Set(runLink, true);

		}

	}
}







