/*
 * Copyright (c) 2006-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.commands
{
	import reprise.commands.events.CommandEvent;

	public class AsyncCommandBase extends CommandBase implements IAsyncCommand
	{
		////////////////////////       Private / Protected Properties       ////////////////////////
		/**
		 * <code>True</code> if the command is executing
		 */
		protected var _isExecuting : Boolean;
		/**
		 * <code>True</code> if the command's execution was cancelled
		 */
		protected var _isCancelled : Boolean;


		////////////////////////               Public Methods               ////////////////////////
		public function AsyncCommandBase()
		{
		}


		/**
		 * Starts the execution of the receiver. Sets <code>isExecuting</code> to <code>true</code>
		 * and resets the <code>isCancelled</code> flag, so that it returns <code>false</code>. If
		 * the receiver already started execution, this method does nothing.
		 */
		public override function execute() : void
		{
			if (_isExecuting)
			{
				return;
			}
			_isExecuting = true;
			_isCancelled = false;
		}

		/**
		 * Returns <code>true</code> if the receiver is being executed.
		 */
		public function get isExecuting() : Boolean
		{
			return _isExecuting;
		}

		/**
		 * Cancels execution of the command. <code>isExecuting</code> is set to <code>false</code>,
		 * <code>isCancelled</code> to <code>true</code>. Afterwards
		 * <code>CommandCancelEvent.CANCEL</code> is dispatched.
		 */
		public function cancel() : void
		{
			_isExecuting = false;
			_isCancelled = true;
			dispatchEvent(new CommandEvent(CommandEvent.CANCEL));
		}

		/**
		 * Returns <code>true</code> if <code>cancel()</code> was called before on the receiver.
		 */
		public function get isCancelled() : Boolean
		{
			return _isCancelled;
		}

		/**
		 * Sets the receiver to a state as if it was newly initialized. Thus if it is executing, the
		 * execution will be aborted by calling <code>cancel()</code>. Nevertheless
		 * <code>isCancelled</code> is set to false afterwards, just as <code>isExecuting</code>.
		 */
		public function reset() : void
		{
			if (_isExecuting)
			{
				cancel();
			}
			_isCancelled = false;
		}


		////////////////////////         Private / Protected Methods        ////////////////////////
		/**
		 * Sends out an <code>CommandCompleteEvent.COMPLETE</code> with the given success value.
		 * <code>isExecuting</code> is set to <code>false</code> and <code>didSucceed</code> to the
		 * respective value of the passed argument.
		 *
		 * @param success Pass <code>true</code> if the execution was successful
		 */
		protected function notifyComplete(success : Boolean) : void
		{
			_isExecuting = false;
			_success = success;
			dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
		}
	}
}