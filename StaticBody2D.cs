using Godot;
using System;

public partial class StaticBody2D : Godot.StaticBody2D
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		StaticBody2D stat = GetNode<StaticBody2D>("StaticBody2D");
		CollisionPolygon2D col = new CollisionPolygon2D();
		col.Polygon = GetNode<Polygon2D>("Polygon2D").Polygon;
		stat.AddChild(col);
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
} 
