using Godot;
using System;

public partial class Perso : CharacterBody2D
{
	public const float Speed = 2000.0f;
	public const float JumpVelocity = -1850.0f;
		private AnimationTree animationTree;


	public override void _Ready()
	{
		animationTree = GetNode<AnimationTree>("AnimationTree");
		animationTree.Active = true;
	}
	
	// Get the gravity from the project settings to be synced with RigidBody nodes.
	public float gravity = ProjectSettings.GetSetting("physics/2d/default_gravity").AsSingle();

	public override void _Process(double delta)
	{
	   UpdateAnimationParameters();
	}
	public override void _PhysicsProcess(double delta)
	{
		Vector2 velocity = Velocity;
 
    // Handle Gravity
    if (!IsOnFloor()) {
        velocity.Y += gravity * (float)delta;
    }

    // Handle Jump
    if (Input.IsActionJustPressed("Jump_Only") && IsOnFloor()) {
        velocity.Y = JumpVelocity;
    animationTree.Set("parameters/conditions/is_jumping", true);
    animationTree.Set("parameters/conditions/is_falling", false);
    animationTree.Set("parameters/conditions/is_onFloor", false);
    animationTree.Set("parameters/conditions/is_idle", false);
    animationTree.Set("parameters/conditions/is_moving", false);

    }

    // Handle Fall
    if (!IsOnFloor() && velocity.Y > 0) {
    animationTree.Set("parameters/conditions/is_falling", true);
    animationTree.Set("parameters/conditions/is_jumping", false);
    animationTree.Set("parameters/conditions/is_onFloor", false);
    animationTree.Set("parameters/conditions/is_idle", false);
    animationTree.Set("parameters/conditions/is_moving", false);
    }
 

		float direction = Input.GetAxis("left", "right");
		if (direction != 0)
		{
			velocity.X = direction * Speed;
		}
		else
		{
			velocity.X = Mathf.MoveToward(Velocity.X, 0, 400);
		}
 
		Velocity = velocity;
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
	if (Input.IsActionJustPressed("punch"))
	{
		animationTree.Set("parameters/conditions/attack1",true);
	}
	else
	{
		animationTree.Set("parameters/conditions/attack1",false);
	}
	
	if (Input.IsActionJustPressed("punch2"))
		{
			animationTree.Set("parameters/conditions/attack2",true);
		}else
		{
			animationTree.Set("parameters/conditions/attack2",false);
		}
		if (velocity.Y>0)
		{
			animationTree.Set("parameters/conditions/is_falling",true);
			animationTree.Set("parameters/conditions/is_onFloor",false);
		}
		else
		{
			animationTree.Set("parameters/conditions/is_falling",false);
			animationTree.Set("parameters/conditions/is_onFloor",true);
		}
}
}

