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
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class FileResource extends AbstractResource
	{
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		protected var m_loader : URLLoader;
		protected var m_requestContentType : String;
		protected var m_data : String;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function FileResource(url:String = null)
		{
			super(url);
		}
		
		public function setRequestContentType(contentType : String) : void
		{
			m_requestContentType = contentType;
		}
		
		public function data() : String
		{
			return m_data;
		}
		
		public override function content() : *
		{
			return m_loader.data;
		}
		
		public override function getBytesLoaded() : Number
		{
			return m_loader.bytesLoaded;
		}
		
		public override function getBytesTotal() : Number
		{
			return m_loader.bytesTotal;
		}
		
		
		
		/***************************************************************************
		*							protected methods							   *
		***************************************************************************/
		protected override function doLoad() : void
		{
			m_loader = new URLLoader();
			m_loader.addEventListener(
				HTTPStatusEvent.HTTP_STATUS, loader_httpStatus);
			m_loader.addEventListener(Event.COMPLETE, loader_complete);
			m_loader.load(createRequest());
			//TODO: add error handling
		}
		protected function createRequest() : URLRequest
		{
			var request : URLRequest = new URLRequest(urlByAppendingTimestamp());
			if (m_requestContentType)
			{
				request.contentType = 'text/xml; charset=utf-8';
			}
			return request;
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