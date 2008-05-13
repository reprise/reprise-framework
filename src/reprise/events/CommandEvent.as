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

package reprise.events { 
	import reprise.commands.ICommand;	
	
	import flash.events.Event;
	
	public class CommandEvent extends Event
	{
		public static const COMPLETE : String = 'completeCommandEvent';
		public var success : Boolean;
			
		public function CommandEvent(type:String, didSucceed:Boolean = false)
		{
			super(type);
			success = didSucceed;
		}
	}
}