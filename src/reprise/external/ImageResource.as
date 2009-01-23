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

package reprise.external 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;	
	import flash.utils.getDefinitionByName;

	public class ImageResource extends AbstractResource
	{
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		protected var m_loader : Loader;
		protected var m_resource : DisplayObject;
		protected var m_attachMode : Boolean;

		
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
		
		public override function bytesLoaded() : Number
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
		
		public override function bytesTotal() : Number
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
			// asset from library
			if (m_url.indexOf('attach://') == 0)
			{
				var symbolId:String = m_url.split('//')[1];
				m_attachMode = true;
	            try
	            {
	                var symbolClass : Class = getDefinitionByName(symbolId) as Class;
					m_resource = new symbolClass() as DisplayObject;
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
			
			m_loader = new Loader();
			m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
			m_loader.contentLoaderInfo.addEventListener(
				HTTPStatusEvent.HTTP_STATUS, loader_httpStatus);
			m_loader.contentLoaderInfo.addEventListener(Event.INIT, loader_init);
			m_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loader_error);
			var context : LoaderContext = new LoaderContext(m_checkPolicyFile, ApplicationDomain.currentDomain);
			m_loader.load(m_request, context);

		}
		
		protected override function doCancel() : void
		{
			if (m_loader)
			{
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
	}
}