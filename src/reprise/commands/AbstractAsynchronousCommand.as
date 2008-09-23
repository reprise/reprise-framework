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
	
	import reprise.events.CommandEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class AbstractAsynchronousCommand extends AbstractCommand
		implements IAsynchronousCommand
	{
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_isExecuting : Boolean;
		protected var m_isCancelled : Boolean;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public override function execute(...args) : void
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
		
		public function reset():void
		{
			m_isCancelled = false;
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
			m_didSucceed = success;
			dispatchEvent(new CommandEvent(Event.COMPLETE, success));
		}	
	}
}