/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.external
{
	
	import flash.media.Sound;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import flash.utils.getDefinitionByName;
	
	
	public class MP3Resource extends AbstractResource
	{
		
		protected var m_sound:Sound;
		
		
		public function MP3Resource(url:String = null)
		{
			super(url);
		}
		
		public override function bytesTotal():int
		{
			return m_sound.bytesLoaded;
		}
		
		public override function bytesLoaded():int
		{
			return m_sound.bytesTotal;
		}
		
		public override function content():*
		{
			return m_sound;
		}
		
		protected override function doLoad():void
		{
			// asset from library
			if (m_url.indexOf('attach://') == 0)
			{
				var symbolId:String = m_url.split('//')[1];
	            try
	            {
					var pieces:Array = symbolId.split('.');
					symbolId = pieces[0];
	                var symbolClass : Class = getDefinitionByName(symbolId) as Class;
					for (var i:int = 1; i < pieces.length; i++)
					{
						symbolClass = symbolClass[pieces[i]];
					}
					m_sound = new symbolClass() as Sound;
					m_httpStatus = new HTTPStatus(200, m_url);
					onData(true);
	            } 
				catch (e : Error)
				{
					log('w Unable to use attach:// procotol! Symbol ' + symbolId + ' not found!');
					onData(false);
	            }
				return;
			}
			
			m_sound = new Sound();
			m_sound.addEventListener(IOErrorEvent.IO_ERROR, sound_ioError);
			m_sound.addEventListener(Event.COMPLETE, sound_complete);
			m_sound.load(new URLRequest(url()));
		}
		
		protected function sound_complete(e:Event):void
		{
			onData(true);
		}
		
		protected function sound_ioError(e:IOErrorEvent):void
		{
			log('w An error occured with the soundfile "' + url() + '"\n' + e);
		}
	}
}