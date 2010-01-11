/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

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