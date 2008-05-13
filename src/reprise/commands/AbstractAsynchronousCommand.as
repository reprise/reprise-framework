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
	import reprise.events.CommandEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class AbstractAsynchronousCommand extends EventDispatcher
		implements IAsynchronousCommand
	{
		/***************************************************************************
		*							publc properties							   *
		***************************************************************************/
		//TODO: probably rename this to 'id' as it has to be public to use Array.sortOn
		public var m_id : Number;
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_inited : Boolean;
		protected var m_isExecuting : Boolean;
		protected var m_isCancelled : Boolean;
		
		public var m_priority : Number = 0;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function execute(...args) : void
		{
			if (m_isExecuting)
			{
				return;
			}
			m_isExecuting = true;
			m_isCancelled = false;
		}
		
		public function isExecuting() : Boolean
		{
			return m_isExecuting;
		}
		
		public function cancel() : void
		{
			m_isExecuting = false;
			m_isCancelled = true;
			dispatchEvent(new CommandEvent(Event.CANCEL));
		}
		
		public function isCancelled() : Boolean
		{
			return m_isCancelled;
		}
		
		public function setPriority(value : Number) : void
		{
			m_priority = value;
		}
		public function priority() : Number
		{
			return m_priority;
		}
		public function setId(value : Number) : void
		{
			m_id = value;
		}
		public function id() : Number
		{
			return m_id;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function AbstractAsynchronousCommand()
		{
		}
		
		
		protected function notifyComplete(success:Boolean) : void
		{
			m_isExecuting = false;
			dispatchEvent(new CommandEvent(Event.COMPLETE, success));
		}	
	}
}