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
		public function load(source : String) : void;
		public function play(offset : Number) : void;
		public function pause() : void;
		public function resume() : void;
		public function stop() : void;
	
		public function isPlaying() : Boolean;
	
		public function setVolume(volume : Number) : void;
		public function getVolume() : Number;
	
		public function getBytesLoaded() : Number;
		public function getBytesTotal() : Number;
	
		public function getDuration() : Number;
		public function getDurationLoaded() : Number;
		public function getPosition() : Number;
		public function getLoadingTimeLeft() : Number;
	
		public function getPercentLoaded() : Number;
	
		public function destroy() : void;
	}	
}