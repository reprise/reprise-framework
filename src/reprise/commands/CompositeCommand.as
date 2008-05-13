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

package reprise.commands { 
	import reprise.data.collection.IndexedArray;
	import reprise.events.CommandEvent;
	
	import flash.events.Event;
	
	public class CompositeCommand
		extends AbstractAsynchronousCommand
	{
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_id : Number = 0;
		
		//TODO: check if this should be uint
		protected   var m_maxParallelExecutionCount : Number = 1; //default value
		protected	var m_pendingCommands : IndexedArray;
		protected	var m_finishedCommands : IndexedArray;
		protected	var m_currentCommands : IndexedArray;
		protected	var m_isExecutingAsynchronously	: Boolean = false;
		protected	var m_abortOnFailure:Boolean = true;
		protected var m_failedCommands:Array;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CompositeCommand()
		{
			m_id = g_id++;
			clear();
		}
		
		public override function execute(...args):void
		{
			if (m_isExecuting)
			{
				return;
			}
			super.execute();
			m_isExecutingAsynchronously = containsAsynchronousCommands();
			executeNext();
		}
		
		public function addCommand(cmd:ICommand):void
		{
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
		
	//	public function commandWithIndex(n:Number):ICommand
	//	{
	//		return ICommand(m_commands[n]);
	//	}
		
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
			if (m_pendingCommands.length == 0)
			{
				if (m_isExecutingAsynchronously && m_currentCommands.length == 0)
				{
					notifyComplete(m_failedCommands.length == 0);
				}
				return;
			}
			
			while ((m_currentCommands.length < m_maxParallelExecutionCount || 
				!m_maxParallelExecutionCount) && m_pendingCommands.length)
			{
				var currentCommand : ICommand = ICommand(m_pendingCommands.shift());
				if (currentCommand is IAsynchronousCommand)
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
		
		protected function containsAsynchronousCommands():Boolean
		{
			var i:Number = m_pendingCommands.length;
			while (i--)
			{
				if (m_pendingCommands[i] is IAsynchronousCommand)
				{
					return true;
				}
			}
			i = m_finishedCommands.length;
			while (i--)
			{
				if (m_finishedCommands[i] is IAsynchronousCommand)
				{
					return true;
				}
			}
			return false;
		}
	}
}