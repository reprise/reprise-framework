/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.commands 
{
	import reprise.commands.AbstractAsynchronousCommand;
	import flash.events.EventDispatcher;
	import flash.events.Event;	

	/**
	 * @author marc
	 */
	public class ListenerCommand extends AbstractAsynchronousCommand 
	{
		
		private var m_eventName:String;
		private var m_scope:EventDispatcher;
		
		
		public function ListenerCommand(scope:EventDispatcher, eventName:String)
		{
			super();
			m_scope = scope;
			m_eventName = eventName;
		}
		
		public override function execute(...args):void
		{
			m_scope.addEventListener(m_eventName, event_complete);
		}
		
		private function event_complete(e:Event):void
		{
			notifyComplete(true);
		}
	}
}
