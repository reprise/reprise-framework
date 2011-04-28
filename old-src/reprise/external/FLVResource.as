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
		
		protected var _connection:NetConnection;
		protected var _stream:NetStream;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function FLVResource(url:String = null)
		{
			super(url);
		}

		override public function setURL(theURL : String) : void
		{
			super.setURL(theURL);
			_stream && cleanupStream();
			theURL && initStream();
		}

		public override function bytesTotal() : int
		{
			return _stream.bytesTotal;
		}
		
		public override function bytesLoaded() : int
		{
			return _stream.bytesLoaded;
		}
		
		public override function content():*
		{
			return _stream;
		}
		
		protected override function doLoad():void
		{
			_stream.play(url());
		}

		override protected function doCancel() : void
		{
			_stream && cleanupStream();
		}

		override public function reset() : void
		{
			if (!_isExecuting && _stream)
			{
				cleanupStream();
			}
			super.reset();
		}

		protected override function checkProgress(...rest : Array) : void
		{
			if (_stream.bytesLoaded >= _stream.bytesTotal)
			{
				onData(true);
			}
			super.checkProgress(rest);
		}

		protected function initStream():void
		{
			_connection = new NetConnection();
			_connection.connect(null);
			_stream = new NetStream(_connection);
			_stream.bufferTime = 0;
			_stream.client = this;
			_stream.addEventListener(NetStatusEvent.NET_STATUS, stream_status);
		}

		protected function cleanupStream() : void
		{
			_stream.close();
			_stream.removeEventListener(NetStatusEvent.NET_STATUS, stream_status);
			_stream.soundTransform = null;
			_stream = null;
			_connection.close();
			_connection = null;
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