/*
 * Copyright (c) 2006-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.commands
{
	public interface ICommand
	{
		function execute() : void;

		function get priority() : int;
		function set priority(value : int) : void;

		function get id() : int;
		function set id(value : int) : void;

		function get success() : Boolean;

		function set queue(queue : CompositeCommand) : void;
	}
}