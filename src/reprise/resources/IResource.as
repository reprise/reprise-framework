/*
* Copyright (c) 2006-2011 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.resources
{
	import reprise.commands.IAsyncCommand;

	public interface IResource extends IAsyncCommand
	{
		function load(url : String = null) : void;
		function completed() : Boolean;

		function set url(url : String) : void;
		function get url() : String;

		function get bytesLoaded() : int;
		function get bytesTotal() : int;

		function content() : *;
	}
}