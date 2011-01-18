/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.events
{ 
	import flash.events.Event;
	
	/**
	 * @author till
	 */
	public class MediaEvent extends Event
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const PLAYBACK_START : String = "playbackStart";
		public static const PLAYBACK_PAUSE : String = "playbackPause";
		public static const PLAYBACK_FINISH : String = "playbackFinish";
		public static const BUFFERING : String = "buffering";
		public static const VIDEO_INITIALIZE : String = "videoInitialize";
		public static const CUE_POINT : String = "cuePoint";
		public static const LOAD_COMPLETE : String = 'loadCompleteMediaEvent';
		public static const PLAY_PROGRESS : String = 'playProgressMediaEvent';
		public static const LOAD_PROGRESS : String = 'loadProgressMediaEvent';
		public static const DIMENSIONS_KNOWN : String = 'dimensionsKnownMediaEvent';
		public static const ERROR : String = 'errorMediaEvent';
		
		public var metaData : Object;
		public var cuePoint : Object;
		public var message : String;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function MediaEvent(type : String, bubbles : Boolean = false)
		{
			super(type, bubbles);
		}
	}
}