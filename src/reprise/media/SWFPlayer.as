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
	
	import reprise.external.IResource;
	import reprise.media.AbstractPlayer;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.display.MovieClip;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.display.DisplayObjectContainer;
	
	
	public class SWFPlayer extends AbstractPlayer
	{
		
		protected var m_loader:Loader;
		protected var m_host:DisplayObjectContainer;
		protected var m_soundTransform:SoundTransform;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function SWFPlayer(resource:IResource, host:DisplayObjectContainer)
		{
			super();
			m_host = host;
			setResource(resource);
		}
		
		public override function setResource(resource:IResource):void
		{
			super.setResource(resource);
			m_loader = new Loader();
			m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
			m_loader.contentLoaderInfo.addEventListener(
				HTTPStatusEvent.HTTP_STATUS, loader_httpStatus);
			m_loader.contentLoaderInfo.addEventListener(Event.INIT, loader_init);
			m_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loader_error);
			m_soundTransform = new SoundTransform(1.0, 0.0);
			m_host.addChild(m_loader);
		}
		
		public override function bytesLoaded():Number
		{
			return m_loader.contentLoaderInfo.bytesLoaded;
		}

		public override function bytesTotal():Number
		{
			return m_loader.contentLoaderInfo.bytesTotal;
		}
		
		public override function position():Number
		{
			return m_loader.content ? frameToTime(MovieClip(m_loader.content).currentFrame) : 0;
		}
		
		public override function duration():Number
		{
			return m_loader.content ? frameToTime(MovieClip(m_loader.content).totalFrames) : 0;
		}
		
		
		
		/***************************************************************************
		*							protected methods							   *
		***************************************************************************/
		protected override function doStop():void 
		{
			MovieClip(m_loader.content).stop();
		}
		
		protected override function doPause():void 
		{
			doStop();
		}
		
		protected override function doPlay():void 
		{
			if (!m_loader.content)
			{
				return;
			}
			MovieClip(m_loader.content).gotoAndPlay(timeToFrame(position()));
		}
		
		protected override function doSeek(offset:Number):void 
		{
			offset = timeToFrame(offset);
			if (!isPlaying())
			{
				MovieClip(m_loader.content).gotoAndStop(offset);
			}
			else
			{
				MovieClip(m_loader.content).gotoAndPlay(offset);
			}
		}
		
		protected override function doSetVolume(vol:Number):void 
		{
			m_soundTransform.volume = vol;
			if (m_loader.content)
			{
				MovieClip(m_loader.content).soundTransform = m_soundTransform;
			}
		}
		
		protected override function doLoad():void 
		{
			m_loader.load(new URLRequest(m_source.url()));
		}
		
		protected override function doUnload():void 
		{
			m_loader.unload();
		}
		
		protected override function setState(state:uint):void
		{
			super.setState(state);
			if (!m_loader.content)
			{
				return;
			}
			if (state != AbstractPlayer.STATE_PLAYING)
			{
				MovieClip(m_loader.content).removeEventListener(Event.ENTER_FRAME, 
					content_enterFrame);
			}
			else
			{
				MovieClip(m_loader.content).addEventListener(Event.ENTER_FRAME, 
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
			return m_loader.content ? m_loader.contentLoaderInfo.frameRate : 25;
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
			MovieClip(m_loader.content).stop();
			MovieClip(m_loader.content).addEventListener(Event.ENTER_FRAME, content_enterFrame);
			if (state() == AbstractPlayer.STATE_PLAYING)
			{
				MovieClip(m_loader.content).addEventListener(Event.ENTER_FRAME, 
					content_enterFrame);
			}
		}
		
		protected function loader_error(e:IOErrorEvent):void
		{
			log('w Something went wrong while loading file ' + m_source.url());
		}
		
		protected function content_enterFrame(e:Event):void
		{
			if (MovieClip(m_loader.content).currentFrame == MovieClip(m_loader.content).totalFrames)
			{
				mediaReachedEnd();
			}
		}
	}
}