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
	import reprise.events.MediaPlayerDisplayEvent;
	import reprise.utils.ProxyFunction;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.media.Video;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	public class MediaPlayerDisplay extends EventDispatcher
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_playButton : MovieClip;
		protected var m_pauseButton : MovieClip;
		protected var m_stopButton : MovieClip;
		protected var m_timeScrubber : MovieClip;
		protected var m_timeScrubberMinX : Number;
		protected var m_timeScrubberMaxX : Number;
		protected var m_loadingBarMaxWidth : Number;
		
		protected var m_display : Video;
		protected var m_audioTarget : MovieClip;
		
		protected var m_player : IMediaPlayer;
	
		protected var m_loadingBar : MovieClip;
		protected var m_progressBar : MovieClip;
	
		protected var m_timeUpdateInterval : Number;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function MediaPlayerDisplay ()
		{
			
		}
		
		public function setAudio (source:String) : void
		{
			m_player = new MP3Player(m_audioTarget);
			//TODO: add proper event relaying
//			m_player.setDispatcherParent(this);
			initPlayer(source);
		}
		public function setVideo (source:String) : void
		{
			m_player = new FLVPlayer (m_display, m_audioTarget);
			//TODO: add proper event relaying
//			m_player.setDispatcherParent(this);
			initPlayer(source);
		}
		
		public function setDisplay (display:Video) : void
		{
			m_display = display;
		}
		public function setAudioTarget (target:MovieClip) : void
		{
			m_audioTarget = target;
		}
		
		public function setPlayButton (btn:MovieClip) : void
		{
			m_playButton = btn;
			btn.onRelease = ProxyFunction.create (this, onPlayClick);
		}
		public function setPauseButton (btn:MovieClip) : void
		{
			m_pauseButton = btn;
			btn.onRelease = ProxyFunction.create (this, onPauseClick);
		}
		public function setStopButton (btn:MovieClip) : void
		{
			m_stopButton = btn;
			btn.onRelease = ProxyFunction.create (this, onStopClick);
		}
		public function setTimeScrubber (
			scrubber:MovieClip, minX:Number, maxX:Number) : void
		{
			m_timeScrubber = scrubber;
			m_timeScrubberMinX = minX;
			m_timeScrubberMaxX = maxX;
			
			scrubber.onPress = ProxyFunction.create (this, startTimeScrub);
			scrubber.onRelease = scrubber.onReleaseOutside = 
				ProxyFunction.create (this, stopTimeScrub);
		}
		public function setScrubbingArea(minX:Number, maxX:Number) : void
		{
			m_timeScrubberMinX = minX;
			m_timeScrubberMaxX = maxX;
			
		}
		
		public function setLoadingBar (bar:MovieClip, seekToClickPosition:Boolean, 
			loadingBarMaxWidth:Number) : void
		{
			m_loadingBar = bar;
			
			m_loadingBarMaxWidth = loadingBarMaxWidth;
			
			if (seekToClickPosition)
			{
				m_loadingBar.onRelease = ProxyFunction.create(this, loadingBar_click);
			}
		}
		
		public function setProgressBar (bar:MovieClip) : void
		{
			m_progressBar = bar;
		}
		
		/**
		 * sets the volume of the current player
		 */
		public function setVolume (volume:Number) : void
		{
			m_player.setVolume(volume);
		}
		
		public function getVolume() : Number
		{
			return 	m_player.getVolume();
		}
			
		/**
		 * starts the media at the given offset
		 */
		public function play(offset : Number = -1) : void
		{
			m_playButton.visible = false;
			m_pauseButton.visible = true;
			
			if (offset == -1)
			{
				m_player.resume();
			}
			else {
				m_player.play(offset);
			}
		}
		
		/**
		 * stops the playing media
		 */
		public function stop() : void
		{
			m_playButton.visible = true;
			m_pauseButton.visible = false;
			
			m_player.stop();
		}
		
		/**
		 * pauses the playing media
		 */
		public function pause():void
		{
			m_playButton.visible = true;
			m_pauseButton.visible = false;
			
			m_player.pause();
		}
		
		/**
		 * restarts the playing media
		 */
		public function resume():void
		{
			onPlayClick();
		}
		
		/**
		 * destroys the playing media
		 */
		public function destroy() : void
		{
			if (m_timeUpdateInterval)
			{
				clearInterval(m_timeUpdateInterval);
			}
			m_player.destroy();
		}
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function initPlayer(source : String) : void
		{
			m_timeUpdateInterval = setInterval (
				ProxyFunction.create (this, updateTime), 50);
			m_player.load (source);
			onPlayClick();
		}
		
		//event-handlers
		protected function onPlayClick () : void
		{
			this.play();
			dispatchEvent(new MediaPlayerDisplayEvent(
				MediaPlayerDisplayEvent.PLAY_CLICK));
		}
		protected function onPauseClick () : void
		{
			pause();
			dispatchEvent(new MediaPlayerDisplayEvent(
				MediaPlayerDisplayEvent.PAUSE_CLICK));
		}
		protected function onStopClick () : void
		{
			this.stop();
			dispatchEvent(new MediaPlayerDisplayEvent(
				MediaPlayerDisplayEvent.STOP_CLICK));
		}
		
		protected function startTimeScrub () : void
		{
			m_timeScrubber.scrubbing = true;
			m_timeScrubber.offsetX = m_timeScrubber.mouseX;
			m_player.pause();
		}
		protected function stopTimeScrub () : void
		{
			var pos:Number = (m_timeScrubber.x - m_timeScrubberMinX) / 
				(m_timeScrubberMaxX - m_timeScrubberMinX) * m_player.getDuration ();
			m_timeScrubber.scrubbing = false;
			m_player.play(pos);
		}
		protected function updateTime () : void
		{
			if (m_timeScrubber.scrubbing) {
				m_timeScrubber.x = 
					m_timeScrubber.parent.mouseX - m_timeScrubber.offsetX;
				if (m_timeScrubber.x < m_timeScrubberMinX)
					m_timeScrubber.x = m_timeScrubberMinX;
				else if (m_timeScrubber.x > m_timeScrubberMaxX)
					m_timeScrubber.x = m_timeScrubberMaxX;
			}
			else {
				m_timeScrubber.x = m_timeScrubberMinX + 
					(m_timeScrubberMaxX - m_timeScrubberMinX) * 
					m_player.getPosition () / m_player.getDuration ();
			}
			if(m_loadingBarMaxWidth)
			{
				m_loadingBar.width = 
					m_loadingBarMaxWidth / 100 * m_player.getPercentLoaded();
			}
			else
			{
				m_loadingBar.scaleX = m_player.getPercentLoaded();
			}
			m_progressBar.width = m_timeScrubber.x - m_timeScrubberMinX;
			//TODO: check if we need this and find a replacement if true
//			updateAfterEvent ();
		}
	
		protected function loadingBar_click() : void
		{
			var xPos:Number = m_timeScrubber.parent.mouseX;
			xPos = (xPos < m_timeScrubberMinX ? m_timeScrubberMinX : 
				(xPos > m_timeScrubberMaxX ? m_timeScrubberMaxX : xPos));
			m_timeScrubber.x = xPos;
			stopTimeScrub();
		}
	}
}