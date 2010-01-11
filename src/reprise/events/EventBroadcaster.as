/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.events { 
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * @author Till Schneidereit
	 */
	public class EventBroadcaster extends EventDispatcher
	{
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		protected static var g_instance : EventBroadcaster;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static function instance() : EventBroadcaster
		{
			if ( g_instance == null )
			{
				g_instance = new EventBroadcaster();
			}
			return g_instance;
		}
		
		public function broadcastEvent(event:Event) : void
		{		
			dispatchEvent(event);
		} 
		/***************************************************************************
		*							protected methods							   *
		***************************************************************************/
		public function EventBroadcaster()
		{
		}
	}
}