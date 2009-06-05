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

	import reprise.commands.ICommand;
	import flash.events.EventDispatcher;
	
	public class AbstractCommand extends EventDispatcher 
		implements ICommand
	{
		/***************************************************************************
		*                           Protected properties                           *
		***************************************************************************/
		protected var m_didSucceed : Boolean;
		protected var m_id:int = 0;
		protected var m_priority:int = 0;
		protected var m_queueParent : CompositeCommand;
		
		
		/***************************************************************************
		*                              Public methods                              *
		***************************************************************************/
		public function AbstractCommand() {}
		
		
		public function execute(...rest) : void
		{
			
		}
		
		public function get priority():int
		{
			return m_priority;
		}
		
		public function set priority(value:int):void
		{
			if (value != m_priority)
			{
				m_priority = value;
				if (m_queueParent)
				{
					m_queueParent.invalidatePriorities();
				}
			}
		}
		
		public function get id():int
		{
			return m_id;
		}
		
		public function set id(value:int):void
		{
			m_id = value;
		}
		
		public function didSucceed() : Boolean
		{
			return m_didSucceed;
		}
		
		public function setQueueParent(queue : CompositeCommand) : void
		{
			m_queueParent = queue;
		}
	}
}