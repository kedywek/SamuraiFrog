using Godot;

namespace SamuraiFrog.scripts;

public partial class EnemyMovement : CharacterBody2D
{
	[Export] private float _speed;
	[Export] private float _stoppingDistance;
	private Node2D _player;
	private Vector2 _targetVelocity = Vector2.Zero;
	private Vector2 _basePosition;

	public override void _Ready()
	{
		_player =  GetTree().GetNodesInGroup("Player")[0] as Node2D;
		_basePosition = Position;
	}

	public override void _PhysicsProcess(double delta)
	{
		GD.Print(Position.DistanceTo(_player.Position));
		if (Position.DistanceTo(_player.Position) >= _stoppingDistance) {
			_targetVelocity.X = GetDirection(_player.Position).X * _speed;
		}
		else {
			_targetVelocity.X = 0f;
		}
		Velocity = _targetVelocity;
		MoveAndSlide();
	}

	private void OnEnterArea2D(Node2D node) {
	}

	private void OnExitArea2D(Node2D node) {
	}

	private Vector2 GetDirection(Vector2 target) {
		Vector2 dir = Position.DirectionTo(target).Normalized();
		return dir;
	}
}