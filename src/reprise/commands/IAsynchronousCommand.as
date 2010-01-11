/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.commands
{ 
	import reprise.commands.ICommand;
	
	public interface IAsynchronousCommand extends ICommand
	{
		function cancel() : void;
		function isCancelled() : Boolean;
		function isExecuting() : Boolean;
		function reset() : void;
	}
}