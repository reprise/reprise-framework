/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.media
{
	import reprise.external.IResource;
	import reprise.external.MP3Resource;
	import reprise.media.AbstractPlayer;

	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;

	public class MP3Player extends AbstractPlayer
	{
		
		protected var _sound:Sound;
		protected var _soundTransform:SoundTransform;
		protected var _soundChannel:SoundChannel;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function MP3Player(resource:IResource)
		{
			super();
			setResource(resource);
			_soundTransform = new SoundTransform(1.0, 0.0);
		}

		public override function bytesLoaded():Number
		{
			return _sound ? _sound.bytesLoaded : 0;
		}

		public override function bytesTotal():Number
		{
			return _sound ? _sound.bytesTotal : 0;
		}
		
		public override function isBuffered():Boolean
		{
			return _sound
				? !_sound.isBuffering && super.isBuffered()
				: false;
		}
		
		public override function position():Number
		{
			if (!_sound) return 0;
			if (_soundChannel)
			{
				return _soundChannel.position / 1000;
			}
			return _recentPosition;
		}
		
		public override function duration():Number
		{
			if (!_sound) return 0;
			return _sound.length / (_sound.bytesLoaded / _sound.bytesTotal) / 1000;
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function doLoad():void
		{
			_source.execute();
			_sound = Sound(MP3Resource(_source).content());
			_sound.addEventListener(Event.ID3, sound_id3);
		}

		protected override function doUnload():void
		{
			try
			{
				_sound.close();
			}
			catch (e:Error)
			{
				log('w ' + e);
			}
		}
		
		protected override function doPlay():void
		{
			if (_soundChannel)
			{
				_soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundChannel_complete);
			}
			_soundChannel = _sound.play(_recentPosition * 1000, 0, _soundTransform);
			_soundChannel.addEventListener(Event.SOUND_COMPLETE, soundChannel_complete);
		}

		protected override function doPause():void
		{
			_soundChannel.stop();
		}

		protected override function doStop():void
		{
			_soundChannel.stop();
		}

		protected override function doSeek(offset:Number):void
		{
			if (!isPlaying())
			{
				_recentPosition = offset;
				return;
			}
			pause();
			_recentPosition = offset;
			play();
		}
		
		protected override function doSetVolume(vol:Number):void
		{
			_soundTransform.volume = vol;
			if (_soundChannel)
			{
				_soundChannel.soundTransform = _soundTransform;
			}
		}
		
		protected function soundChannel_complete(e:Event):void
		{
			mediaReachedEnd();
		}
		
		protected function sound_id3(e:Event):void
		{
			log('--------------------- ID3 ---------------------');
			for (var key:String in _sound.id3)
			{
				log(key + ' - ' + _sound.id3[key]);
			}
			//_duration = _sound.id3.TIME;
			log(_sound.id3.TIME);
			log('--------------------- /ID3 ---------------------');
		}
	}
}