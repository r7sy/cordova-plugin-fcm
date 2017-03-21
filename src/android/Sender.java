package com.gae.scaffolder.plugin;
public class Sender {
	private String id;
	private String sound ;
	private boolean muted ;
	public Sender(String id , String sound,boolean muted)
	{
		this.id=id;
		this.sound=sound;
		this.muted =muted;
	}
	
	public String getId(){return this.id;}
	public String getSound(){return this.sound;}
	public void setSound(String s){this.sound=s;}
	public boolean getMuted(return this.muted;)
	public void setMuted (boolean muted){this.muted = muted;}
	
}
