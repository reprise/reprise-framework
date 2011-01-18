/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.data
{

	import reprise.commands.ICommand;

	
	public interface IValidator extends ICommand
	{
		function setValue(value:*):void;
		function value():*;
	}
}