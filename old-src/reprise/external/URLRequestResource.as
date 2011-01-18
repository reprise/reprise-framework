/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.external
{
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	public class URLRequestResource extends AbstractResource
	{
		/*******************************************************************************************
		 *								protected/ private properties							   *
		 *******************************************************************************************/
		protected var m_request : URLRequest;
		protected var m_requestContentType : String;
		protected var m_requestMethod : String;
		protected var m_requestData : Object;


		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function URLRequestResource(url:String)
		{
			super(url);
		}

		public function setRequestContentType(contentType : String) : void
		{
			m_requestContentType = contentType;
		}

		public function setRequestMethod(method : String) : void
		{
			m_requestMethod = method;
		}

		public function setRequestData(data : Object) : void
		{
			m_requestData = data;
		}

		/*******************************************************************************************
		 *								protected/ private methods								 *
		 *******************************************************************************************/
		protected function createRequest() : URLRequest
		{
			var request : URLRequest = new URLRequest(urlByAppendingTimestamp());
			if (m_requestContentType)
			{
				request.contentType = m_requestContentType;
			}
			if (m_requestData)
			{
				request.data = m_requestData;
			}
			request.method = m_requestMethod || URLRequestMethod.GET;
			return request;
		}
	}
}