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

package reprise.external
{ 
	import reprise.commands.IProgressCommand;
	
	
	public interface IResource extends IProgressCommand
	{
		function load( url : String = null) : void;
		function didFinishLoading() : Boolean;	
		function setURL( src : String ) : void;
		function url() : String;
		function content() : *;
		function setTimeout( timeout : Number ) : void;
		function timeout() : Number;
		function setForceReload( bFlag : Boolean ) : void;
		function forceReload() : Boolean;
		function setRetryTimes( times : Number ) : void;
		function retryTimes() : Number;
		function bytesLoaded() : Number;
		function bytesTotal() : Number;
	}
}