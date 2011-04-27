/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.resources
{ 
	import reprise.commands.IProgressCommand;
	
	
	public interface IResource extends IProgressCommand
	{
		function load( url : String = null) : void;
		function didFinishLoading() : Boolean;	
		function setURL( src : String ) : void;
		function url() : String;
		function content() : *;
		function setTimeout( timeout : int ) : void;
		function timeout() : int;
		function setForceReload( bFlag : Boolean ) : void;
		function forceReload() : Boolean;
		function setRetryTimes( times : int ) : void;
		function retryTimes() : int;
		function bytesLoaded() : int;
		function bytesTotal() : int;
	}
}