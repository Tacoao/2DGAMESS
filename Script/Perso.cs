using Godot;
using System;
using System.Numerics;
using System.Runtime.ConstrainedExecution;
using System.Security.Cryptography;


public partial class Perso : CharacterBody2D
{
	//Mouvement Variable
	//Run Variable
	public double maxlife = 100.0;
	public double life = 100.0;

	private float acceleration = 5000.0f; // acceleration du personnage
	private int AttackHCounter = 0;
	private int AttackLCounter = 0;
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
	private Timer damageTimer;
	//Animation Link

	private string idleLink = "parameters/conditions/idle";
	private string runLink = "parameters/conditions/is_moving";
	private string isJump = "parameters/conditions/is_jump";
	private string isLanding = "parameters/conditions/is_landed";
	private string isFalling =  "parameters/conditions/isFalling";

	private string AttackH1 = "parameters/conditions/isAttackH1";
	private string AttackH2 = "parameters/conditions/isAttackH2";
	private string AttackH3 = "parameters/conditions/isAttackH3";
	private string AttackL1 = "parameters/conditions/isAttackL1";
	private string AttackL2 = "parameters/conditions/isAttackL2";
	private string AttackL3 = "parameters/conditions/isAttackL3";

	private string isHit = "parameters/conditions/isHurt";
	public void Takedamage(int damage){
		this.life -= damage;
		ChangeColorToRed();
		damageTimer.Start(0.5f);
	}

	private void ChangeColorToRed()
	{
		animatedSprite2D.Modulate = new Color(1, 0, 0); 
	}

	private void OnDamageTimerTimeout()
	{
		animatedSprite2D.Modulate = new Color(1, 1, 1); 
	}
	
	public void AnimationHandler(){
		
		if (IsOnFloor() && (bool)animationTree.Get(isFalling))
		{
			animationTree.Set(isFalling ,false);
			animationTree.Set(isLanding ,true);
		}
		if (!IsOnFloor())
		{
			animationTree.Set(isFalling ,true);
			animationTree.Set(idleLink, false);
			animationTree.Set(runLink, false);
			animationTree.Set(isLanding ,false);
		}
		if (Velocity == Godot.Vector2.Zero && IsOnFloor())
		{
			animationTree.Set(isHit ,false);
			animationTree.Set(isFalling ,false);
			animationTree.Set(isJump,false);
			animationTree.Set(idleLink, true);
			animationTree.Set(AttackL1,false);
			animationTree.Set(AttackL2,false);
			animationTree.Set(AttackL3,false);
			animationTree.Set(AttackH1,false);
			animationTree.Set(AttackH2,false);
			animationTree.Set(AttackH3,false);
			animationTree.Set(runLink, false);
		}
		else if (IsOnFloor())
		{
			animationTree.Set(isFalling ,false);
			animationTree.Set(isJump,false);
			animationTree.Set(idleLink, false);
			animationTree.Set(AttackL1,false);
			animationTree.Set(AttackL2,false);
			animationTree.Set(AttackL3,false);
			animationTree.Set(AttackH1,false);
			animationTree.Set(AttackH2,false);
			animationTree.Set(AttackH3,false);
			animationTree.Set(runLink, true);

		}
		if (Input.IsActionJustPressed("LeftClick"))
		{
			LightattackHandler();
		}
		if (Input.IsActionJustPressed("RightClick"))
		{
			HeavyattackHandler();
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
		
	}
	private GpuParticles2D gpuparticle ;
	public override void _Ready()
	{
		GD.Print("Script Loaded");
		wallDetect = GetNode<RayCast2D>("wallDetect");
		dashTimer = GetNode<Timer>("dashTimer");
		canDashTimer = GetNode<Timer>("canDashTimer");
		animatedSprite2D = GetNode<AnimatedSprite2D>("Sprite2D");
		animationTree = GetNode<AnimationTree>("AnimationTree");
		gpuparticle = GetNode<GpuParticles2D>("GPUParticles2D");
		gpuparticle.Emitting = false;
		animationTree.Active = true;
		wallDetect.Enabled = true;
		jumpVelocity = ((2.0f * jumpHeight) / jumpTimeToPeak) * -1.0f;
		jumpGravity = ((-2.0f * jumpHeight) / (jumpTimeToPeak * jumpTimeToPeak)) * -1.0f;
		fallGravity = ((-2.0f * jumpHeight) / (jumpTimeToFall * jumpTimeToFall)) * -1.0f;
		motion = Velocity;
		this.CurrentRopeLenght = RopeLenght;
		damageTimer = GetNode<Timer>("DamageTimer");

		// Connectez le signal timeout du Timer à une méthode pour réinitialiser la couleur
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

		



		AnimationHandler();
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

	private void LightattackHandler(){
		if (!bowMod)
		{
				AttackLCounter += 1 ;
				if (AttackLCounter >3)
				{
					AttackLCounter = 1;
				}
				switch (AttackLCounter)
					{
						case 1:
							animationTree.Set(idleLink , false);
							animationTree.Set(runLink,false );
							animationTree.Set(AttackL1,true);
							animationTree.Set(AttackL3,false);
							animationTree.Set(AttackH1,false);
							animationTree.Set(AttackH2,false);
							animationTree.Set(AttackH3,false);
							break;
						case 2:
							animationTree.Set(idleLink , false);
							animationTree.Set(runLink,false );
							animationTree.Set(AttackL2,true);
							animationTree.Set(AttackL1,false);
							animationTree.Set(AttackH1,false);
							animationTree.Set(AttackH2,false);
							animationTree.Set(AttackH3,false);
							break;
						case 3:
							animationTree.Set(idleLink , false);
							animationTree.Set(runLink,false );
							animationTree.Set(AttackL3,true);
							animationTree.Set(AttackL2,false);
							animationTree.Set(AttackH1,false);
							animationTree.Set(AttackH2,false);
							animationTree.Set(AttackH3,false);
							break;
						default:
							break;
					}
		}
	}
	private void HeavyattackHandler(){
		if (!bowMod)
		{
				AttackHCounter += 1 ;
				if (AttackHCounter >3)
				{
					AttackHCounter = 1;
				}
				switch (AttackHCounter)
					{
						case 1:
							animationTree.Set(idleLink , false);
							animationTree.Set(runLink,false );
							animationTree.Set(AttackH1,true);
							animationTree.Set(AttackH3,false);
							animationTree.Set(AttackL1,false);
							animationTree.Set(AttackL2,false);
							animationTree.Set(AttackL3,false);
							break;
						case 2:
							animationTree.Set(idleLink , false);
							animationTree.Set(runLink,false );
							animationTree.Set(AttackH2,true);
							animationTree.Set(AttackH1,false);
							animationTree.Set(AttackL1,false);
							animationTree.Set(AttackL2,false);
							animationTree.Set(AttackL3,false);
							break;
						case 3:
							animationTree.Set(idleLink , false);
							animationTree.Set(runLink,false );
							animationTree.Set(AttackH3,true);
							animationTree.Set(AttackH2,false);
							animationTree.Set(AttackL1,false);
							animationTree.Set(AttackL2,false);
							animationTree.Set(AttackL3,false);
							break;
						default:
							break;
					}
		}
	}
	//Mouvement Handler
	private void HandleMovementInput(double delta)
	{
		StringName left = new StringName("left");
		StringName right = new StringName("right");

		// Get direction from input: -1 for left, 1 for right, 0 for no input
		float direction = Input.GetActionStrength(right) - Input.GetActionStrength(left);

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
				gpuparticle.Emitting = true;
				animatedSprite2D.Visible=false;
				motion.X = direction * DASH_SPEED;

			}
			else
			{
				motion.X = acceleration * direction;
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
		animationTree.Set(runLink,false);
		animationTree.Set(idleLink,false);
		animationTree.Set(isJump,true);
		animationTree.Set(idleLink,true);
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
		if (Input.IsActionJustPressed("RightClick"))
		{
			HookPosition = GetHookPosition();
			if (HookPosition != Godot.Vector2.Zero)
			{
				this.hooked = true;
				CurrentRopeLenght = GlobalPosition.DistanceTo(HookPosition);
			}
		}
		if (Input.IsActionJustReleased("RightClick") && hooked)
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
		gpuparticle.Emitting = false;
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

	
	
}







