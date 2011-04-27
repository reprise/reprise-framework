/*
 * Copyright (c) 2006-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

/**
 * Waits for the specified event to be dispatched by the specified EventDispatcher before completing
 *
 * Can be used to stall <code>CompositeCommand</code>s until some condition is met
 */
package reprise.commands
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class WaitForEventCommand extends AsyncCommandBase
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _eventName : String;
		private var _dispatcher : EventDispatcher;


		//----------------------               Public Methods               ----------------------//
		public function WaitForEventCommand(dispatcher : EventDispatcher, eventName : String)
		{
			super();
			_dispatcher = dispatcher;
			_eventName = eventName;
		}

		public override function execute() : void
		{
			_dispatcher.addEventListener(_eventName, dispatcher_event);
		}

		
		//----------------------         Private / Protected Methods        ----------------------//
		private function dispatcher_event(event : Event) : void
		{
			_dispatcher.removeEventListener(_eventName, dispatcher_event);
			notifyComplete(true);
		}
	}
}
