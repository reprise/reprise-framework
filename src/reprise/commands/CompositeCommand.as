////////////////////////////////////////////////////////////////////////////////
//
//  Fork unstable media GmbH
//  Copyright 2006-2008 Fork unstable media GmbH
//  All Rights Reserved.
//
//  NOTICE: Fork unstable media permits you to use, modify, and distribute this
//  file in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package reprise.commands 
{
	import flash.events.Event;
	
	import reprise.data.collection.IndexedArray;
	import reprise.events.CommandEvent;

	
	public class CompositeCommand extends AbstractAsynchronousCommand
	{
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_maxParallelExecutionCount : int = 1;
		protected var m_pendingCommands : IndexedArray;
		protected var m_finishedCommands : IndexedArray;
		protected var m_currentCommands : IndexedArray;
		protected var m_isExecutingAsynchronously : Boolean = false;
		protected var m_abortOnFailure : Boolean = true;
		protected var m_failureOccured : Boolean = false;
		protected var m_failedCommands : Array;
		protected var m_nextResourceId : int = 0;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CompositeCommand()
		{
			clear();
		}
		
		public override function execute(...args):void
		{
			if (m_isExecuting)
			{
				return;
			}
			super.execute();
			m_isExecutingAsynchronously = executesAsynchronously();
			executeNext();
		}
		
		public function addCommand(cmd:ICommand):void
		{
			cmd.id = m_nextResourceId++;
			m_pendingCommands.push(cmd);
			if (m_isExecuting)
			{
				executeNext();
			}
		}
		
		public function removeCommand(cmd:ICommand):void
		{
			if (m_currentCommands.objectExists(cmd))
			{
				return;
			}
			m_pendingCommands.remove(cmd);
		}
		
		public function abortOnFailure():Boolean
		{
			return m_abortOnFailure;
		}
	
		public function setAbortOnFailure(val:Boolean):void
		{
			m_abortOnFailure = val;
		}
		
		public function setMaxParallelExecutionCount(value : Number) : void
		{
			m_maxParallelExecutionCount = value;
			if (m_isExecuting)
			{
				refillExecutionSlots();
			}
		}
		
		public function clear():void
		{
			m_pendingCommands = new IndexedArray();
			m_finishedCommands = new IndexedArray();
			m_currentCommands = new IndexedArray();
			m_failedCommands = [];
		}
		
		public function length():uint
		{
			return m_pendingCommands.length + m_finishedCommands.length + m_currentCommands.length;
		}
		
		public override function cancel() : void
		{
			var i : Number = m_currentCommands.length;
			while (i--)
			{
				if (m_currentCommands[i] is IAsynchronousCommand)
				{
				var currentCommand : IAsynchronousCommand = 
					IAsynchronousCommand(m_currentCommands[i]);
				unregisterListenersForAsynchronousCommand(currentCommand);
				currentCommand.cancel();
				}
			}
			super.cancel();
		}
		
		public function executesAsynchronously() : Boolean
		{
			return m_pendingCommands.some(commandExecutesAsynchronously) ||
				m_finishedCommands.some(commandExecutesAsynchronously);
		}
		
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function command_complete(e:CommandEvent):void
		{
			var completedCommand:IAsynchronousCommand = 
				IAsynchronousCommand(e.target);
			unregisterListenersForAsynchronousCommand(completedCommand);
			
			if (!e.success)
			{
				if (m_abortOnFailure)
				{
					notifyComplete(false);
					return;
				}
				m_failedCommands.push(e.target);
			}
			m_currentCommands.remove(e.target);
			m_finishedCommands.push(e.target);
			executeNext();
		}
		
		protected function command_cancel(event : CommandEvent) : void
		{
			// cancel makes no difference to us to a unsuccessful command
			var completeEvent : CommandEvent = new CommandEvent(Event.COMPLETE, false);
			command_complete(completeEvent);
		}
		
		protected function refillExecutionSlots() : void
		{
			while (m_currentCommands.length < m_maxParallelExecutionCount)
			{
				executeNext();
			}
		}
		
		protected function executeNext() : void
		{
			m_pendingCommands.sortOn(['priority', 'id'], 
				[Array.NUMERIC | Array.DESCENDING, Array.NUMERIC]);
			
			if (m_pendingCommands.length == 0)
			{
				if (m_isExecutingAsynchronously && m_currentCommands.length == 0 && 
					!m_failureOccured)
				{
					notifyComplete(m_failedCommands.length == 0);
				}
				else
				{
					m_didSucceed = m_failedCommands.length == 0;
					m_isExecuting = false;
				}
				return;
			}
			
			while ((m_currentCommands.length < m_maxParallelExecutionCount || 
				!m_maxParallelExecutionCount) && m_pendingCommands.length)
			{
				var currentCommand : ICommand = ICommand(m_pendingCommands.shift());
				
				if (commandExecutesAsynchronously(currentCommand))
				{
					if (IAsynchronousCommand(currentCommand).isCancelled())
					{
						m_finishedCommands.push(currentCommand);
						executeNext();
						return;
					}
					registerListenersForAsynchronousCommand(
						IAsynchronousCommand(currentCommand));			
					m_currentCommands.push(currentCommand);
					currentCommand.execute();
				}
				else
				{
					currentCommand.execute();
					if (!currentCommand.didSucceed())
					{
						if (m_abortOnFailure)
						{
							m_failureOccured = true;
							notifyComplete(false);
							return;
						}
						m_failedCommands.push(currentCommand);
					}
					m_finishedCommands.push(currentCommand);
					executeNext();
				}
			}
		}
		
		protected function registerListenersForAsynchronousCommand(
			cmd:IAsynchronousCommand):void
		{
			cmd.addEventListener(Event.COMPLETE, command_complete);
			cmd.addEventListener(Event.CANCEL, command_cancel);
		}
		
		protected function unregisterListenersForAsynchronousCommand(
			cmd:IAsynchronousCommand):void
		{
			cmd.removeEventListener(Event.COMPLETE, command_complete);
			cmd.removeEventListener(Event.CANCEL, command_cancel);
		}
		
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
	}
}