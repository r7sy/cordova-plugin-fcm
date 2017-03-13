package com.gae.scaffolder.plugin;
import java.util.Date;
public class Message {
	private String id;
	private String title;
	private String body;
	private String senderId;
	private Date arrivalTime;
	public Message(String id , String title , String body , String senderId,String arrivalTime)
	{ 
	this.id=id;
	this.body=body;
	this.senderId=senderId;
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
	
	
	
}
