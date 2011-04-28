/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.media
{
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import com.robertpenner.easing.Linear;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import reprise.events.CommandEvent;
	import reprise.events.MediaEvent;
	import reprise.events.StateChangeEvent;
	import reprise.external.IResource;
	import reprise.tweens.SimpleTween;
	import reprise.utils.MathUtil;
	
	
	/**
	* Dispatched when the media file could not be loaded.
	*
	* @eventType reprise.events.MediaEvent.ERROR
	*/
	[Event(name='error', type='reprise.events.MediaEvent')]
	
	/**
	* Dispatched when the end of the media file was reached during playback.
	*
	* @eventType reprise.events.CommandEvent.COMPLETE
	*/
	[Event(name='complete', type='reprise.events.CommandEvent')]
	
	/**
	* Dispatched before the player state changes.
	*
	* @eventType reprise.events.StateChangeEvent.STATE_WILL_CHANGE
	*/
	[Event(name='stateWillChange', type='reprise.events.StateChangeEvent')]
	
	/**
	* The AbstractPlayer class is a base class for every type of streaming media.
	* It aids in calculating buffer times and supports autostart if the buffer is full
	* as well as pausing the playback if the buffer runs out.
	*/
	public class AbstractPlayer extends EventDispatcher
	{
		
		//----------------------               Public Methods               ----------------------//
		public static var SETTINGS_TIMEOUT_DURATION:uint = 10;
		
		/** 
		* active when the player has really nothing to do
		*/
		public static const STATE_IDLE:uint = 0;
		
		/**
		* active when the player gathers information like filesize etc.
		*/
		public static const STATE_PREBUFFERING:uint = 1;
		
		/**
		* active when the player is buffering
		*/
		public static const STATE_BUFFERING:uint = 2;
		
		/**
		* active when the player is playing
		*/
		public static const STATE_PLAYING:uint = 3;
		
		/**
		* active when the player is paused
		*/
		public static const STATE_PAUSED:uint = 4;
		
		/**
		* active when the player is stopped, will switch to idle when the media is 
		* fully loaded
		*/
		public static const STATE_STOPPED:uint = 5;
		
		/**
		* set when the duration of the media is known
		*/
		public static const STATUS_DURATION_KNOWN:uint = 1 << 0;
		
		/**
		* set when the filesize of the mediafile is known
		*/
		public static const STATUS_FILESIZE_KNOWN:uint = 1 << 1;
		
		/**
		* set when the bandwidth of the user is known
		*/
		public static const STATUS_BANDWIDTH_KNOWN:uint = 1 << 2;
		
		/**
		* set while the mediafile is loaded
		*/
		public static const STATUS_IS_LOADING:uint = 1 << 3;
		
		/**
		* set after the media file was fully loaded
		*/
		public static const STATUS_LOAD_FINISHED:uint = 1 << 4;
		
		/**
		* set when the player should start instanly after the buffer was filled
		* e.g. autoplay is active, or the stream was interrupted due to a buffer underrun
		*/
		public static const STATUS_SHOULD_PLAY:uint = 1 << 5;
		
		/**
		* set when the buffer is full enough to play the mediafile with the current bandwidth
		* of the user, without interrupting
		*/
		public static const STATUS_BUFFER_FULL:uint = 1 << 6;
		
		/**
		* set after autoplay was executed. this flag is deleted if the user clicked stop. 
		* so the user can override that behaviour
		*/
		public static const STATUS_DID_AUTOPLAY:uint = 1 << 7;
		
		/**
		* set when the mediafile is paused at the last frame (video). therefore 
		* OPTIONS_REVERSE_ON_COMPLETE must be turned off
		*/
		public static const STATUS_PAUSED_AT_END:uint = 1 << 8;
		
		/**
		* a collection of properties which must be known to determine the required buffer time.
		* when this is set buffering can happen.
		*/
		public static const BUFFERING_RELEVANT_STATUS:uint = 
			STATUS_DURATION_KNOWN | STATUS_FILESIZE_KNOWN | STATUS_BANDWIDTH_KNOWN;
		
		
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected static const OPTIONS_AUTOPLAY:uint = 1 << 0;
		protected static const OPTIONS_LOOP:uint = 1 << 1;
		protected static const OPTIONS_REVERSE_ON_COMPLETE:uint = 1 << 2;
		
		protected var m_debug:Boolean = false;
		
		/**
		* Current state of the player
		* @see #state()
		*/
		protected var m_state:uint;
		protected var m_status:uint;
		protected var m_options:uint = OPTIONS_REVERSE_ON_COMPLETE;
		
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
		protected var m_muteTween:SimpleTween;
		protected var m_volumeBeforeFade:Number;
				
		
		
		//----------------------               Public Methods               ----------------------//
		public function AbstractPlayer()
		{
			m_buffer = new AbstractBuffer(this);
			m_statusObserverTimer = new Timer(100, 0);
			m_statusObserverTimer.addEventListener(TimerEvent.TIMER, observeStatus);
		}
		
		
		/**
		* Sets the resource, which should be used for later playback. May be overwritten by
		* concrete subclasses.
		* 
		* @param resource The resource which should be used for later playback
		*/
		public function setResource(resource:IResource):void
		{
			m_source = resource;
		}
		
		/**
		* Specifies whether the playback should start automatically after the buffer was filled
		* with enough data to play flawlessly at the current bandwidth of the user.
		* 
		* @param bFlag The flag which sets if the playback should start automatically
		*/
		public function setAutoplayEnabled(bFlag:Boolean):void
		{
			setOptionsFlag(OPTIONS_AUTOPLAY, bFlag);
		}
		
		/**
		* Specifies whether the playback should happen continuously. Set to true to make the 
		* player loop.
		* 
		* @param bFlag Specifies whether the player loops or not
		*/
		public function setLoops(bFlag:Boolean):void
		{
			setOptionsFlag(OPTIONS_LOOP, bFlag);
		}
		
		/**
		* Specifies whether or not to jump back to the first frame of the media, after playback 
		* finished. If set to false, the media stops at the last frame.
		* 
		* @param bFlag The flag which sets, whether or not to jump back to the first frame 
		* after playback
		*/
		public function setReversesOnComplete(bFlag:Boolean):void
		{
			setOptionsFlag(OPTIONS_REVERSE_ON_COMPLETE, bFlag);
		}
		
		/**
		* Starts loading the media resource. This method is also automatically called by the
		* the method play(). So you would call this method only directly if you want to 
		* manually start preloading the data.
		*/
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
		
		/**
		* Unloads the loaded resource and frees the used memory.
		*/
		public function unload():void
		{
			stop();
			doUnload();
			m_buffer.reset();
			m_source.reset();
			m_statusObserverTimer.reset();
			m_statusObserverTimer.removeEventListener(TimerEvent.TIMER, observeStatus);
			m_statusObserverTimer = null;
			m_source = null;
			
			if (m_status & STATUS_LOAD_FINISHED)
			{
				return;
			}
			
			m_status &= ~STATUS_IS_LOADING; // no more loading
			m_status &= ~STATUS_SHOULD_PLAY; // no more need to play

			setState(STATE_IDLE);
		}
		
		/**
		* Attempts to playback the media. If the file did not start loading before, it gets loaded
		* first. If the buffer insufficiently filled to play flawlessly at the user's current
		* bandwidth calling this method leads to no immediate effect. After the buffer was filled
		* with data the playback starts automatically.
		*/
		public function play(...args):void
		{
			if (m_status & STATUS_PAUSED_AT_END)
			{
				stop();
			}
			
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
		
		/**
		* Pauses the media file if is playing.
		*/
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
		
		/**
		* Stops the media file. If the media is not playing, but instead buffering, calling this
		* method leads to that the playback happens not automatically after the buffer was filled.
		*/
		public function stop():void
		{
			// again: what's ever happening right now, but we notice that the user wishes to 
			// stop the mediafile
			m_status &= ~STATUS_SHOULD_PLAY;
			m_status &= ~STATUS_PAUSED_AT_END;
			
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
		
		/**
		* Seeks the media file. If neither load() or play() were called previously, this method
		* does nothing. If the specified offset is greater than the already loaded duration of the
		* media file, the offset will be set to the loaded duration.
		* 
		* @param offset The offset to seek in seconds.
		*/
		public function seek(offset:Number):void
		{
			m_status &= ~STATUS_PAUSED_AT_END;
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
		
		/**
		* This method is a convenience wrapper for seek(), which practically can be used with
		* statusbars, which return percentage values.
		* 
		* @param percent The value to seek in percent relative to the duration of the media file
		*/
		public function seekPercent(percent:Number):void
		{
			seek(duration() / 100 * percent);
		}
		
		/**
		* Sets the volume of the played back media.
		* 
		* @param vol The volume between 0 and 1
		*/
		public function setVolume(vol:Number):void
		{
			vol = Math.max(0, vol);
			vol = Math.min(1, vol);
			m_volume = vol;
			doSetVolume(vol);
		}
		
		/**
		* If playing, fades out the volume and pauses the media file afterwards. If the media file
		* is not playing, this method does nothing.
		* 
		* @param duration The time how long the fade should take before the media file pauses
		*/
		public function muteAndPause(duration:uint):void
		{
			if (m_state != STATE_PLAYING)
			{
				return;
			}
			m_volumeBeforeFade = volume();
			cancelMuteTween();
			m_muteTween = new SimpleTween(duration);
			m_muteTween.addTweenProperty(this, 'setVolume', m_volumeBeforeFade, 0, 
				Linear.easeNone, false, true);
			m_muteTween.addEventListener(Event.COMPLETE, muteTween_complete);
			m_muteTween.execute();
		}
		
		/**
		* Returns the actual volume of the media file between 0 and 1
		*/
		public function volume():Number
		{
			return m_volume;
		}
		
		/**
		* Returns the bytes loaded of the media file. Needs to be overwritten in concrete
		* subclasses!
		*/
		public function bytesLoaded():Number
		{
			return 0;
		}
		
		/**
		* Returns the total size of the media file. Needs to be overwritten in concrete
		* subclasses!
		*/
		public function bytesTotal():Number
		{
			return 0;
		}
		
		/**
		* Returns the duration of the media file in seconds.
		*/
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
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
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
			if (unloadMedia)
			{
				unload();
			}
		}
		
		protected function mediaReachedEnd():void
		{
			if (m_options & OPTIONS_LOOP)
			{
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
				seek(0);
				play();
				return;
			}
			if (m_options & OPTIONS_REVERSE_ON_COMPLETE)
			{
				stop();
				goIdle();
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
				return;
			}
			m_status |= STATUS_PAUSED_AT_END;
			pause();
			dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
		}

		protected function goIdle():void
		{
			if (m_state == STATE_PLAYING || m_status & STATUS_IS_LOADING || STATE_PAUSED)
			{
				return;
			}
			setState(STATE_IDLE);
		}
		
		protected function cancelMuteTween():void
		{
			if (m_muteTween && m_muteTween.isRunning())
			{
				m_muteTween.removeEventListener(CommandEvent.COMPLETE, muteTween_complete);
				m_muteTween.cancel();
			}
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

			var oldState : uint = m_state;
			dispatchEvent(new StateChangeEvent(StateChangeEvent.STATE_WILL_CHANGE, m_state, state));
			m_state = state;
			dispatchEvent(new StateChangeEvent(StateChangeEvent.STATE_DID_CHANGE, oldState, state));

			if (state != STATE_IDLE && !m_statusObserverTimer.running)
			{
				m_statusObserverTimer.reset();
				m_statusObserverTimer.start();
			}
		}
		
		/**
		* Generates a string from the current state. This method is used for internal 
		* debugging purposes
		* 
		* @return A string representation of the current state
		*/
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
				log('>>>\n' + str + '\n<<<');
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
		
		protected function setOptionsFlag(flag:Number, value:Boolean):void
		{
			if (value)
			{
				m_options |= flag;
			}
			else
			{
				m_options &= ~flag;
			}
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
		
		protected function muteTween_complete(e:CommandEvent):void
		{
			pause();
			setVolume(m_volumeBeforeFade);
		}
	}
}