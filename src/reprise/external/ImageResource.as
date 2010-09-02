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

	public class ImageResource extends AbstractResource
	{
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		private static const MAX_POLICYFILE_LOAD_TIME : int = 5000;

		protected var m_loader : Loader;
		protected var m_resource : DisplayObject;
		private var m_policyFileLoadTimer:Timer;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function ImageResource(url:String = null)
		{
			super(url);
		}
		
		public override function content() : *
		{
			return m_resource;
		}
		
		public function loader() : Loader
		{
			return m_loader;
		}
		
		public function bitmap(backgroundColor:Number = NaN, smoothing : Boolean = false) : BitmapData
		{
			var transparent : Boolean = false;
			if (isNaN(backgroundColor))
			{
				transparent = true;
				backgroundColor = 0;
			}
			var bmp : BitmapData = new BitmapData(m_loader.width, m_loader.height, 
				transparent, backgroundColor);
			bmp.draw(m_loader, null, null, null, null, smoothing);
			return bmp;
		}
		
		public override function bytesLoaded() : int
		{
			if (m_attachMode)
			{
				return 1;
			}
			if (!m_loader)
			{
				return 0;
			}
			return m_loader.contentLoaderInfo.bytesLoaded;
		}
		
		public override function bytesTotal() : int
		{
			if (m_attachMode)
			{
				return 1;
			}
			if (!m_loader)
			{
				return 0;
			}
			return m_loader.contentLoaderInfo.bytesTotal;
		}
		
		
		
		/***************************************************************************
		*							protected methods							   *
		***************************************************************************/	
		protected override function doLoad() : void
		{
			var useByteloader : Boolean;
			var assetBytes : ByteArray;
			// asset from library
			if (m_url.indexOf('attach://') == 0)
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
					m_resource = DisplayObject(resource);
					m_httpStatus = new HTTPStatus(200, m_url);
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

			var context : LoaderContext = new LoaderContext(m_checkPolicyFile, ApplicationDomain.currentDomain);
			m_loader = new Loader();
			m_loader.contentLoaderInfo.addEventListener(Event.INIT, loader_init);
			if (useByteloader)
			{
				m_loader.loadBytes(assetBytes, context);
				return;
			}
			m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
			m_loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, loader_httpStatus);
			m_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loader_error);
			m_loader.load(m_request, context);
		}

		protected override function doCancel() : void
		{
			if (m_loader)
			{
				if (!m_didFinishLoading)
				{
					try
					{
						m_loader.close();
					}
					catch (error : Error)
					{
						//no need to handle this error, just throw it away
					}
				}
				m_loader.unload();
			}
		}
		
		//Loader events
		protected function loader_complete(event : Event) : void
		{
			m_httpStatus = new HTTPStatus(200, m_url);
		}
		
		protected function loader_init(event : Event) : void
		{
			//check to see if we can't access even though we requested a policyFile
			if (m_checkPolicyFile && !m_loader.contentLoaderInfo.childAllowsParent)
			{
				//yep, can't access. We probably have been redirected by a CDN and need
				//to load a policyFile from the new server
				var url : String = m_loader.contentLoaderInfo.url;
				var server : String = url.substr(0, url.lastIndexOf('/') + 1);
				Security.loadPolicyFile(server + 'crossdomain.xml');
				m_policyFileLoadTimer = new Timer(50);
				m_policyFileLoadTimer.addEventListener(TimerEvent.TIMER, policyFileLoading_timer);
				m_policyFileLoadTimer.start();
				return;
			}
			m_resource = m_loader.content;
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
			if (m_loader.contentLoaderInfo.childAllowsParent)
			{
				//policyfile has been loaded: Great success!
				m_resource = m_loader.content;
				onData(true);
			}
			else if (m_policyFileLoadTimer.currentCount > MAX_POLICYFILE_LOAD_TIME / 50)
			{
				//max duration for timeout exceeded: Epic fail1
				onData(false);
			}
			else
			{
				return;
			}
			//in case of success or fail: stop timer
			m_policyFileLoadTimer.stop();
			m_policyFileLoadTimer = null;
		}
	}
}