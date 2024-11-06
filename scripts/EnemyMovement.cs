using Godot;

namespace SamuraiFrog.scripts;

public partial class EnemyMovement : CharacterBody2D
{
	[Export] private float _speed;
	[Export] private float _stoppingDistance;
	private Node2D _player;
	private Vector2 _targetPosition;
	private Vector2 _targetVelocity = Vector2.Zero;
	private Vector2 _basePosition;

	public override void _Ready()
	{
		_player =  GetTree().GetNodesInGroup("Player")[0] as Node2D;
		_basePosition = Position;
	}

	public override void _PhysicsProcess(double delta) {
		_targetVelocity.X = GetDirection(_targetPosition).X;
		Velocity = _targetVelocity * _speed;
		MoveAndSlide();
		if (Position.DistanceTo(_targetPosition) <= _stoppingDistance) {
			_targetVelocity = Vector2.Zero;
		}
	}

	private void OnEnterArea2D(Node2D node) {
		if(!node.IsInGroup("Player")) return;
		GD.Print("Player entered");
		_targetPosition = _player.Position;
	}

	private void OnExitArea2D(Node2D node) {
		if(!node.IsInGroup("Player")) return;
		GD.Print("Player exited");
		_targetPosition = _basePosition;
	}

	private Vector2 GetDirection(Vector2 target) {
		Vector2 dir = Position.DirectionTo(target);
		return dir;
	}
}