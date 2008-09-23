////////////////////////////////////////////////////////////////////////////////
//
//  Fork unstable media GmbH
//  Copyright 2006-2008 Fork unstable media GmbH
//  All Rights Reserved.
//
//  NOTICE: Fork unstable media permits you to use, modify, and distribute this
//  file in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package reprise.events 
{
	import flash.events.Event;
	
	public class StateChangeEvent extends Event
	{
		public static const STATE_WILL_CHANGE:String = 'StateWillChangeEvent';
		public static const STATE_DID_CHANGE:String = 'StateDidChangeEvent';
		
		public var oldState:*;
		public var newState:*;
		
		public function StateChangeEvent(type:String, theOldState:*, theNewState:*)
		{
			super(type);
			oldState = theOldState;
			newState = theNewState;
		}
	}
}