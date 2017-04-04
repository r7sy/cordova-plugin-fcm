package com.gae.scaffolder.plugin;
import java.util.Date;
public class Message {
	private String id;
	private String title;
	private String body;
	private String senderId;
	
	private String thumbnail_url;
	
	private String thumbnail_hash;
	private String senderName;
	private Date arrivalTime;
	public Message(String id , String title , String body , String senderId,String senderName,String thumbnail_url,String tumbnail_hash,String arrivalTime)
	{ 
	this.id=id;
	this.title=title;
	this.body=body;
	this.senderId=senderId;
	this.senderName =senderName;
	this.thumbnail_url = thumbnail_url;
	
	this.thumbnail_hash = thumbnail_hash;
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

	public String getThumbnailHash(){return this.thumbnail_hash;}
	public String getThumbnailUrl(){return this.thumbnail_url;}
	
}
