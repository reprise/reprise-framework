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

package reprise.commands
{	
	import flash.events.IEventDispatcher; 
	
	public interface ICommand extends IEventDispatcher
	{
		function execute(...rest) : void;
		function get priority():int;
		function set priority(value:int):void;
		function get id():int;
		function set id(value:int):void;
		function didSucceed():Boolean;
		function setQueueParent(queue : CompositeCommand) : void;
	}
}