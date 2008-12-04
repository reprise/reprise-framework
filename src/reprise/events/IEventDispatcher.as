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
	
	public interface IEventDispatcher
	{
		function addEventListener(type:String, listener:Function, useCapture:Boolean = false, 
			priority:int = 0, useWeakReference:Boolean = false):void;
		function dispatchEvent(event:Event):Boolean;
		function hasEventListener(type:String):Boolean;
		function removeEventListener(type:String, listener:Function, 
			useCapture:Boolean = false):void;
		function willTrigger(type:String):Boolean;
	}
}
