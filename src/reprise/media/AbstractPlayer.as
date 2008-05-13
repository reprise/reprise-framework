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
	
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import reprise.commands.TimeCommandExecutor;
	import reprise.events.CommandEvent;
	import reprise.events.StateChangeEvent;
	import reprise.events.MediaEvent;
	import reprise.external.IResource;
	import reprise.utils.MathUtil;
	
	
	public class AbstractPlayer extends EventDispatcher
	{
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static var SETTINGS_TIMEOUT_DURATION:uint = 10;
		
		public static const STATE_IDLE:uint = 0;
		public static const STATE_PREBUFFERING:uint = 1;
		public static const STATE_BUFFERING:uint = 2;
		public static const STATE_PLAYING:uint = 3;
		public static const STATE_PAUSED:uint = 4;
		public static const STATE_STOPPED:uint = 5;
		
		public static const STATUS_DURATION_KNOWN:uint = 1 << 0;
		public static const STATUS_FILESIZE_KNOWN:uint = 1 << 1;
		public static const STATUS_BANDWIDTH_KNOWN:uint = 1 << 2;
		public static const STATUS_IS_LOADING:uint = 1 << 3;
		public static const STATUS_LOAD_FINISHED:uint = 1 << 4;
		public static const STATUS_SHOULD_PLAY:uint = 1 << 5;
		public static const STATUS_BUFFER_FULL:uint = 1 << 6;
		public static const STATUS_DID_AUTOPLAY:uint = 1 << 7;
		public static const BUFFERING_RELEVANT_STATUS:uint = 
			STATUS_DURATION_KNOWN | STATUS_FILESIZE_KNOWN | STATUS_BANDWIDTH_KNOWN;
		
		
		
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		protected static const OPTIONS_AUTOPLAY:uint = 1 << 0;
		protected static const OPTIONS_LOOP:uint = 1 << 1;
		
		protected var m_debug:Boolean = false;
		
		protected var m_state:uint;
		protected var m_status:uint;
		protected var m_options:uint;
		
		protected var m_buffer:AbstractBuffer;
		protected var m_statusObserverTimer:Timer;
		protected var m_source:IResource;
		protected var m_volume:Number = 100;
		protected var m_duration:Number = 0;
		protected var m_recentPosition:Number = 0;
		
		protected var m_startTime:uint;
		protected var m_speed:Number;
		protected var m_lastLoadProgress:uint = 0;
		protected var m_lastSpeedCheck:uint;
				
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function AbstractPlayer()
		{
			m_buffer = new AbstractBuffer(this);
			m_statusObserverTimer = new Timer(100, 0);
			m_statusObserverTimer.addEventListener(TimerEvent.TIMER, observeStatus);
		}
		
		
		public function setResource(resource:IResource):void
		{
			m_source = resource;
		}
		
		public function setAutoplayEnabled(bFlag:Boolean):void
		{
			if (bFlag)
			{
				m_options |= OPTIONS_AUTOPLAY;
			}
			else
			{
				m_options &= ~OPTIONS_AUTOPLAY;
			}
		}
		
		public function load():void
		{
			if (m_status & STATUS_LOAD_FINISHED || m_status & STATUS_IS_LOADING)
			{
				return;
			}
			
			// reset everything
			m_status &= ~STATUS_BUFFER_FULL;
			m_status &= ~STATUS_DURATION_KNOWN;
			m_status &= ~STATUS_FILESIZE_KNOWN;
			m_status &= ~STATUS_BANDWIDTH_KNOWN;
			
			setState(STATE_PREBUFFERING);
			
			m_status |= STATUS_IS_LOADING;
			m_startTime = m_lastSpeedCheck = getTimer();
			doLoad();
		}
		
		public function unload():void
		{
			stop();
			if (m_status & STATUS_LOAD_FINISHED)
			{
				return;
			}
			
			m_status &= ~STATUS_IS_LOADING; // no more loading
			m_status &= ~STATUS_SHOULD_PLAY; // no more need to play
			
			m_buffer.reset();
			doUnload();
			setState(STATE_IDLE);
		}
		
		public function play():void
		{
			load();
			m_status |= STATUS_SHOULD_PLAY;
			
			// prebuffering means, that we have no clue about the user bandwidth, the filesize, etc.
			// we need a little time to figure these things out and present some proper status to
			// the user afterwards.
			if (state() == STATE_PREBUFFERING)
			{
				return;
			}
			
			setState(STATE_PLAYING);
			doPlay();
		}
		
		public function pause():void
		{
			// what's ever happening right now, but we notice that the user wishes to 
			// stop the mediafile
			m_status &= ~STATUS_SHOULD_PLAY;
			
			if (m_state != STATE_PLAYING)
			{
				return;
			}
			
			m_recentPosition = position();
			setState(STATE_PAUSED);
			doPause();
			goIdle();
		}
		
		public function stop():void
		{
			// again: what's ever happening right now, but we notice that the user wishes to 
			// stop the mediafile
			m_status &= ~STATUS_SHOULD_PLAY;
			
			if (m_state != STATE_PLAYING && m_state != STATE_PAUSED)
			{
				return;
			}
			
			seek(0);
			setState(STATE_STOPPED);
			doStop();
			// give an opportunity to the UI, to update it's position control 
			// via an play_progress event
			checkPlayProgress();
			goIdle();
		}
		
		public function seek(offset:Number):void
		{
			if ([STATE_PLAYING, STATE_PAUSED, STATE_IDLE].indexOf(m_state) == -1 ||
				(!(m_status & STATUS_IS_LOADING) && !(m_status & STATUS_LOAD_FINISHED)))
			{
				return;
			}
			if (isNaN(offset) || offset < 0)
			{
				offset = 0;
			}
			else if (offset > durationLoaded())
			{
				offset = durationLoaded();
			}
			doSeek(offset);
		}
		
		public function seekPercent(percent:Number):void
		{
			seek(duration() / 100 * percent);
		}
		
		public function setVolume(vol:Number):void
		{
			vol = Math.max(0, vol);
			vol = Math.min(1, vol);
			m_volume = vol;
			doSetVolume(vol);
		}
		
		public function volume():Number
		{
			return m_volume;
		}
		
		public function bytesLoaded():Number
		{
			return 0;
		}
		
		public function bytesTotal():Number
		{
			return 0;
		}
		
		public function duration():Number
		{
			return m_duration;
		}
		
		public function state():uint
		{
			return m_state;
		}
		
		public function status():uint
		{
			return m_status;
		}
		
		public function isPlaying():Boolean
		{
			return m_state == STATE_PLAYING;
		}
		
		public function position():Number
		{
			return 0;
		}
		
		public function positionPercent():Number
		{
			return position() / (duration() / 100);
		}
		
		public function estimatedBufferTime():Number
		{
			return m_buffer.requiredBufferDuration();
		}
		
		public function isBuffered():Boolean
		{
			return isLoaded() || m_buffer.bufferFill() >= 100;
		}		

		public function bufferStatus():Number
		{
			return m_buffer.bufferFill();
		}
		
		public function remainingBufferingDuration():Number
		{
			return m_buffer.remainingBufferingDuration();
		}

		public function durationLoaded():Number
		{
			return m_buffer.loadedMediaLength();
		}

		public function isLoaded():Boolean
		{
			return Boolean(m_status & STATUS_LOAD_FINISHED);
		}

		public function loadStartTime():uint
		{
			return m_startTime;
		}
		
		public function loadProgress():Number
		{
			return bytesLoaded() / (bytesTotal() / 100);
		}
		
		
		
		/***************************************************************************
		*							protected methods							   *
		***************************************************************************/
		/**
		* This should be overridden by concrete subclasses to do something useful
		**/
		protected function doStop():void {}
		protected function doPause():void {}
		protected function doPlay():void {}
		protected function doSeek(offset:Number):void {}
		protected function doSetVolume(vol:Number):void {}
		protected function doLoad():void {}
		protected function doUnload():void {}
		
		protected function updateBuffer():void
		{
			m_buffer.setPlayheadPosition(position());
			m_buffer.setUserBandwidth(m_speed);
			m_buffer.setBytesLoaded(bytesLoaded());
			m_buffer.setMediaSize(bytesTotal());
			m_buffer.setMediaLength(duration());
		}
		
		protected function log(msg:String):void
		{
			trace('[AbstractPlayer] Source: ' + m_source.url() + '\nMessage: ' + msg);
		}
	
		protected function broadcastError(msg:String, unloadMedia:Boolean):void
		{
			log('Error! ' + msg);
			var evt:MediaEvent = new MediaEvent(MediaEvent.ERROR);
			evt.message = msg;
			dispatchEvent(evt);
			if (unloadMedia == true)
			{
				unload();
			}
		}
		
		protected function mediaReachedEnd():void
		{
			if (m_options & OPTIONS_LOOP)
			{
				play();
				return;
			}
			
			stop();
			goIdle();
			dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
		}

		protected function goIdle():void
		{
			if (m_state == STATE_PLAYING || m_status & STATUS_IS_LOADING)
			{
				return;
			}
			setState(STATE_IDLE);
		}
		
		protected function setState(state:uint):void
		{
			if (m_state == state)
			{
				return;
			}
			
			if (state == STATE_IDLE)
			{
				m_statusObserverTimer.stop();
			}
			
			var oldState:uint = m_state;
			dispatchEvent(new StateChangeEvent(StateChangeEvent.STATE_WILL_CHANGE, m_state, state));
			m_state = state;
			dispatchEvent(new StateChangeEvent(StateChangeEvent.STATE_DID_CHANGE, oldState, state));
			
			if (state != STATE_IDLE)
			{
				if (!m_statusObserverTimer.running)
				{
					m_statusObserverTimer.reset();
					m_statusObserverTimer.start();
				}
			}
		}
		
		protected function stateToString():String
		{
			var state:String = 'PLAYING';
			switch (m_state)
			{
				case STATE_PAUSED:
					state = 'PAUSED';
					break;
				case STATE_IDLE : 
					state = 'IDLE';
					break;
				case STATE_STOPPED :
					state = 'STOPPED';
					break;
				case STATE_PREBUFFERING :
					state = 'PREBUFFERING';
					break;
				case STATE_BUFFERING :
					state = 'BUFFERING';
					break;
			}
			return state;
		}
	
		// Checking what's going on. This part is essentially the work we take on for 
		// our concrete subclasses
		protected function checkPlayProgress():void
		{
			var percent:Number = position() / (duration() / 100);
			dispatchEvent(new MediaEvent(MediaEvent.PLAY_PROGRESS));
		}
	
		protected function checkLoadProgress():void
		{
			var ttl:Number = bytesTotal();
			if (ttl <= 100 || isNaN(ttl))
			{
				return;
			}
			m_status |= STATUS_FILESIZE_KNOWN;
			var percent:Number = bytesLoaded() / (ttl / 100);
			dispatchEvent(new MediaEvent(MediaEvent.LOAD_PROGRESS));
			measureSpeed();
			
			if (m_debug)
			{
				var str:String = '';
				str += 'bw/rem/avg/lps time: ' + MathUtil.round(m_speed / 1024, 1) + ' KB/s | ' + 
					MathUtil.round(m_buffer.remainingDownloadDuration() / 60, 2) + ' min. | ' + 
					MathUtil.round(m_buffer.averageUserBandwidth() / 1024, 1) + ' KB/s | ' + 
					MathUtil.round(m_buffer.loadedMediaLengthPerSecond(), 2) + ' s/s\n';
				str += 'media size (ttl/load/%/br): ' + MathUtil.round(bytesTotal() / 1024, 2) + 
					' KB | ' + MathUtil.round(bytesLoaded() / 1024, 2) + ' KB | ' + 
					MathUtil.round(bytesLoaded() / (bytesTotal() / 100), 1) + '% | ' + 
					MathUtil.round(m_buffer.mediaBitrate() / 1024, 2) + ' KB/s\n';
				str += 'media length (ttl/load/ply/%): ' + MathUtil.round(duration() / 60, 2) + 
					' min. | ' + MathUtil.round(durationLoaded() / 60, 2) + ' min. | ' + 
					MathUtil.round(position() / 60, 2) + ' min. | ' + 
					MathUtil.round(positionPercent(), 1) + '%\n';
				str += 'buffer (req/load/%/rem): ' + MathUtil.round(
						m_buffer.requiredBufferLength() / 60, 2) + ' min. | ' + 
					MathUtil.round(m_buffer.loadedBufferLength() / 60, 2) + ' min. | ' + 
					MathUtil.round(bufferStatus(), 1) + '% | ' +
					MathUtil.round(m_buffer.remainingBufferingDuration()) + ' s\n';
				str += 'state: ' + stateToString();
				trace('>>>\n' + str + '\n<<<');
			}
			
			if (bytesLoaded() >= bytesTotal())
			{
				loadFinished();
			}
		}

		protected function measureSpeed():void
		{
			var t:Number = getTimer();
			var startDif:Number = t - m_startTime;
			var curDif:Number = t - m_lastSpeedCheck; 
		
			if (startDif < 3000 || !(m_status & STATUS_FILESIZE_KNOWN) || 
				m_status & STATUS_BANDWIDTH_KNOWN && curDif < 5000 )
			{
				return;
			}

			var seconds:Number = curDif / 1000;
			var bLoaded:Number = bytesLoaded() - m_lastLoadProgress;
			m_lastLoadProgress = bytesLoaded();
			m_lastSpeedCheck = t;
			m_speed = bLoaded / seconds; // b/s
		
			// see if we have a valid value
			if (m_speed < 0 || isNaN(m_speed))
			{
				// if we tried too long, we give up, throw an error event and unload our media file
				if (startDif >= SETTINGS_TIMEOUT_DURATION)
				{
					broadcastError('Timeout exceeded. Please double-check if the file ' + 
						m_source + ' exists on the server', true);
				}
				return;
			}
			m_status |= STATUS_BANDWIDTH_KNOWN;
		}
		
		protected function loadFinished():void
		{
			var ttl:Number = Number(bytesTotal());
			if (ttl <= 100 || isNaN(ttl))
			{
				return;
			}
			m_status |= STATUS_LOAD_FINISHED;
			m_status &= ~STATUS_IS_LOADING;
			updateBuffer();
			goIdle();
			dispatchEvent(new MediaEvent(MediaEvent.LOAD_COMPLETE));
		}
	
		protected function observeStatus(e:TimerEvent):void
		{
			if (m_state == STATE_IDLE)
			{
				return;
			}
		
			// udpate play status when playing
			if (m_state == STATE_PLAYING && m_status & STATUS_DURATION_KNOWN)
			{
				checkPlayProgress();
			}
			
			// update load status when loading
			if (!(m_status & STATUS_LOAD_FINISHED) && m_status & STATUS_IS_LOADING)
			{
				checkLoadProgress();
			}
		
			// check if we know how long our media file is
			if (duration() > 0 && !isNaN(duration()))
			{
				m_status |= STATUS_DURATION_KNOWN;
			}
			
			// go no further if we know not enough to feed our buffer with information
			if (m_state == STATE_PREBUFFERING && 
				!((m_status & BUFFERING_RELEVANT_STATUS) == BUFFERING_RELEVANT_STATUS) && 
				!(m_status & STATUS_LOAD_FINISHED))
			{
				return;
			}
		
			// do go further if we know enough
			if (m_state == STATE_PREBUFFERING && m_status & BUFFERING_RELEVANT_STATUS)
			{
				setState(STATE_BUFFERING);
			}

			// self explaining
			updateBuffer();

			// play when we should
			if ((isBuffered() || m_status & STATUS_LOAD_FINISHED) && 
				!(m_status & STATUS_BUFFER_FULL) &&
				(m_status & STATUS_SHOULD_PLAY || 
					(m_options & OPTIONS_AUTOPLAY && !(m_status & STATUS_DID_AUTOPLAY))))
			{
				m_status |= STATUS_DID_AUTOPLAY;
				m_status |= STATUS_BUFFER_FULL;
				if (m_state != STATE_PLAYING)
				{
					play();
				}
			}
			// pause on buffer underrun
			else if (!isBuffered() && !(m_status & STATUS_LOAD_FINISHED))
			{
				m_status &= ~STATUS_BUFFER_FULL;
				// if buffer is equal or less than .5 percent filled, we pause
				if (bufferStatus() <= .5)
				{
					if (m_state == STATE_PLAYING)
					{
						pause();
						m_status |= STATUS_SHOULD_PLAY;
					}
				}
			}
		}
	}
}