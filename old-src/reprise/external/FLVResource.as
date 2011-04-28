/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.external
{
	
	import flash.net.NetStream;
	import flash.net.NetConnection;
	import flash.events.NetStatusEvent;
	
	
	public class FLVResource extends AbstractResource
	{
		
		protected var m_connection:NetConnection;
		protected var m_stream:NetStream;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function FLVResource(url:String = null)
		{
			super(url);
		}

		override public function setURL(theURL : String) : void
		{
			super.setURL(theURL);
			m_stream && cleanupStream();
			theURL && initStream();
		}

		public override function bytesTotal() : int
		{
			return m_stream.bytesTotal;
		}
		
		public override function bytesLoaded() : int
		{
			return m_stream.bytesLoaded;
		}
		
		public override function content():*
		{
			return m_stream;
		}
		
		protected override function doLoad():void
		{
			m_stream.play(url());
		}

		override protected function doCancel() : void
		{
			m_stream && cleanupStream();
		}

		override public function reset() : void
		{
			if (!m_isExecuting && m_stream)
			{
				cleanupStream();
			}
			super.reset();
		}

		protected override function checkProgress(...rest : Array) : void
		{
			if (m_stream.bytesLoaded >= m_stream.bytesTotal)
			{
				onData(true);
			}
			super.checkProgress(rest);
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

		protected function cleanupStream() : void
		{
			m_stream.close();
			m_stream.removeEventListener(NetStatusEvent.NET_STATUS, stream_status);
			m_stream.soundTransform = null;
			m_stream = null;
			m_connection.close();
			m_connection = null;
		}
		
		protected function stream_status(e:NetStatusEvent):void
		{
			if (e.info.level == 'error')
			{
				onData(false);
			}
		}
		
		public function onMetaData(info:Object):void 
		{
	        log("i metadata: duration=" + info.duration + " width=" + info.width +
			        " height=" + info.height + " framerate=" + info.framerate);
		}
		
		public function onXMPData(info:Object):void 
		{
			log("i raw XMP data:\n" + info.data);
		}
		
		public function onCuePoint(info:Object):void 
		{
			log("i cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
		}
	}
}