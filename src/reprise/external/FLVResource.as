package reprise.external
{
	
	import flash.net.NetStream;
	import flash.net.NetConnection;
	import flash.events.NetStatusEvent;
	
	
	public class FLVResource extends AbstractResource
	{
		
		protected var m_connection:NetConnection;
		protected var m_stream:NetStream;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function FLVResource(url:String = null)
		{
			super(url);
			initStream();
		}
		
		public override function bytesTotal():Number
		{
			return m_stream.bytesLoaded;
		}
		
		public override function bytesLoaded():Number
		{
			return m_stream.bytesTotal;
		}
		
		public override function content():*
		{
			return m_stream;
		}
		
		
		protected function initStream():void
		{
			m_connection = new NetConnection();
			m_connection.connect(null);
			m_stream = new NetStream(m_connection);
			m_stream.bufferTime = 0;
			m_stream.client = this;
			m_stream.addEventListener(NetStatusEvent.NET_STATUS, stream_status);
		}
		
		protected override function doLoad():void
		{
			m_stream.play(url());
		}
		
		protected function stream_status(e:NetStatusEvent):void
		{
			
		}
		
		public function onMetaData(info:Object):void 
		{
	        log("i metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
		}
		
		public function onCuePoint(info:Object):void 
		{
			log("i cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
		}
	}
}