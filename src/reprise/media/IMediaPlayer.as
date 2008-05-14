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

package reprise.media
{ 
	import flash.events.IEventDispatcher;
	
	public interface IMediaPlayer extends IEventDispatcher
	{
		function load(source : String) : void;
		function play(offset : Number) : void;
		function pause() : void;
		function resume() : void;
		function stop() : void;
	    
		function isPlaying() : Boolean;
	    
		function setVolume(volume : Number) : void;
		function getVolume() : Number;
	    
		function getBytesLoaded() : Number;
		function getBytesTotal() : Number;
	    
		function getDuration() : Number;
		function getDurationLoaded() : Number;
		function getPosition() : Number;
		function getLoadingTimeLeft() : Number;
	    
		function getPercentLoaded() : Number;
	    
		function destroy() : void;
	}	
}