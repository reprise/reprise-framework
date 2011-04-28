/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.external
{

	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	import reprise.external.AbstractResource;
	
	public class AMFResource extends AbstractResource
	{
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _netConnection:NetConnection;
		protected var _service:String;
		protected var _method:String;
		protected var _arguments:Array;
		protected var _headers:Object;
		protected var _objectEncoding:uint = 3;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function AMFResource(url:String = null, service:String = null, method:String = null, 
			args:Array = null)
		{
			super(url);
			_service = service;
			_method = method;
			_arguments = args || [];
			_headers = {};
		}
		
		public function setService(service:String):void
		{
			_service = service;
		}
		
		public function service():String
		{
			return _service;
		}
		
		public function setMethod(method:String):void
		{
			_method = method;
		}
		
		public function method():String
		{
			return _method;
		}
		
		public function setArguments(args:Array):void
		{
			_arguments = args;
		}
		
		public function arguments():Array
		{
			return _arguments;
		}
		
		public function setCredentials(userName:String, password:String):void
		{
			addHeader('Credentials', {userid:userName, password:password});
		}
		
		public function addHeader(name:String, value:Object, mustUnderstand:Boolean = false):void
		{
			_headers[name] = {value:value, mustUnderstand:mustUnderstand};
		}
		
		public function setObjectEncoding(encoding:uint):void
		{
			_objectEncoding = encoding;
		}
		
		public function objectEncoding():uint
		{
			return _objectEncoding;
		}
		
		public override function bytesLoaded() : int
		{
			return 0;
		}
		
		public override function bytesTotal() : int
		{
			return 0;
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		override protected function doLoad():void
		{
			_netConnection = new NetConnection();
			_netConnection.objectEncoding = _objectEncoding;
			for (var headerName:String in _headers)
			{
				var header:Object = _headers[headerName];
				_netConnection.addHeader(headerName, header.mustUnderstand, header.value);
			}
			_netConnection.connect(url());
			var params:Array = [(_service + '.' + _method),
				new Responder(netConnection_result, netConnection_status)];
			params = params.concat(_arguments);
			_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR,
				netConnection_securityError);
			_netConnection.addEventListener(IOErrorEvent.IO_ERROR,
				netConnection_ioError);
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS,
				netConnection_netStatus);
			_netConnection.call.apply(_netConnection, params);
		}
		
		override protected function doCancel():void
		{
			_netConnection.close();
			_netConnection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,
				netConnection_securityError);
			_netConnection.removeEventListener(IOErrorEvent.IO_ERROR,
				netConnection_ioError);
			_netConnection.removeEventListener(NetStatusEvent.NET_STATUS,
				netConnection_netStatus);
			_netConnection = null;
		}
		
		
		
		//*****************************************************************************************
		//*                                         Events                                        *
		//*****************************************************************************************
		protected function netConnection_result(data:Object):void
		{
			if (_isCancelled) return;
			_content = data;
			onData(true);
		}
		
		protected function netConnection_status(data:Object):void
		{
			if (_isCancelled) return;
			_content = data;
			onData(true);
		}
		
		protected function netConnection_securityError(e:SecurityErrorEvent):void
		{
			trace(e);
			onData(false);
		}
		
		protected function netConnection_ioError(e:IOErrorEvent):void
		{
			trace(e);
			onData(false);
		}
		
		protected function netConnection_netStatus(e:NetStatusEvent):void
		{
			if (e.info.hasOwnProperty('level') && e.info.level == 'error')
			{
				if (e.info.hasOwnProperty('code') && e.info.hasOwnProperty('details'))
				{
					trace(e.info.code + ' (' + e.info.details + ')');
				}
				onData(false);
			}
		}
	}
}