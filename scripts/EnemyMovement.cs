using Godot;
using System;
using System.Collections.Generic;
using System.Diagnostics;

public partial class EnemyMovement : CharacterBody2D
{
	[Export] 
	private float _speed = 10f;
	private Node2D _player;
	public override void _Ready()
	{
		_player =  GetTree().GetNodesInGroup("Player")[0] as Node2D;
	}

	public override void _PhysicsProcess(double delta)
	{
		Vector2 directionTo = Position.DirectionTo(_player.Position).Normalized();
		Velocity = directionTo * _speed;
		MoveAndSlide();
	}
}
