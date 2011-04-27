/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.test.areas.commands
{
	import asmock.framework.Expect;
	import asmock.framework.MockRepository;
	import asmock.integration.flexunit.IncludeMocksRule;

	import flash.events.Event;

	import org.hamcrest.assertThat;
	import org.hamcrest.object.hasPropertyWithValue;
	import org.hamcrest.object.notNullValue;

	import reprise.commands.AsyncCommandBase;
	import reprise.commands.CompositeCommand;
	import reprise.commands.events.CommandEvent;

	public class AsyncCommandBaseTests
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