/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.commands 
{
	import flash.events.Event;
	
	import reprise.data.collection.IndexedArray;
	import reprise.events.CommandEvent;
	import reprise.external.IResource;
	import reprise.external.ImageResource;


	public class CompositeCommand extends AbstractAsynchronousCommand
	{
		
		//*****************************************************************************************
		//*                                  Protected Properties                                 *
		//*****************************************************************************************
		/**
		* The number of commands which should be executed concurrently.
		*/
		protected var m_maxParallelExecutionCount : int = 1;
		/**
		* flag that signifies a change in command priorities. If set, the queue has to be re-sorted 
		* before the next command is executed.
		*/
		protected var m_prioritiesInvalid : Boolean;
		/**
		* Holds the commands in the queue.
		*/
		protected var m_pendingCommands : IndexedArray;
		/**
		* Holds the commands, which are currently being executed.
		*/
		protected var m_currentCommands : IndexedArray;
		/**
		* Is true, if there are or were any asynchronous commands in the queue. If so an event
		* is dispatched after completion.
		*/
		protected var m_isExecutingAsynchronously : Boolean;
		/**
		* Indicates whether the CompositeCommand should abort if any of the queued commands
		* returns with an error.
		*/
		protected var m_abortOnFailure : Boolean = true;
		/**
		* An internal counter used to have a reliable sorting.
		*/
		protected var m_nextResourceId : int;
		/**
		* The number of commands which failed execution
		*/
		protected var m_numCommandsFailed : int;
		/**
		* The number of commands which were executed in total
		*/
		protected var m_numCommandsExecuted : int;

		
		//*****************************************************************************************
		//*                                     Public Methods                                    *
		//*****************************************************************************************
		public function CompositeCommand() 
		{
			reset();
		}
		
		public function invalidatePriorities() : void
		{
			m_prioritiesInvalid = true;
		}

		
		/**
		* Executes the command, which in return runs all queued commands it contains.
		*/
		public override function execute(...args):void
		{
			if (m_isExecuting)
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
		* @param cmd The command to be added
		*/
		public function addCommand(cmd:ICommand):void
		{
			// we automatically reset everything for a new run
			if (!m_isExecuting && !m_pendingCommands.length)
			{
				reset();
			}

			m_isExecutingAsynchronously ||= commandExecutesAsynchronously(cmd);
			cmd.id = m_nextResourceId++;
			cmd.setQueueParent(this);
			m_pendingCommands.push(cmd);
			
			if (m_isExecuting)
			{
				executeNext();
			}
		}
		
		/**
		* Removes a command from the queue. If the command is not contained in the queue, this 
		* method does nothing.
		* 
		* @param cmd The command to be removed
		*/
		public function removeCommand(cmd:ICommand):void
		{
			if (m_currentCommands.objectExists(cmd))
			{
				return;
			}
			m_pendingCommands.remove(cmd);
		}
		
		/**
		* Returns whether the <code>CompositeCommand</code> should abort the execution after 
		* any of the contained commands was executed with an error.
		*/
		public function abortOnFailure():Boolean
		{
			return m_abortOnFailure;
		}
		
		/**
		* Sets whether the <code>CompositeCommand</code> should abort the execution after 
		* any of the contained commands was executed with an error.
		* 
		* @param val The flag whether the <code>CompositeCommand</code> should abort on a failure
		* or not
		*/
		public function setAbortOnFailure(val:Boolean):void
		{
			m_abortOnFailure = val;
		}
		
		/**
		* Specifies how many commands should be executed concurrently. If <code>value</code> is 
		* set to <code>0</code> then all commands will be executed in one run.
		* 
		* @param value The number of commands to be run concurrently. Set to <code>0</code> if you
		* want all commands to be executed in one run.
		*/
		public function setMaxParallelExecutionCount(value : int) : void
		{
			m_maxParallelExecutionCount = value;
			if (m_isExecuting)
			{
				// make sure that the queue is filled up appropriately
				executeNext();
			}
		}
		
		/**
		* Returns the sum of commands which are currently being executed or waiting in the queue.
		*/
		public function length():uint
		{
			if (!m_pendingCommands)
			{
				return 0;
			}
			return m_pendingCommands.length + m_currentCommands.length;
		}
		
		/**
		* Calls <code>cancel()</code> on all commands which are currently running and 
		* calls the super-implementation of <code>cancel()</code> afterwards.
		* 
		* @see AbstractAsynchronousCommand#cancel
		*/
		public override function cancel() : void
		{
			failGracefully(true);
		}
		
		/**
		* Returns <code>true</code> if any of the contained commands is an instance of 
		* AsynchronousCommand.
		*/
		public function executesAsynchronously() : Boolean
		{
			return m_isExecutingAsynchronously;
		}
		
		/**
		* Returns the number of commands executed in total. This number is increased not until 
		* a command completely finished its execution.
		*/
		public function numExecutedCommands():int
		{
			return m_numCommandsExecuted;
		}
		
		/**
		* Returns the number of commands which failed execution.
		*/
		public function numFailedCommands():int
		{
			return m_numCommandsFailed;
		}

		/**
		* @inheritDoc
		*/
		override public function reset():void
		{
			m_pendingCommands = new IndexedArray();
			m_currentCommands = new IndexedArray();
			m_isExecutingAsynchronously = false;
			m_didSucceed = true;
			m_nextResourceId = 0;
			m_numCommandsExecuted = 0;
			m_numCommandsFailed = 0;
			super.reset();
		}
		
		
		
		//*****************************************************************************************
		//*                                   Protected Methods                                   *
		//*****************************************************************************************
		/**
		* This method is the working horse of the composite command. It sorts the command based 
		* on their priority and executes them respecting the given settings.
		*/
		protected function executeNext() : void
		{
			if (m_pendingCommands.length == 0 && m_currentCommands.length == 0)
			{
				m_isExecuting = false;
				// we only dispatch a event if we're executing asynchronously
				if (m_isExecutingAsynchronously)
				{
					notifyComplete(m_didSucceed);
				}
				return;
			}
			
			// we execute as much commands as defined by m_maxParallelExecutionCount
			// if m_maxParallelExecutionCount equals 0, we execute all commands at once
			if ((m_currentCommands.length >= m_maxParallelExecutionCount && m_maxParallelExecutionCount > 0) ||
				!m_pendingCommands.length || m_isCancelled)
			{
				return;
			}
			if (m_prioritiesInvalid)
			{
				m_pendingCommands.sortOn(['priority', 'id'], 
					[Array.NUMERIC | Array.DESCENDING, Array.NUMERIC]);
				m_prioritiesInvalid = false;
			}
			var currentCommand : ICommand = ICommand(m_pendingCommands.shift());

			if (currentCommand is IAsynchronousCommand && IAsynchronousCommand(currentCommand).isCancelled())
			{
				executeNext();
				return;
			}
			
			if (commandExecutesAsynchronously(currentCommand))
			{
				registerListenersForAsynchronousCommand(IAsynchronousCommand(currentCommand));
				m_currentCommands.push(currentCommand);
				currentCommand.execute();
			}
			else
			{
				currentCommand.execute();
				m_numCommandsExecuted++;
				if (!currentCommand.didSucceed())
				{
					m_numCommandsFailed++;
					m_didSucceed = false;
					if (m_abortOnFailure)
					{
						failGracefully(false);
						return;
					}
				}
			}
			executeNext();
		}
		
		/**
		* Registers listeners for the <code>COMPLETE</code> and <code>CANCEL</code> events of a 
		* given command.
		* 
		* @param cmd The command to which the listeners should be attached to
		*/
		protected function registerListenersForAsynchronousCommand(
			cmd:IAsynchronousCommand):void
		{
			cmd.addEventListener(Event.COMPLETE, command_complete);
			cmd.addEventListener(Event.CANCEL, command_cancel);
		}
		
		/**
		* Unregisters listeners for the <code>COMPLETE</code> and <code>CANCEL</code> events of 
		* a given command.
		* 
		* @param cmd The command from which the listeners should be removed
		*/
		protected function unregisterListenersForAsynchronousCommand(
			cmd:IAsynchronousCommand):void
		{
			cmd.removeEventListener(Event.COMPLETE, command_complete);
			cmd.removeEventListener(Event.CANCEL, command_cancel);
		}
		
		/**
		* Unregisters listeners from all commands which are currently being executed asynchronously
		* and calls <code>cancel()</code> on them. Afterwards <code>didSucceed</code> is set to 
		* false and either <code>notifyComplete</code> called with the negative result or the
		* super-implementation of <code>cancel()</code>.
		* 
		* @param userInterrupt Specifies if either the command fails because <code>cancel()</code>
		* was called (<code>true</code>) or any of the executed commands failed (<code>false</code>).
		*/
		protected function failGracefully(userInterrupt:Boolean):void
		{
			var i : int = m_currentCommands.length;
			while (i--)
			{
				var cmd:ICommand = ICommand(m_currentCommands[i]);
				if (commandExecutesAsynchronously(cmd))
				{
					unregisterListenersForAsynchronousCommand(IAsynchronousCommand(cmd));
					IAsynchronousCommand(cmd).cancel();
				}
			}
			userInterrupt ? super.cancel() : notifyComplete(m_didSucceed);
		}
		
		/**
		* Checks if a given command should be executed asynchronously. Returns <code>true</code> 
		* if the command is either an <code>AsynchronousCommand</code> and/or has a property or 
		* a method <code>executesAsynchronously</code> which returns <code>true</code>.
		* 
		* @param cmd The command which should be examined
		* @param ...rest varargs to enable the use of this function in one of the built-in 
		* <code>Array</code> methods
		*/
		protected function commandExecutesAsynchronously(cmd:ICommand, ...rest) : Boolean
		{
			var executesAsynchronously : Boolean = cmd is IAsynchronousCommand;
			if ((cmd as Object).hasOwnProperty('executesAsynchronously'))
			{
				executesAsynchronously = 
					cmd['executesAsynchronously'] is Function 
					? cmd['executesAsynchronously']()
					: cmd['executesAsynchronously'];
			}
			return executesAsynchronously;
		}
		
		
		
		//*****************************************************************************************
		//*                                     Event Handling                                    *
		//*****************************************************************************************
		/**
		* Called by a <code>COMPLETE</code> event of an executed asynchronous command. The command 
		* will be removed from the queue. If the command executed with a failure and 
		* <code>abortOnFailure()</code> is set to <code>true</code>, the <code>CompositeCommand</code>
		* stops.
		* 
		* @param e The received event
		*/
		protected function command_complete(e:CommandEvent):void
		{
			var completedCommand:IAsynchronousCommand = 
				IAsynchronousCommand(e.target);
			unregisterListenersForAsynchronousCommand(completedCommand);
			m_currentCommands.remove(e.target);
			m_numCommandsExecuted++;
			if (!completedCommand.didSucceed())
			{
				m_didSucceed = false;
				m_numCommandsFailed++;
				if (m_abortOnFailure)
				{
					failGracefully(false);
					return;
				}
			}
			executeNext();
		}
		
		/**
		* Called by a <code>CANCEL</code> event of an executed asynchronous command. The command is 
		* handled the same way as if it was completed successfully and is essentially just skipped.
		* 
		* @param e The received event
		*/
		protected function command_cancel(event : CommandEvent) : void
		{
			// cancel makes no difference to us to a unsuccessful command
			var completeEvent:Event = new ((event as Object).constructor)(Event.COMPLETE, true);
			IAsynchronousCommand(event.target).dispatchEvent(completeEvent);
			// since execution is counted after a command completed its execution, cancelled
			// commands don't fall into this category
			m_numCommandsExecuted--;
		}
	}
}