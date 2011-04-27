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
	import asmock.framework.SetupResult;
	import asmock.framework.StubOptions;
	import asmock.integration.flexunit.IncludeMocksRule;

	import org.hamcrest.assertThat;
	import org.hamcrest.object.hasPropertyWithValue;

	import reprise.commands.CompositeCommand;
	import reprise.commands.IAsyncCommand;
	import reprise.commands.ICommand;
	import reprise.commands.events.CommandEvent;

	public class CompositeCommandTests
	{
		//----------------------              Public Properties             ----------------------//
		[Rule] public var includeMocks : IncludeMocksRule = new IncludeMocksRule(
				[ICommand, IAsyncCommand]);


		//----------------------       Private / Protected Properties       ----------------------//
		private var _mockRepository : MockRepository;


		//----------------------               Public Methods               ----------------------//
		[Before]
		public function beforeTest() : void
		{
			_mockRepository = new MockRepository();
		}

		[Test]
		public function emptyCompositeCommandHasLength0() : void
		{
			var composite : CompositeCommand = new CompositeCommand();
			assertThat(composite, hasPropertyWithValue('length', 0));
		}

		[Test(expects='Error')]
		public function addingSameCommandTwiceThrowsError() : void
		{
			var command : ICommand = ICommand(_mockRepository.createStub(ICommand));

			var composite : CompositeCommand = new CompositeCommand();
			composite.addCommand(command);
			composite.addCommand(command);
		}

		[Test(expects='Error')]
		public function removingCommandNotContainedThrowsError() : void
		{
			var command : ICommand = ICommand(_mockRepository.createStub(ICommand));

			var composite : CompositeCommand = new CompositeCommand();
			composite.removeCommand(command);
		}

		[Test]
		public function addingCommandsIncreasesCompositeCommandLength() : void
		{
			var composite : CompositeCommand = new CompositeCommand();

			composite.addCommand(ICommand(_mockRepository.createStub(ICommand)));
			assertThat(composite, hasPropertyWithValue('length', 1));
			composite.addCommand(ICommand(_mockRepository.createStub(ICommand)));
			assertThat(composite, hasPropertyWithValue('length', 2));
		}

		[Test]
		public function executingCompositeCommandExecutesContainedCommandsInOrder() : void
		{
			var command1 : ICommand = ICommand(_mockRepository.createStub(ICommand));
			var command2 : ICommand = ICommand(_mockRepository.createStub(ICommand));
			SetupResult.forCall(command1.success).returnValue(true);

			_mockRepository.ordered(function() : void
			{
				Expect.call(command1.execute());
				Expect.call(command2.execute());
			});
			_mockRepository.replayAll();

			var composite : CompositeCommand = new CompositeCommand();
			composite.addCommand(command1);
			composite.addCommand(command2);
			composite.execute();

			_mockRepository.verifyAll();
		}

		[Test]
		public function
				executingCompositeCommandExecutesContainedCommandsInPrioritizedOrder() : void
		{
			var command1 : ICommand = ICommand(_mockRepository.createStub(ICommand));
			var command2 : ICommand = ICommand(_mockRepository.createStub(ICommand, StubOptions.EVENTS));
			SetupResult.forCall(command2.priority = 10).dispatchEvent(
					new CommandEvent(CommandEvent.PRIORITY_CHANGE));
			SetupResult.forCall(command2.priority).returnValue(10);
			SetupResult.forCall(command1.success).returnValue(true);
			SetupResult.forCall(command2.success).returnValue(true);

			_mockRepository.ordered(function() : void
			{
				Expect.call(command2.execute()).message('command2 should be executed first');
				Expect.call(command1.execute()).message('command1 should be executed last');
			});
			_mockRepository.replayAll();

			var composite : CompositeCommand = new CompositeCommand();
			composite.addCommand(command1);
			composite.addCommand(command2);
			composite.execute();

			_mockRepository.verifyAll();
//			var command1 : ICommand = ICommand(_mockRepository.createStub(ICommand));
//			var command2 : ICommand = ICommand(_mockRepository.createStub(ICommand));
//			SetupResult.forCall(command1.success).returnValue(true);
//			SetupResult.forCall(command2.success).returnValue(true);
//			SetupResult.forCall(command2.priority).returnValue(10);
//
//			_mockRepository.ordered(function() : void
//			{
//				Expect.call(command1.execute());
//				Expect.call(command2.execute());
//			});
//			_mockRepository.replayAll();
//
//			var composite : CompositeCommand = new CompositeCommand();
//			composite.addCommand(command1);
//			composite.addCommand(command2);
//			composite.execute();
//
//			_mockRepository.verifyAll();
		}

		[Test]
		public function
				executingCompositeCommandWithSuccessfulContainedCommandSetsSuccessToTrue() : void
		{
			var command : ICommand = ICommand(_mockRepository.createStub(ICommand));
			SetupResult.forCall(command.success).returnValue(true);
			_mockRepository.replayAll();

			var composite : CompositeCommand = new CompositeCommand();
			composite.addCommand(command);
			composite.execute();

			assertThat(composite, hasPropertyWithValue('success', true));
		}

		[Test]
		public function
				executingCompositeCommandWithFailingContainedCommandSetsSuccessToFalse() : void
		{
			var command : ICommand = ICommand(_mockRepository.createStub(ICommand));
			SetupResult.forCall(command.success).returnValue(false);
			_mockRepository.replayAll();

			var composite : CompositeCommand = new CompositeCommand();
			composite.addCommand(command);
			composite.execute();

			assertThat(composite, hasPropertyWithValue('success', false));
		}

		[Test]
		public function compositeCommandAbortsOnFailingCommand() : void
		{
			var command1 : ICommand = ICommand(_mockRepository.createStub(ICommand));
			var command2 : ICommand = ICommand(_mockRepository.createStub(ICommand));
			SetupResult.forCall(command1.success).returnValue(false);

			_mockRepository.ordered(function() : void
			{
				Expect.call(command1.execute());
				Expect.notCalled(command2.execute());
			});
			_mockRepository.replayAll();

			var composite : CompositeCommand = new CompositeCommand();
			composite.addCommand(command1);
			composite.addCommand(command2);
			composite.execute();

			_mockRepository.verifyAll();
		}

		[Test]
		public function compositeCommandDoesntAbortOnFailingCommandIfAbortOnFailureIsFalse() : void
		{
			var command1 : ICommand = ICommand(_mockRepository.createStub(ICommand));
			var command2 : ICommand = ICommand(_mockRepository.createStub(ICommand));
			SetupResult.forCall(command1.success).returnValue(false);

			_mockRepository.ordered(function() : void
			{
				Expect.call(command1.execute());
				Expect.call(command2.execute());
			});
			_mockRepository.replayAll();

			var composite : CompositeCommand = new CompositeCommand();
			composite.abortOnFailure = false;
			composite.addCommand(command1);
			composite.addCommand(command2);
			composite.execute();

			_mockRepository.verifyAll();
		}

		//----------------------         Private / Protected Methods        ----------------------//
	}
}