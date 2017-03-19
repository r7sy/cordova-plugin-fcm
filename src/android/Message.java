package com.gae.scaffolder.plugin;
import java.util.Date;
public class Message {
	private String id;
	private String title;
	private String body;
	private String senderId;
	
	private String thumbnail;
	private String senderName;
	private Date arrivalTime;
	public Message(String id , String title , String body , String senderId,String senderName,String thumbnail,String arrivalTime)
	{ 
	this.id=id;
	this.title=title;
	this.body=body;
	this.senderId=senderId;
	this.senderName =senderName;
	this.thumbnail = thumbnail;
	if(arrivalTime==null)
	{
		this.arrivalTime=new Date();
		
	} else {
		this.arrivalTime=new Date(Long.parseLong(arrivalTime));
		
	}
	
	}
	
	public String getId(){return this.id;}
	public String getTitle(){return this.title;}
	public String getBody(){return this.body;}
	public String getSenderId(){return this.senderId;}
	public Long getArrivalTime(){return this.arrivalTime.getTime();}
	public String getSenderName(){return this.senderName;};

	public String getThumbnail(){return this.thumbnail;}
	
}
