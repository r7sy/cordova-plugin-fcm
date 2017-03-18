package com.gae.scaffolder.plugin;
public class Sender {
	private String id;
	private String sound ;
	public Sender(String id , String sound)
	{
		this.id=id;
		this.sound=sound;
		
	}
	
	public String getId(){return this.id;}
	public String getSound(){return this.sound;}
	public void setSound(String s){this.sound=s;}
	
	
}
