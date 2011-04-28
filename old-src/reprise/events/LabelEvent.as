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
	 * @author Till
	 */
	public class LabelEvent extends Event
	{
		//----------------------             Public Properties              ----------------------//
		public static const LINK_CLICK : String = "linkClick";
		
		public var href : String;
		public var linkTarget : String;
		//----------------------       Private / Protected Properties       ----------------------//
		
		
		//----------------------               Public Methods               ----------------------//
		public function LabelEvent(type : String, 
			bubbles : Boolean = false, cancelable : Boolean = true)
		{
			super(type, bubbles, cancelable);
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		
	}
}