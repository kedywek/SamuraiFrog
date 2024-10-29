using Godot;
using System;

public partial class Health{
	private int maxHealth;
	private int health;
	public Health(int maxHealth){
		this.maxHealth = maxHealth;
		health = maxHealth;
	}
	
	public int GetHealth(){
		return health;
	}
	
	public float GetHealthNormalized(){
		return health/maxHealth;
	}
	
	public void TakeDamage(int hitPoints){
		if(health <= 0) return;
		health -= hitPoints;
	}
	
}
