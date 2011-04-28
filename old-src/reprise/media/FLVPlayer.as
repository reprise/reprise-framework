/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.media
{
	import reprise.events.MediaEvent;
	import reprise.external.FLVResource;
	import reprise.external.IResource;
	import reprise.media.AbstractPlayer;

	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetStream;

	public class FLVPlayer extends AbstractPlayer
	{

		protected var _stream:NetStream;
		protected var _video:Video;
		protected var _width:uint;
		protected var _framerate:uint;
		protected var _height:uint;
		protected var _soundTransform:SoundTransform;
		protected var _metadata:Object;
		protected var _buffered:Boolean = false;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function FLVPlayer(resource:IResource, host:Video)
		{
			super();
			setResource(resource);
			setHost(host);
		}
		
		public override function setResource(resource:IResource):void
		{
			if (_stream)
			{
				cleanupStream();
			}
			super.setResource(resource);
			_stream = NetStream(FLVResource(resource).content());
			_stream.client = this;
			_stream.addEventListener(NetStatusEvent.NET_STATUS, stream_netStatus);
			_soundTransform = _stream.soundTransform = new SoundTransform(1.0, 0.0);
		}
		
		public function setHost(video:Video):void
		{
			_video = video;
		}
		
		public override function position():Number
		{
			if (state() == AbstractPlayer.STATE_PLAYING)
				return _stream.time;
			else
				return _recentPosition;
		}

		public override function bytesLoaded():Number
		{
			return _stream.bytesLoaded;
		}

		public override function bytesTotal():Number
		{
			return _stream.bytesTotal;
		}

		public function width():Number
		{
			return _width;
		}

		public function height():Number
		{
			return _height;
		}
		
		/*
		* overridden in order to use the built in buffering mechanism of the netstream object 
		*/
		public override function isBuffered():Boolean
		{
			return _buffered;
		}

		public override function bufferStatus():Number
		{
			return _stream.bufferLength / (_stream.bufferTime / 100);
		}

		protected override function updateBuffer():void
		{
			super.updateBuffer();
			if (isLoaded() || isNaN(_buffer.requiredBufferLength()))
			{
				return;
			}
			_stream.bufferTime = _buffer.requiredBufferLength();
			if (_stream.bufferLength >= _stream.bufferTime)
			{
				_buffered = true;
			}
		}

		/**
		* Events thrown by NetConnection object
		*/
		public function onMetaData(info:Object):void 
		{
			_width = info.width;
			_height = info.height;
			_framerate = info.framerate;
			_duration = info.duration;
			if (info.videodatarate && info.audiodatarate)
			{
				// videodatarate and audiodatarate are in Kbps
				_buffer.setMediaBitrate((info.videodatarate + info.audiodatarate) / 8 * 1024);
			}
			_buffer.setMediaLength(_duration);

			if (isNaN(_duration) || _duration == 0)
			{
				broadcastError('Duration of video not embedded. Please reencode video with ' + 
					'appropriate encoder which does handle this.', true);
			}
			
			dispatchEvent(new MediaEvent(MediaEvent.DIMENSIONS_KNOWN));
		}
		
		public function onXMPData(info:Object):void 
		{
			log("i raw XMP data:\n" + info.data);
		}
		
		public function onCuePoint(info:Object):void 
		{
			log("i cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function doLoad():void
		{
			_video.attachNetStream(_stream);
			_source.execute();
			_stream.pause();
			_video.clear();
		}

		protected override function doUnload():void
		{
			_stream && cleanupStream();
			_video && _video.clear();
		}

		protected override function doPlay():void
		{
			if (!_source.isExecuting())
			{
				_source.execute();
			}
			else
			{
				_stream.resume();
			}
		}

		protected override function doPause():void
		{
			_stream.pause();
		}

		protected override function doStop():void
		{
			_stream.pause();
			_video.clear();
		}

		protected override function doSeek(offset:Number):void
		{
			_stream.seek(offset);
		}
		
		protected override function doSetVolume(vol:Number):void
		{
			_soundTransform.volume = vol;
			_stream.soundTransform = _soundTransform;
		}

		protected function cleanupStream() : void
		{
			_source.reset();
			_stream.removeEventListener(NetStatusEvent.NET_STATUS, stream_netStatus);
			_stream.soundTransform = null;
			_stream = null;
		}
		
		protected function stream_netStatus(e:NetStatusEvent):void
		{
			if (state() == STATE_PREBUFFERING)
			{
				return;
			}

			switch (e.info.code)
			{
				case "NetStream.Play.Stop" :
					mediaReachedEnd();
					break;

				case "NetStream.Play.StreamNotFound" :
					broadcastError("File " + _source + " not found", true);
					break;

				case "NetStream.Buffer.Full" :
					_buffered = true;
					break;

				case "NetStream.Buffer.Flush" :
					_buffered = isLoaded();
					break;

				case "NetStream.Buffer.Empty" :
					_buffered = false;
					break;
			}		
		}
	}
}