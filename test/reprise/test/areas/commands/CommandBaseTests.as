/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.test.areas.commands
{
	import asmock.framework.MockRepository;
	import asmock.integration.flexunit.IncludeMocksRule;

	import org.flexunit.asserts.assertTrue;

	import reprise.commands.CommandBase;
	import reprise.commands.CompositeCommand;
	import reprise.commands.events.CommandEvent;

	public class CommandBaseTests
	{
		//----------------------              Public Properties             ----------------------//
		[Rule] public var includeMocks : IncludeMocksRule = new IncludeMocksRule(
				[CompositeCommand]);


		////////////////////////       Private / Protected Properties       ////////////////////////
		private var _mockRepository : MockRepository;


		//----------------------               Public Methods               ----------------------//
		[Before]
		public function beforeTest() : void
		{
			_mockRepository = new MockRepository();
		}

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