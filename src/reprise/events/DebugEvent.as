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
	public class DebugEvent extends Event 
	{
		/***************************************************************************
		*                           public properties	                           *
		***************************************************************************/
		public static const WILL_RESET_STYLES : String = 'willResetStyles';
		public static const DID_RESET_STYLES : String = 'didResetStyles';
		
		public function DebugEvent(
			type : String, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
