package reprise.external
{
	
	import flash.media.Sound;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	
	
	public class MP3Resource extends AbstractResource
	{
		
		protected var m_sound:Sound;
		
		
		public function MP3Resource(url:String = null)
		{
			super(url);
			m_sound = new Sound();
			m_sound.addEventListener(IOErrorEvent.IO_ERROR, sound_ioError);
			m_sound.addEventListener(Event.COMPLETE, sound_complete);
		}
		
		public override function getBytesTotal():Number
		{
			return m_sound.bytesLoaded;
		}
		
		public override function getBytesLoaded():Number
		{
			return m_sound.bytesTotal;
		}
		
		public override function content():*
		{
			return m_sound;
		}
		
		
		
		protected override function doLoad():void
		{
			m_sound.load(new URLRequest(url()));
		}
		
		protected function sound_complete(e:Event):void
		{
			onData(true);
		}
		
		protected function sound_ioError(e:IOErrorEvent):void
		{
			trace('An error occured with the soundfile "' + url() + '"\n' + e);
		}
	}
}