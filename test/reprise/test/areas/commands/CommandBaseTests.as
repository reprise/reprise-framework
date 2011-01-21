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

	import org.flexunit.assertThat;
	import org.flexunit.async.Async;

	import reprise.commands.CommandBase;
	import reprise.commands.CompositeCommand;

	public class CommandBaseTests
	{
		[Before(async, timeout=5000)]
		public function prepareMockolates():void
		{
			Async.proceedOnEvent(this,
					prepare(CompositeCommand),
					Event.COMPLETE);
		}




		////////////////////////       Private / Protected Properties       ////////////////////////


		////////////////////////               Public Methods               ////////////////////////
		[Test] public function changingPriorityNotifiesQueue() : void
		{
			var command : CommandBase = new CommandBase();
			var composite : CompositeCommand = nice(CompositeCommand);
			command.queue = composite;
			command.priority = 10;

			assertThat(composite, received().method('invalidatePriorities'));
		}

		////////////////////////         Private / Protected Methods        ////////////////////////
	}
}