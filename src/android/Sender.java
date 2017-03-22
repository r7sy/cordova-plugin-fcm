package com.gae.scaffolder.plugin;
public class Sender {
	private String id;
	private String sound ;
	private boolean muted ;
	private boolean vibrate;
	public Sender(String id , String sound,boolean muted,boolean vibrate)
	{
		this.id=id;
		this.sound=sound;
		this.muted =muted;
		this.vibrate=vibrate;
	}
	
	public String getId(){return this.id;}
	public String getSound(){return this.sound;}
	public void setSound(String s){this.sound=s;}
	public boolean getMuted(){return this.muted;}
	public void setMuted (boolean muted){this.muted = muted;}
	
	public boolean getVibrate(){return this.vibrate;}
	public void setVibrate (boolean vibrate){this.vibrate = vibrate;}
}
