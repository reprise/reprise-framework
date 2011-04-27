/*
 * Copyright (c) 2006-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.commands
{
	import flash.events.IEventDispatcher;

	public interface IAsyncCommand extends ICommand
	{
		function cancel() : void;

		function get isCancelled() : Boolean;

		function get isExecuting() : Boolean;

		function reset() : void;
	}
}