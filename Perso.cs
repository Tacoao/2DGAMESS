using Godot;
using System;
using System.Security.Cryptography;


public partial class Perso : CharacterBody2D
{
	public const float Speed = 2000.0f;
	public const float JumpVelocity = -1850.0f;
	private AnimationTree animationTree;
	private Vector2 HookPosition = new Vector2();
	private Vector2 motion = new Vector2();

	private float RopeLenght  = 500;

	private float CurrentRopeLenght;

	private bool hooked = false;

	public override void _Ready()
	{
		animationTree = GetNode<AnimationTree>("AnimationTree");
		animationTree.Active = true;
		this.CurrentRopeLenght = RopeLenght;
	}
	
	// Get the gravity from the project settings to be synced with RigidBody nodes.
	public float gravity = ProjectSettings.GetSetting("physics/2d/default_gravity").AsSingle();

	public override void _Process(double delta)
	{
	   UpdateAnimationParameters();
	}

    public override void _Draw()
    {
        var pos = GlobalPosition;
    if (hooked)
    {
        DrawLine(new Vector2(0, -16), ToLocal(HookPosition), new Color(0.35f, 0.7f, 0.9f), 3, true);
        // Cyan
    }
    else
    {
        return;
    }

    var colliding = GetNode<RayCast2D>("RayCast").IsColliding();
    var collidePoint = GetNode<RayCast2D>("RayCast").GetCollisionPoint();
    if (colliding)
    {
        var distance = pos.DistanceTo(collidePoint);
        if (distance < RopeLenght)
        {
            // Draw line with white color
            DrawLine(new Vector2(0, -16), ToLocal(collidePoint), new Color(1, 1, 1, 0.25f), 0.5f, true);
        }
    }
    }

    
	
	public void  hook(){
		GetNode<Node2D>("RayCast").LookAt(GetGlobalMousePosition());
		if (Input.IsActionJustPressed("hook"))
		{
			HookPosition = GetHookPosition();
			if (HookPosition != Vector2.Zero)
			{
				this.hooked = true;
				CurrentRopeLenght = GlobalPosition.DistanceTo(HookPosition);
			}
		}
		if (Input.IsActionJustReleased("hook")&&hooked)
		{
			hooked=false;
		}
	}
	public Vector2 GetHookPosition(){
		foreach (RayCast2D rayCast2D in GetNode<Node2D>("RayCast").GetChildren())
		{
			if (rayCast2D.IsColliding())
			{
				return rayCast2D.GetCollisionPoint();
			}
		}
		return Vector2.Zero;
	}
	public void Gravity(){
		this.motion.Y += gravity;
	}

	public void Swing(double delta){
		Vector2 radius = GlobalPosition - HookPosition;
		if (motion.Length()< 0.01 || radius.Length()<10)
		{
			return;
		}
		double angle = Math.Acos(radius.Dot(motion) / (radius.Length() * motion.Length()));
		float rad = (float) Math.Cos(angle) * motion.Length();
		motion += radius.Normalized()* -rad;
		if (GlobalPosition.DistanceTo(HookPosition) > CurrentRopeLenght)
		{
			GlobalPosition = HookPosition +radius.Normalized()*CurrentRopeLenght;
		}
		motion+=(HookPosition-GlobalPosition).Normalized() * 15000 * (float)delta;
	}


    public override void _PhysicsProcess(double delta)
	{
		motion = Velocity;
		Gravity();
		hook();
		if (hooked)
		{
			Gravity();
			Swing(delta);
			motion+=new Vector2(0.975f, 0.975f);
			MoveAndSlide();
		}
		
	
		// Handle Gravity
		if (!IsOnFloor()) {
			motion.Y += gravity * (float)delta;
		}

		// Handle Jump
		if (Input.IsActionJustPressed("Jump_Only") && IsOnFloor()) {
			motion.Y = JumpVelocity;
		animationTree.Set("parameters/conditions/is_jumping", true);
		animationTree.Set("parameters/conditions/is_falling", false);
		animationTree.Set("parameters/conditions/is_onFloor", false);
		animationTree.Set("parameters/conditions/is_idle", false);
		animationTree.Set("parameters/conditions/is_moving", false);

		}

		// Handle Fall
		if (!IsOnFloor() && motion.Y > 0) {
		animationTree.Set("parameters/conditions/is_falling", true);
		animationTree.Set("parameters/conditions/is_jumping", false);
		animationTree.Set("parameters/conditions/is_onFloor", false);
		animationTree.Set("parameters/conditions/is_idle", false);
		animationTree.Set("parameters/conditions/is_moving", false);
		}
	

			float direction = Input.GetAxis("left", "right");
			if (direction != 0)
			{
				motion.X = direction * Speed;
			}
			else
			{
				motion.X = Mathf.MoveToward(Velocity.X, 0, 400);
			}
	
			Velocity = motion;
			MoveAndSlide();
	
			// Flip the sprite based on the direction.
			bool isLeft = direction < 0;
		if (isLeft != GetNode<AnimatedSprite2D>("Sprite2D").FlipH) {
			GetNode<AnimatedSprite2D>("Sprite2D").FlipH = isLeft;
		}	
	}



	public void UpdateAnimationParameters()
{
	    Vector2 velocity = Velocity;
    if (IsOnFloor())
    {
		animationTree.Set("parameters/conditions/is_onFloor", true);
		animationTree.Set("parameters/conditions/is_falling", false);
        if (velocity == Vector2.Zero)
        {
            animationTree.Set("parameters/conditions/is_idle", true);
            animationTree.Set("parameters/conditions/is_moving", false);
        }
        else
        {
            animationTree.Set("parameters/conditions/is_idle", false);
            animationTree.Set("parameters/conditions/is_moving", true);
        }
    }
    else
    {
        animationTree.Set("parameters/conditions/is_idle", false);
        animationTree.Set("parameters/conditions/is_moving", false);
    }

    // Other conditions for jumping, falling, turning, and attacks remain unchanged
    if (Input.IsActionJustPressed("left") || Input.IsActionJustPressed("right"))
    {
        animationTree.Set("parameters/conditions/is_turning", true);
    }
    else
    {
        animationTree.Set("parameters/conditions/is_turning", false);
    }

	if (Input.IsActionJustPressed("Jump_Only"))
	{
		animationTree.Set("parameters/conditions/is_jumping", true);
		animationTree.Set("parameters/conditions/is_onFloor", false);
		animationTree.Set("parameters/conditions/is_idle", false);
		animationTree.Set("parameters/conditions/is_moving", false);
		animationTree.Set("parameters/conditions/is_falling", false);
		animationTree.Set("parameters/conditions/is_turning", false);
		
	}
	else
	{
		animationTree.Set("parameters/conditions/is_jumping", false);
	}
	
}
}

