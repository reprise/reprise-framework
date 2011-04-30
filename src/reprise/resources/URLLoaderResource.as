/*
* Copyright (c) 2006-2011 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.resources
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.utils.ByteArray;

	public class URLLoaderResource extends URLRequestResource
	{
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _loader : URLLoader;
		protected var _data : String;
		protected var _dataFormat : String;
		
		
		//----------------------               Public Methods               ----------------------//
		public function URLLoaderResource(url:String = null)
		{
			super(url);
		}
		
		public function data() : String
		{
			return _data;
		}
		
		public override function content() : *
		{
			return _loader.data;
		}

		public function setDataFormat(format : String) : void
		{
			_dataFormat = format;
		}

		public override function get bytesLoaded() : int
		{
			if (_attachMode)
			{
				return 1;
			}
			if (!_loader)
			{
				return 0;
			}
			return _loader.bytesLoaded;
		}

		public override function get bytesTotal() : int
		{
			if (_attachMode)
			{
				return 1;
			}
			if (!_loader)
			{
				return 0;
			}
			return _loader.bytesTotal;
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function doLoad() : void
		{
			// asset from library
			if (_url.indexOf('attach://') === 0)
			{
				var symbol : Class = resolveAttachSymbol();
				if (!symbol)
				{
					onData(false);
					return;
				}
				var binaryObject : Object = new symbol();
				if (!(binaryObject is ByteArray))
				{
					log ('w ' + createUnsupportedTypeMessage(symbol));
					onData(false);
					return;
				}
				_data = ByteArray(binaryObject).toString();
				onData(true);
				return;
			}
			_loader = new URLLoader();
			_dataFormat && (_loader.dataFormat = _dataFormat);
			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, loader_httpStatus);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioError);
			_loader.addEventListener(Event.COMPLETE, loader_complete);
			_loader.load(createRequest());
			//TODO: add error handling
		}

		protected override function doCancel() : void
		{
			if (!_isExecuting)
			{
				return;
			}
			_loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, loader_httpStatus);
			_loader.removeEventListener(Event.COMPLETE, loader_complete);
			_loader.close();
			_loader = null;
		}

		protected function loader_httpStatus(event : HTTPStatusEvent) : void
		{
			setHttpStatusCode(event.status);
		}

		private function loader_ioError(event : IOErrorEvent) : void
		{
			_ioErrorOccured = true;
			_ioErrorText = event.text;
			onData(false);
		}

		protected function loader_complete(event : Event) : void
		{
			_data = _loader.data;
			_loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, loader_httpStatus);
			_loader.removeEventListener(Event.COMPLETE, loader_complete);
			onData(true);
		}
	}
}
