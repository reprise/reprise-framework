/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.media
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import reprise.external.IResource;
	import reprise.media.AbstractPlayer;	

	public class SWFPlayer extends AbstractPlayer
	{
		
		protected var _loader:Loader;
		protected var _host:DisplayObjectContainer;
		protected var _soundTransform:SoundTransform;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function SWFPlayer(resource:IResource, host:DisplayObjectContainer)
		{
			super();
			_host = host;
			setResource(resource);
		}
		
		public override function setResource(resource:IResource):void
		{
			super.setResource(resource);
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
			_loader.contentLoaderInfo.addEventListener(
				HTTPStatusEvent.HTTP_STATUS, loader_httpStatus);
			_loader.contentLoaderInfo.addEventListener(Event.INIT, loader_init);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loader_error);
			_soundTransform = new SoundTransform(1.0, 0.0);
			_host.addChild(_loader);
		}
		
		public override function bytesLoaded():Number
		{
			return _loader.contentLoaderInfo.bytesLoaded;
		}

		public override function bytesTotal():Number
		{
			return _loader.contentLoaderInfo.bytesTotal;
		}
		
		public override function position():Number
		{
			return _loader.content ? frameToTime(MovieClip(_loader.content).currentFrame) : 0;
		}
		
		public override function duration():Number
		{
			return _loader.content ? frameToTime(MovieClip(_loader.content).totalFrames) : 0;
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function doStop():void 
		{
			MovieClip(_loader.content).stop();
		}
		
		protected override function doPause():void 
		{
			doStop();
		}
		
		protected override function doPlay():void 
		{
			if (!_loader.content)
			{
				return;
			}
			MovieClip(_loader.content).gotoAndPlay(timeToFrame(position()));
		}
		
		protected override function doSeek(offset:Number):void 
		{
			offset = timeToFrame(offset);
			if (!isPlaying())
			{
				MovieClip(_loader.content).gotoAndStop(offset);
			}
			else
			{
				MovieClip(_loader.content).gotoAndPlay(offset);
			}
		}
		
		protected override function doSetVolume(vol:Number):void 
		{
			_soundTransform.volume = vol;
			if (_loader.content)
			{
				MovieClip(_loader.content).soundTransform = _soundTransform;
			}
		}
		
		protected override function doLoad():void 
		{
			_loader.load(new URLRequest(_source.url()));
		}
		
		protected override function doUnload():void 
		{
			_loader.unload();
		}
		
		protected override function setState(state:uint):void
		{
			super.setState(state);
			if (!_loader.content)
			{
				return;
			}
			if (state != AbstractPlayer.STATE_PLAYING)
			{
				MovieClip(_loader.content).removeEventListener(Event.ENTER_FRAME,
					content_enterFrame);
			}
			else
			{
				MovieClip(_loader.content).addEventListener(Event.ENTER_FRAME,
					content_enterFrame);
			}
		}
		
		protected function frameToTime(frame:Number):Number
		{
			return frame / framerate();
		}
		
		protected function timeToFrame(time:Number):Number
		{
			return Math.round(time * framerate());
		}
		
		protected function framerate():uint
		{
			return _loader.content ? _loader.contentLoaderInfo.frameRate : 25;
		}
		
		
		
		/***************************************************************************
		*									events								   *
		***************************************************************************/
		protected function loader_complete(e:Event):void
		{
			
		}
		
		protected function loader_httpStatus(e:HTTPStatusEvent):void
		{
			
		}
		
		protected function loader_init(e:Event):void
		{
			MovieClip(_loader.content).stop();
			MovieClip(_loader.content).addEventListener(Event.ENTER_FRAME, content_enterFrame);
			if (state() == AbstractPlayer.STATE_PLAYING)
			{
				MovieClip(_loader.content).addEventListener(Event.ENTER_FRAME,
					content_enterFrame);
			}
		}
		
		protected function loader_error(e:IOErrorEvent):void
		{
			log('w Something went wrong while loading file ' + _source.url());
		}
		
		protected function content_enterFrame(e:Event):void
		{
			if (MovieClip(_loader.content).currentFrame == MovieClip(_loader.content).totalFrames)
			{
				mediaReachedEnd();
			}
		}
	}
}