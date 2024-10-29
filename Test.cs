using Godot;
using System;

public partial class Test : Node
{
	private Health health;
	[Export] private int maxHealth;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		health = new Health(maxHealth);
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if (Input.IsActionPressed("Attack"))
		{
			GD.Print(health.GetHealth());
			health.TakeDamage(1);
   		}
	}
}
