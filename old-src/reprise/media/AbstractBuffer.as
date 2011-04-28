/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.media
{
	import reprise.media.AbstractPlayer;

	public class AbstractBuffer
	{
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var m_userBandwidth:Number; // Bytes per second
		protected var m_mediaLength:Number; // Seconds
		protected var m_mediaSize:Number; // Bytes
		protected var m_playheadPosition:Number; // Seconds
		protected var m_bytesLoaded:Number; // Bytes
		protected var m_player:AbstractPlayer;
		protected var m_bandwidthUpdates:Number;
		protected var m_bandwidthSum:Number;
		protected var m_bitrate:Number;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function AbstractBuffer(ply:AbstractPlayer) 
		{
			reset();
			m_player = ply;
		}
	
		public function reset():void
		{
			m_userBandwidth = 0;
			m_mediaLength = 0;
			m_mediaSize = 0;
			m_playheadPosition = 0;
			m_bytesLoaded = 0;
			m_bitrate = 0;
			m_bandwidthUpdates = 0;
			m_bandwidthSum = 0;
		}	
	
		public function userBandwidth():Number
		{
			return m_userBandwidth;
		}

		public function setUserBandwidth(val:Number):void
		{
			m_bandwidthUpdates++;
			m_bandwidthSum += val;
			m_userBandwidth = val;
		}
		
		public function averageUserBandwidth():Number
		{
			return m_bandwidthSum / m_bandwidthUpdates;
		}
	
		public function mediaLength():Number
		{
			return m_mediaLength;
		}

		public function setMediaLength(val:Number):void
		{
			m_mediaLength = val;
		}
	
		public function mediaSize():Number
		{
			return m_mediaSize;
		}

		public function setMediaSize(val:Number):void
		{
			m_mediaSize = val;
		}
		
		public function remainingMediaSize():Number
		{
			return m_mediaSize - m_bytesLoaded;
		}
	
		public function playheadPosition():Number
		{
			return m_playheadPosition;
		}

		public function setPlayheadPosition(val:Number):void
		{
			m_playheadPosition = val;
		}
		
		public function remainingMediaLength():Number
		{
			return m_mediaLength - m_playheadPosition;
		}
	
		public function bytesLoaded():Number
		{
			return m_bytesLoaded;
		}

		public function setBytesLoaded(val:Number):void
		{
			m_bytesLoaded = val;
		}	
	
		public function downloadDuration():Number
		{
			return mediaSize() / userBandwidth();
		}
	
		public function remainingDownloadDuration():Number
		{
			return remainingMediaSize() / userBandwidth();
		}
	
		public function requiredBufferDuration():Number
		{
			var reqBufLen:Number = remainingMediaLength() / loadedMediaLengthPerSecond() -
				remainingMediaLength();
			reqBufLen = Math.min(reqBufLen, remainingDownloadDuration());
			reqBufLen = Math.max(reqBufLen, 0);
			return reqBufLen;
		}
	
		public function loadedBufferLength():Number
		{
			var sz:Number = loadedMediaLength() - playheadPosition();
			return Math.max(sz, 0);		
		}
	
		public function requiredBufferLength():Number
		{
			return requiredBufferSize() / mediaBitrate();
		}
	
		public function requiredBufferSize():Number
		{
			return requiredBufferDuration() * userBandwidth();
		}
	
		public function loadedBufferSize():Number
		{
			return loadedBufferLength() * mediaBitrate();
		}
	
		public function loadedMediaLength():Number
		{
			return m_bytesLoaded / mediaBitrate();
		}
		
		public function loadedMediaLengthPerSecond():Number
		{
			return m_userBandwidth / mediaBitrate();
		}
		
		public function remainingBufferingDuration():Number
		{
			return (requiredBufferSize() - loadedBufferSize()) / userBandwidth();
		}
	
		/***
		* Function: bufferFill
		* Returns: Returns how much the buffer is filled in percent
		***/
		public function bufferFill():Number
		{
			if (loadedBufferLength() >= requiredBufferDuration())
				return 100;
		
			var total:Number = requiredBufferDuration();
			var current:Number = loadedMediaLength() - playheadPosition();		
			return Math.max(current / (total / 100), 0);
		}
	
		public function setMediaBitrate(bitrate:Number):void
		{
			m_bitrate = bitrate;
		}
	
		/**
		* Function: mediaBitrate
		* Returns: bitrate of the media file (bytes/second)
		**/
		public function mediaBitrate():Number
		{
			return m_bitrate || m_mediaSize / m_mediaLength;
		}
	}
}