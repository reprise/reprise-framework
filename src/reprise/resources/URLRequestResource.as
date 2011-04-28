/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.resources
{
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;

	public class URLRequestResource extends ResourceBase
	{
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _requestContentType : String;
		protected var _requestMethod : String;
		protected var _requestHeaders : Array;
		protected var _requestData : Object;


		//----------------------               Public Methods               ----------------------//
		public function URLRequestResource(url:String)
		{
			super(url);
		}

		public function get requestContentType() : String
		{
			return _requestContentType;
		}

		public function set requestContentType(value : String) : void
		{
			_requestContentType = value;
		}

		public function get requestMethod() : String
		{
			return _requestMethod;
		}

		public function set requestMethod(value : String) : void
		{
			_requestMethod = value;
		}

		public function get requestHeaders() : Array
		{
			return _requestHeaders;
		}

		public function set requestHeaders(value : Array) : void
		{
			_requestHeaders = value;
		}

		public function addRequestHeader(requestHeader : URLRequestHeader) : void
		{
			_requestHeaders ||= [];
			_requestHeaders.push(requestHeader);
		}

		public function get requestData() : Object
		{
			return _requestData;
		}

		public function set requestData(value : Object) : void
		{
			_requestData = value;
		}

		//----------------------         Private / Protected Methods        ----------------------//
		protected function createRequest() : URLRequest
		{
			var request : URLRequest = new URLRequest(_url);
			if (_requestContentType)
			{
				request.contentType = _requestContentType;
			}
			if (_requestData)
			{
				request.data = _requestData;
			}
			if (_requestHeaders)
			{
				request.requestHeaders = _requestHeaders;
			}
			request.method = _requestMethod || URLRequestMethod.GET;
			return request;
		}
	}
}