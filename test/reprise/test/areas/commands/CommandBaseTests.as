/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.test.areas.commands
{
	import org.flexunit.asserts.assertTrue;

	import reprise.commands.CommandBase;
	import reprise.commands.events.CommandEvent;

	public class CommandBaseTests
	{
		//----------------------              Public Properties             ----------------------//


		//----------------------       Private / Protected Properties       ----------------------//


		//----------------------               Public Methods               ----------------------//
		[Test] public function changingPriorityDispatchesPriorityChangeEvent() : void
		{
			var command : CommandBase = new CommandBase();
			var listenerInvoked : Boolean;
			command.addEventListener(CommandEvent.PRIORITY_CHANGE,
					function(event : CommandEvent) : void
					{
						listenerInvoked = true;
					});
			command.priority = 10;

			assertTrue('PRIORITY_CHANGE is dispatched on priority change', listenerInvoked);
		}

		////////////////////////         Private / Protected Methods        ////////////////////////
	}
}