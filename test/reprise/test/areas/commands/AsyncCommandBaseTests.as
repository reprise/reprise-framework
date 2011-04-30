/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.test.areas.commands
{
	import flash.events.Event;

	import org.hamcrest.assertThat;
	import org.hamcrest.object.hasPropertyWithValue;
	import org.hamcrest.object.notNullValue;

	import reprise.commands.AsyncCommandBase;
	import reprise.commands.events.CommandEvent;

	public class AsyncCommandBaseTests
	{
		//----------------------              Public Properties             ----------------------//


		//----------------------       Private / Protected Properties       ----------------------//


		//----------------------               Public Methods               ----------------------//
		[Test]
		public function executeDispatchesComplete() : void
		{
			var command : AsyncCommandBase = new AsyncCommandBase();
			var receivedEvent : CommandEvent;
			command.addEventListener(Event.COMPLETE, function(event : CommandEvent) : void
			{
				receivedEvent = event;
			});
			command.execute();
			assertThat(command, notNullValue());
		}

		[Test]
		public function cancelSetsIsCancelledFlag() : void
		{
			var command : AsyncCommandBase = new AsyncCommandBase();
			command.cancel();
			assertThat(command, hasPropertyWithValue('isCancelled', true));
		}

		
		//----------------------         Private / Protected Methods        ----------------------//
	}
}