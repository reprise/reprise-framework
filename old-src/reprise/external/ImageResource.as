/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.external 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	public class ImageResource extends URLRequestResource
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private static const MAX_POLICYFILE_LOAD_TIME : int = 5000;

		protected var _loader : Loader;
		protected var _resource : DisplayObject;
		private var _policyFileLoadTimer:Timer;

		
		//----------------------               Public Methods               ----------------------//
		public function ImageResource(url:String = null)
		{
			super(url);
		}
		
		public override function content() : *
		{
			return _resource;
		}
		
		public function loader() : Loader
		{
			return _loader;
		}
		
		public function bitmap(backgroundColor:Number = NaN, smoothing : Boolean = false) : BitmapData
		{
			var transparent : Boolean = false;
			if (isNaN(backgroundColor))
			{
				transparent = true;
				backgroundColor = 0;
			}
			var bmp : BitmapData = new BitmapData(_loader.width, _loader.height,
				transparent, backgroundColor);
			bmp.draw(_loader, null, null, null, null, smoothing);
			return bmp;
		}
		
		public override function bytesLoaded() : int
		{
			if (_attachMode)
			{
				return 1;
			}
			if (!_loader)
			{
				return 0;
			}
			return _loader.contentLoaderInfo.bytesLoaded;
		}
		
		public override function bytesTotal() : int
		{
			if (_attachMode)
			{
				return 1;
			}
			if (!_loader)
			{
				return 0;
			}
			return _loader.contentLoaderInfo.bytesTotal;
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function doLoad() : void
		{
			var useByteloader : Boolean;
			var assetBytes : ByteArray;
			// asset from library
			if (_url.indexOf('attach://') == 0)
			{
				var symbol : Class = resolveAttachSymbol();
				if (!symbol)
				{
					onData(false);
					return;
				}

				var resource : Object = new (symbol as Class)();

				if (resource is ByteArray)
				{
					useByteloader = true;
					assetBytes = ByteArray(resource);
				}
				else if (resource.hasOwnProperty('movieClipData'))
				{
					useByteloader = true;
					assetBytes = ByteArray(resource['movieClipData']);
				}
				else if (resource is DisplayObject)
				{
					_resource = DisplayObject(resource);
					_httpStatus = new HTTPStatus(200, _url);
					onData(true);
					return;
				}
				else
				{
					logUnsupportedTypeMessage(symbol);
					onData(false);
					return;
				}
			}

			var context : LoaderContext = new LoaderContext(_checkPolicyFile, ApplicationDomain.currentDomain);
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.INIT, loader_init);
			if (useByteloader)
			{
				_loader.loadBytes(assetBytes, context);
				return;
			}
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
			_loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, loader_httpStatus);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loader_error);
			_loader.load(createRequest(), context);
		}

		protected override function doCancel() : void
		{
			if (_loader)
			{
				if (!_didFinishLoading)
				{
					try
					{
						_loader.close();
					}
					catch (error : Error)
					{
						//no need to handle this error, just throw it away
					}
				}
				_loader.unload();
			}
		}
		
		//Loader events
		protected function loader_complete(event : Event) : void
		{
			_httpStatus = new HTTPStatus(200, _url);
		}
		
		protected function loader_init(event : Event) : void
		{
			//check to see if we can't access even though we requested a policyFile
			if (_checkPolicyFile && !_loader.contentLoaderInfo.childAllowsParent)
			{
				//yep, can't access. We probably have been redirected by a CDN and need
				//to load a policyFile from the new server
				var url : String = _loader.contentLoaderInfo.url;
				var server : String = url.substr(0, url.lastIndexOf('/') + 1);
				Security.loadPolicyFile(server + 'crossdomain.xml');
				_policyFileLoadTimer = new Timer(50);
				_policyFileLoadTimer.addEventListener(TimerEvent.TIMER, policyFileLoading_timer);
				_policyFileLoadTimer.start();
				return;
			}
			_resource = _loader.content;
			onData(true);
		}
		
		protected function loader_error(event : IOErrorEvent) : void
		{
			//TODO: find a way to support timeouts
//			else if (errorCode == 'LoadNeverCompleted')
//			{
//				notifyComplete(false, ResourceEvent.ERROR_TIMEOUT);
//				return;
//			}
			
			onData(false);
		}

		private function policyFileLoading_timer(event:TimerEvent):void
		{
			if (_loader.contentLoaderInfo.childAllowsParent)
			{
				//policyfile has been loaded: Great success!
				_resource = _loader.content;
				onData(true);
			}
			else if (_policyFileLoadTimer.currentCount > MAX_POLICYFILE_LOAD_TIME / 50)
			{
				//max duration for timeout exceeded: Epic fail1
				onData(false);
			}
			else
			{
				return;
			}
			//in case of success or fail: stop timer
			_policyFileLoadTimer.stop();
			_policyFileLoadTimer = null;
		}
	}
}