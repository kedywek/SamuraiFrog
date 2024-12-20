using Godot;

namespace SamuraiFrog.scripts;

public partial class Stats : Resource
{
	[Export]
	public float Speed { get; set; }
	[Export]
	public float ChaseFactor { get; set; }
	[Export]
	public float StoppingDistance { get; set; }

	public Stats() : this(0, 0, 0) {}

	public Stats(float speed, float chaseFactor, float stoppingDistance)
	{
		Speed = speed;
		ChaseFactor = chaseFactor;
		StoppingDistance = stoppingDistance;
	}
}
