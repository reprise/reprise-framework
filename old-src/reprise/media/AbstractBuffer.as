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
		protected var _userBandwidth:Number; // Bytes per second
		protected var _mediaLength:Number; // Seconds
		protected var _mediaSize:Number; // Bytes
		protected var _playheadPosition:Number; // Seconds
		protected var _bytesLoaded:Number; // Bytes
		protected var _player:AbstractPlayer;
		protected var _bandwidthUpdates:Number;
		protected var _bandwidthSum:Number;
		protected var _bitrate:Number;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function AbstractBuffer(ply:AbstractPlayer) 
		{
			reset();
			_player = ply;
		}
	
		public function reset():void
		{
			_userBandwidth = 0;
			_mediaLength = 0;
			_mediaSize = 0;
			_playheadPosition = 0;
			_bytesLoaded = 0;
			_bitrate = 0;
			_bandwidthUpdates = 0;
			_bandwidthSum = 0;
		}	
	
		public function userBandwidth():Number
		{
			return _userBandwidth;
		}

		public function setUserBandwidth(val:Number):void
		{
			_bandwidthUpdates++;
			_bandwidthSum += val;
			_userBandwidth = val;
		}
		
		public function averageUserBandwidth():Number
		{
			return _bandwidthSum / _bandwidthUpdates;
		}
	
		public function mediaLength():Number
		{
			return _mediaLength;
		}

		public function setMediaLength(val:Number):void
		{
			_mediaLength = val;
		}
	
		public function mediaSize():Number
		{
			return _mediaSize;
		}

		public function setMediaSize(val:Number):void
		{
			_mediaSize = val;
		}
		
		public function remainingMediaSize():Number
		{
			return _mediaSize - _bytesLoaded;
		}
	
		public function playheadPosition():Number
		{
			return _playheadPosition;
		}

		public function setPlayheadPosition(val:Number):void
		{
			_playheadPosition = val;
		}
		
		public function remainingMediaLength():Number
		{
			return _mediaLength - _playheadPosition;
		}
	
		public function bytesLoaded():Number
		{
			return _bytesLoaded;
		}

		public function setBytesLoaded(val:Number):void
		{
			_bytesLoaded = val;
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
			return _bytesLoaded / mediaBitrate();
		}
		
		public function loadedMediaLengthPerSecond():Number
		{
			return _userBandwidth / mediaBitrate();
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
			_bitrate = bitrate;
		}
	
		/**
		* Function: mediaBitrate
		* Returns: bitrate of the media file (bytes/second)
		**/
		public function mediaBitrate():Number
		{
			return _bitrate || _mediaSize / _mediaLength;
		}
	}
}