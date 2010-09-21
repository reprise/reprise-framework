/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.external 
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.net.URLLoader;
	import flash.utils.ByteArray;

	public class URLLoaderResource extends URLRequestResource
	{
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		protected var m_loader : URLLoader;
		protected var m_data : String;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function URLLoaderResource(url:String = null)
		{
			super(url);
		}
		
		public function data() : String
		{
			return m_data;
		}
		
		public override function content() : *
		{
			return m_loader.data;
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
			return m_loader.bytesLoaded;
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
			return m_loader.bytesTotal;
		}
		
		
		
		/***************************************************************************
		*							protected methods							   *
		***************************************************************************/
		protected override function doLoad() : void
		{
			// asset from library
			if (m_url.indexOf('attach://') == 0)
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
					logUnsupportedTypeMessage(symbol);
					onData(false);
					return;
				}
				m_data = ByteArray(binaryObject).toString();
				onData(true);
				return;
			}
			m_loader = new URLLoader();
			m_loader.addEventListener(
				HTTPStatusEvent.HTTP_STATUS, loader_httpStatus);
			m_loader.addEventListener(Event.COMPLETE, loader_complete);
			m_loader.load(createRequest());
			//TODO: add error handling
		}
		
		protected override function doCancel() : void
		{
			m_loader.removeEventListener(
				HTTPStatusEvent.HTTP_STATUS, loader_httpStatus);
			m_loader.removeEventListener(Event.COMPLETE, loader_complete);
			m_loader.load(null);
			m_loader = null;
		}	
		
		// LoadVars event	
		protected function loader_complete(event : Event) : void
		{
			m_data = m_loader.data;
			onData(true);
		}
	}
}