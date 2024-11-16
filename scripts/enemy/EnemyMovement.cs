using System;
using Godot;

namespace SamuraiFrog.scripts;

[GlobalClass]
public partial class EnemyMovement : CharacterBody2D {
	[Export] public Stats _stats { get; private set; }
	[Export] private RayCast2D _leftGroundRay;
	[Export] private RayCast2D _rightGroundRay;
	[Export] private RayCast2D _leftWallRay;
	[Export] private RayCast2D _rightWallRay;
	private Node2D _player;
	private AnimatedSprite2D _animatedSprite2D;

	float dir = 1f;

	private bool _isMoving = true;

	public override void _Ready() {
		_animatedSprite2D = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
		_animatedSprite2D.Play("Run");
	}

	public override void _PhysicsProcess(double delta) {
		Vector2 velocity = new Vector2();
		_animatedSprite2D.FlipH = Velocity.X > 0;
		if (!_leftGroundRay.IsColliding() || _leftWallRay.IsColliding()) {
			dir = 1f;
		}
		if (!_rightGroundRay.IsColliding() || _rightWallRay.IsColliding()) {
			dir = -1f;
		}
		velocity.X = dir * _stats.Speed;
		SetVelocity(velocity);
		MoveAndSlide();
	}

	private void OnEnterArea2D(Node2D node) {
		if (!node.IsInGroup("Player")) return;
		// _enemyAi.StopLoop();
		// _enemyAi.Chase(node.Position);
	}

	private void OnExitArea2D(Node2D node) {
		if (!node.IsInGroup("Player")) return;
		// _enemyAi.StartLoop();
	}
}