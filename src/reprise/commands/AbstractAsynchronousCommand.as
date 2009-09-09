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

	public class AbstractAsynchronousCommand extends AbstractCommand
		implements IAsynchronousCommand
	{
		
		//*****************************************************************************************
		//*                                  Protected Properties                                 *
		//*****************************************************************************************
		/**
		* <code>True</code> if the receiver is executing
		*/
		protected var m_isExecuting : Boolean;
		/**
		* <code>True</code> if the execution of the receiver was cancelled
		*/
		protected var m_isCancelled : Boolean;
		
		
		
		//*****************************************************************************************
		//*                                     Public Methods                                    *
		//*****************************************************************************************
		public function AbstractAsynchronousCommand() {}
		
		
		/**
		* Starts the execution of the receiver. Sets <code>isExecuting</code> to <code>true</code>
		* and resets the <code>isCancelled</code> flag, so that it returns <code>false</code>. If
		* the receiver already started execution, this method does nothing.
		*/
		public override function execute(...args) : void
		{
			if (m_isExecuting)
			{
				return;
			}
			m_isExecuting = true;
			m_isCancelled = false;
		}
		
		/**
		* Returns <code>true</code> if the receiver is being executed.
		*/
		public function isExecuting() : Boolean
		{
			return m_isExecuting;
		}
		
		/**
		* Cancels execution of the command. <code>isExecuting</code> is set to <code>false</code>,
		* <code>isCancelled</code> to <code>true</code>. Afterwards <code>Event.CANCEL</code> is
		* dispatched.
		*/
		public function cancel() : void
		{
			m_isExecuting = false;
			m_isCancelled = true;
			dispatchEvent(new CommandEvent(Event.CANCEL));
		}
		
		/**
		* Returns <code>true</code> if <code>cancel()</code> was called before on the receiver.
		*/
		public function isCancelled() : Boolean
		{
			return m_isCancelled;
		}
		
		/**
		* Sets the receiver to a state, as if it was newly initialized. Thus if it is executing, the 
		* execution will be aborted by calling <code>cancel()</code>. Nevertheless 
		* <code>isCancelled</code> is set to false afterwards, just as <code>isExecuting</code>.
		*/
		public function reset():void
		{
			if (m_isExecuting)
			{
				cancel();
			}
			m_isCancelled = false;
			m_isExecuting = false;
		}
		
		
		
		//*****************************************************************************************
		//*                                   Protected Methods                                   *
		//*****************************************************************************************
		/**
		* Sends out an <code>Event.COMPLETE</code> with the given success value. 
		* <code>isExecuting</code> is set to <code>false</code> and <code>didSucceed</code> to the
		* respective value of the passed argument.
		* 
		* @param success Pass <code>true</code> if the execution was successful
		*/
		protected function notifyComplete(success:Boolean) : void
		{
			m_isExecuting = false;
			m_didSucceed = success;
			dispatchEvent(new CommandEvent(Event.COMPLETE, success));
		}	
	}
}