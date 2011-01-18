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

		protected var m_stream:NetStream;
		protected var m_video:Video;
		protected var m_width:uint;
		protected var m_framerate:uint;
		protected var m_height:uint;
		protected var m_soundTransform:SoundTransform;
		protected var m_metadata:Object;
		protected var m_buffered:Boolean = false;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function FLVPlayer(resource:IResource, host:Video)
		{
			super();
			setResource(resource);
			setHost(host);
		}
		
		public override function setResource(resource:IResource):void
		{
			super.setResource(resource);
			m_stream = NetStream(FLVResource(resource).content());
			m_stream.client = this;
			m_stream.addEventListener(NetStatusEvent.NET_STATUS, stream_netStatus);
			m_soundTransform = m_stream.soundTransform = new SoundTransform(1.0, 0.0);
		}
		
		public function setHost(video:Video):void
		{
			m_video = video;
		}
		
		public override function position():Number
		{
			if (state() == AbstractPlayer.STATE_PLAYING)
				return m_stream.time;
			else
				return m_recentPosition;
		}

		public override function bytesLoaded():Number
		{
			return m_stream.bytesLoaded;
		}

		public override function bytesTotal():Number
		{
			return m_stream.bytesTotal;
		}

		public function width():Number
		{
			return m_width;
		}

		public function height():Number
		{
			return m_height;
		}
		
		/*
		* overridden in order to use the built in buffering mechanism of the netstream object 
		*/
		public override function isBuffered():Boolean
		{
			return m_buffered;
		}

		public override function bufferStatus():Number
		{
			return m_stream.bufferLength / (m_stream.bufferTime / 100);
		}

		protected override function updateBuffer():void
		{
			super.updateBuffer();
			if (isLoaded() || isNaN(m_buffer.requiredBufferLength()))
			{
				return;
			}
			m_stream.bufferTime = m_buffer.requiredBufferLength();
			if (m_stream.bufferLength >= m_stream.bufferTime)
			{
				m_buffered = true;
			}
		}

		/**
		* Events thrown by NetConnection object
		*/
		public function onMetaData(info:Object):void 
		{
			m_width = info.width;
			m_height = info.height;
			m_framerate = info.framerate;
			m_duration = info.duration;
			if (info.videodatarate && info.audiodatarate)
			{
				// videodatarate and audiodatarate are in Kbps
				m_buffer.setMediaBitrate((info.videodatarate + info.audiodatarate) / 8 * 1024);
			}
			m_buffer.setMediaLength(m_duration);

			if (isNaN(m_duration) || m_duration == 0)
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
		
		
		
		/***************************************************************************
		*							protected methods							   *
		***************************************************************************/
		protected override function doLoad():void
		{
			m_video.attachNetStream(m_stream);
			m_stream.play(m_source.url());
			m_stream.pause();
			m_video.clear();
		}

		protected override function doUnload():void
		{
			m_stream.close();
			m_video.clear();
		}

		protected override function doPlay():void
		{
			m_stream.resume();
		}

		protected override function doPause():void
		{
			m_stream.pause();
		}

		protected override function doStop():void
		{
			m_stream.pause();
			m_video.clear();
		}

		protected override function doSeek(offset:Number):void
		{
			m_stream.seek(offset);
		}
		
		protected override function doSetVolume(vol:Number):void
		{
			m_soundTransform.volume = vol;
			m_stream.soundTransform = m_soundTransform;
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
					broadcastError("File " + m_source + " not found", true);
					break;

				case "NetStream.Buffer.Full" :
					m_buffered = true;
					break;

				case "NetStream.Buffer.Flush" :
					m_buffered = isLoaded();
					break;

				case "NetStream.Buffer.Empty" :
					m_buffered = false;
					break;
			}		
		}
	}
}