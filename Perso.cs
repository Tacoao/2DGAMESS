using Godot;
using System;

public partial class Perso : CharacterBody2D
{
	public const float Speed = 500.0f;
	public const float JumpVelocity = -2000.0f;
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
 
		// Animations
		
 
		// Add the gravity.
		if (!IsOnFloor()) {
			velocity.Y += gravity * (float)delta;
	
		}
 
		// Handle Jump.
		if (Input.IsActionJustPressed("jump") && IsOnFloor())
			velocity.Y = JumpVelocity;
 
		// Get the input direction and handle the movement/deceleration.
		// As good practice, you should replace UI actions with custom gameplay actions.
		float direction = Input.GetAxis("left", "right");
		if (direction != 0)
		{
			velocity.X = direction * Speed;
		}
		else
		{
			velocity.X = Mathf.MoveToward(Velocity.X, 0, 12);
		}
 
		Velocity = velocity;
		MoveAndSlide();
 
		// Flip the sprite based on the direction.
		bool isLeft = direction < 0;
	if (isLeft != GetNode<AnimatedSprite2D>("Sprite2D").FlipH) {
		GetNode<AnimatedSprite2D>("Sprite2D").FlipH = isLeft;
	}
		//animationTree.FlipH = isLeft;
	}



	public void UpdateAnimationParameters()
{
	Vector2 velocity = Velocity;
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

	if (Input.IsActionJustPressed("left"))
	{
		animationTree.Set("parameters/conditions/is_turning", true);
	}
	else
	{
		animationTree.Set("parameters/conditions/is_turning", false);
	}
	if (Input.IsActionJustPressed("punch"))
	{
		animationTree.Set("parameters/conditions/attack1",true);
	}
	else
	{
		animationTree.Set("parameters/conditions/attack1",false);
	}
	if (Input.IsActionJustPressed("jump"))
	{
		animationTree.Set("parameters/conditions/is_jumping",true);
	}
	else
	{
		animationTree.Set("parameters/conditions/is_jumping",false);
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

