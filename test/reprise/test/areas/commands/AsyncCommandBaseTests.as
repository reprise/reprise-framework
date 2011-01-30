/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.test.areas.commands
{
	import flash.events.Event;

	import mockolate.nice;
	import mockolate.prepare;
	import mockolate.received;

	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.hasPropertyWithValue;
	import org.hamcrest.object.notNullValue;

	import reprise.commands.AsyncCommandBase;
	import reprise.commands.CompositeCommand;
	import reprise.events.CommandEvent;

	public class AsyncCommandBaseTests
	{
		//----------------------       Private / Protected Properties       ----------------------//


		//----------------------               Public Methods               ----------------------//
		[Before(async, timeout=5000)]
		public function prepareMockolates():void
		{
			Async.proceedOnEvent(this,
					prepare(CompositeCommand),
					Event.COMPLETE);
		}

		[Test] public function changingPriorityNotifiesQueue() : void
		{
			var command : AsyncCommandBase = new AsyncCommandBase();
			var composite : CompositeCommand = nice(CompositeCommand);
			command.queue = composite;
			command.priority = 10;

			assertThat(composite, received().method('invalidatePriorities'));
		}

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