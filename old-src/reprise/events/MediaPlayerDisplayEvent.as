/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.events
{ 
	import flash.events.Event;
	
	/**
	 * @author till
	 */
	public class MediaPlayerDisplayEvent extends Event
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const PLAY_CLICK : String = "playClickEvent";
		public static const PAUSE_CLICK : String = "pauseClickEvent";
		public static const STOP_CLICK : String = "stopClickEvent";
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function MediaPlayerDisplayEvent(type : String, bubbles : Boolean = false)
		{
			super(type, bubbles);
		}
	}
}