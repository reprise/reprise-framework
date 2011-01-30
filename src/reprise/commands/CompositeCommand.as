/*
 * Copyright (c) 2006-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.commands
{
	import flash.events.Event;

	import reprise.events.CommandEvent;

	public class CompositeCommand extends AsyncCommandBase
	{
		////////////////////////       Private / Protected Properties       ////////////////////////
		/**
		 * The number of commands which should be executed concurrently
		 */
		protected var _maxParallelExecutionCount : uint = 1;
		/**
		 * flag that signifies a change in command priorities. If set, the queue has to be re-sorted
		 * before the next command is executed
		 */
		protected var _prioritiesInvalid : Boolean;
		/**
		 * Holds the commands in the queue
		 */
		protected var _pendingCommands : Vector.<ICommand> = new <ICommand>[];
		/**
		 * Holds the AsyncCommands which are currently being executed
		 */
		protected var _currentCommands : Vector.<IAsyncCommand> = new <IAsyncCommand>[];
		/**
		 * Indicates whether the CompositeCommand should abort if any of the queued commands
		 * returns with an error
		 */
		protected var _abortOnFailure : Boolean = true;
		/**
		 * An internal counter used to have a reliable sorting
		 */
		protected var _nextResourceId : uint;
		/**
		 * The number of commands which failed execution
		 */
		protected var _failedCommandsCount : uint;
		/**
		 * The number of commands which were executed in total
		 */
		protected var _completedCommandsCount : int;


		////////////////////////               Public Methods               ////////////////////////
		public function CompositeCommand()
		{
			reset();
		}

		public function invalidatePriorities() : void
		{
			_prioritiesInvalid = true;
		}


		/**
		 * Executes the command, which in return runs all queued commands it contains
		 */
		public override function execute() : void
		{
			if (_isExecuting)
			{
				return;
			}
			super.execute();
			executeNext();
		}

		/**
		 * Adds a command to the queue. You can add commands if CompositeCommand is already running
		 * without problems. If the CompositeCommand has been run before and finished execution
		 * it will be automatically reset, thus <code>didSucceed()</code> will return true.
		 *
		 * @param command The command to be added
		 */
		public function addCommand(command : ICommand) : void
		{
			// we automatically reset everything for a new run
			if (!_isExecuting && !_pendingCommands.length)
			{
				reset();
			}

			command.id = _nextResourceId++;
			command.queue = this;
			_pendingCommands.push(command);

			// If the queue was previously empty, we might need to execute the new command
			// immediately
			if (_isExecuting && _pendingCommands.length == 1)
			{
				executeNext();
			}
		}

		/**
		 * Removes a command from the queue. If the command is not contained in the queue, this
		 * method does nothing.
		 *
		 * @param command The command to be removed
		 */
		public function removeCommand(command : ICommand) : void
		{
			var commandIndex : Number = _currentCommands.indexOf(command);
			if (commandIndex == -1)
			{
				return;
			}
			_pendingCommands.splice(commandIndex, 1);
		}

		/**
		 * Returns whether the <code>CompositeCommand</code> should abort the execution after
		 * any of the contained commands was executed with an error.
		 */
		public function get abortOnFailure() : Boolean
		{
			return _abortOnFailure;
		}

		/**
		 * Sets whether the <code>CompositeCommand</code> should abort the execution after
		 * any of the contained commands was executed with an error.
		 *
		 * @param value The flag whether the <code>CompositeCommand</code> should abort on a failure
		 * or not
		 */
		public function set abortOnFailure(value : Boolean) : void
		{
			_abortOnFailure = value;
		}

		/**
		 * Specifies how many commands should be executed concurrently. If <code>value</code> is
		 * set to <code>0</code> then all commands will be executed in one run.
		 *
		 * @param value The number of commands to be run concurrently. Set to <code>0</code> if you
		 * want all commands to be executed in one run.
		 */
		public function setMaxParallelExecutionCount(value : uint) : void
		{
			_maxParallelExecutionCount = value;
			if (_isExecuting)
			{
				// make sure that the queue is filled up appropriately
				executeNext();
			}
		}

		/**
		 * Returns the sum of commands which are currently being executed or waiting in the queue.
		 */
		public function length() : uint
		{
			if (!_pendingCommands)
			{
				return 0;
			}
			return _pendingCommands.length + _currentCommands.length;
		}

		/**
		 * Calls <code>cancel()</code> on all commands which are currently running and
		 * calls the super-implementation of <code>cancel()</code> afterwards.
		 *
		 * @see AsyncCommandBase#cancel
		 */
		public override function cancel() : void
		{
			cancelCurrentCommands();
			super.cancel();
		}

		/**
		 * Returns the number of commands executed in total. This number is increased not until
		 * a command completely finished its execution.
		 */
		public function get completedCommandsCount() : int
		{
			return _completedCommandsCount;
		}

		/**
		 * Returns the number of commands which failed execution
		 */
		public function get failedCommandsCount() : int
		{
			return _failedCommandsCount;
		}

		/**
		 * @inheritDoc
		 */
		override public function reset() : void
		{
			_success = true;
			_nextResourceId = 0;
			_pendingCommands.length = 0;
			_currentCommands.length = 0;
			_completedCommandsCount = 0;
			_failedCommandsCount = 0;
			super.reset();
		}


		////////////////////////         Private / Protected Methods        ////////////////////////
		/**
		 * This method is the working horse of the composite command. It sorts the command based
		 * on their priority and executes them respecting the given settings.
		 */
		protected function executeNext() : void
		{
			if (_pendingCommands.length===0)
			{
				if (_currentCommands.length===0)
				{
					notifyComplete(_success);
				}
				return;
			}

			// we execute as much commands as defined by _maxParallelExecutionCount
			// if _maxParallelExecutionCount equals 0, we execute all commands at once
			if (_currentCommands.length >= _maxParallelExecutionCount &&
					_maxParallelExecutionCount > 0)
			{
				return;
			}

			// executeNext should not be called after the CompositeCommand is canceled, but it
			// still might if one of the contained commands' cancel-method is buggy, so we guard
			// for that here
			if (_isCancelled)
			{
				return;
			}

			if (_prioritiesInvalid)
			{
				//TODO: implement priority-sorting
				_prioritiesInvalid = false;
			}

			var currentCommand : ICommand = _pendingCommands.shift();

			if (currentCommand is IAsyncCommand)
			{
				if (IAsyncCommand(currentCommand).isCancelled)
				{
					executeNext();
					return;
				}
				addListenersForAsyncCommand(IAsyncCommand(currentCommand));
				_currentCommands.push(currentCommand);
				currentCommand.execute();
			}
			else
			{
				currentCommand.execute();
				_completedCommandsCount++;
				if (!currentCommand.success)
				{
					_failedCommandsCount++;
					_success = false;
					if (_abortOnFailure)
					{
						cancelCurrentCommands();
						notifyComplete(false);
						return;
					}
				}
			}
			executeNext();
		}

		/**
		 * Adds listeners for the <code>COMPLETE</code> and <code>CANCEL</code> events of a
		 * given command
		 *
		 * @param command The command to which the listeners should be attached to
		 */
		protected function addListenersForAsyncCommand(command : IAsyncCommand) : void
		{
			command.addEventListener(Event.COMPLETE, command_complete);
			command.addEventListener(Event.CANCEL, command_cancel);
		}

		/**
		 * Removes listeners for the <code>COMPLETE</code> and <code>CANCEL</code> events of
		 * a given command
		 *
		 * @param command The command from which the listeners should be removed
		 */
		protected function removeListenersForAsyncCommand(command : IAsyncCommand) : void
		{
			command.removeEventListener(Event.COMPLETE, command_complete);
			command.removeEventListener(Event.CANCEL, command_cancel);
		}

		/**
		 * Removes listeners from all commands which are currently being executed asynchronously
		 * and calls <code>cancel()</code> on them
		 */
		protected function cancelCurrentCommands() : void
		{
			for (var i : int = _currentCommands.length; i--;)
			{
				var command : IAsyncCommand = _currentCommands[i];
				removeListenersForAsyncCommand(command);
				command.cancel();
			}
		}


		////////////////////////                Event Handlers              ////////////////////////
		/**
		 * If the command dispatching the event executed with a failure and
		 * <code>abortOnFailure()</code> is set to <code>true</code>, the
		 * <code>CompositeCommand</code> stops
		 *
		 * @param event The received event
		 */
		protected function command_complete(event : CommandEvent) : void
		{
			var completedCommand : IAsyncCommand = IAsyncCommand(event.target);
			removeListenersForAsyncCommand(completedCommand);
			_currentCommands.splice(_currentCommands.indexOf(completedCommand), 1);
			_completedCommandsCount++;
			if (!completedCommand.success)
			{
				_success = false;
				_failedCommandsCount++;
				if (_abortOnFailure)
				{
					cancelCurrentCommands();
					notifyComplete(false);
					return;
				}
			}
			executeNext();
		}

		/**
		 * Called by a <code>CANCEL</code> event of an executed asynchronous command. The command is
		 * handled the same way as if it was completed successfully and is essentially just skipped.
		 *
		 * @param event The received event
		 */
		protected function command_cancel(event : CommandEvent) : void
		{
			// since execution is counted after a command completed its execution, cancelled
			// commands don't fall into this category. To reduce code duplication, we reuse
			// the handling of completed commands, but reduce their count beforehand to keep it
			// correct in the end.
			_completedCommandsCount--;

			command_complete(event);
		}
	}
}