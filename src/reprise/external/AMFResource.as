//
//  AMFResource.as
//
//  Created by Marc Bauer on 2009-04-23.
//  Copyright (c) 2009 Fork Unstable Media GmbH. All rights reserved.
//

package reprise.external
{

	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	import reprise.external.AbstractResource;
	
	public class AMFResource extends AbstractResource
	{
		
		//*****************************************************************************************
		//*                                  Protected Properties                                 *
		//*****************************************************************************************
		protected var m_netConnection:NetConnection;
		protected var m_service:String;
		protected var m_method:String;
		protected var m_arguments:Array;
		protected var m_headers:Object;
		protected var m_objectEncoding:uint = 3;
		
		
		
		//*****************************************************************************************
		//*                                     Public Methods                                    *
		//*****************************************************************************************
		public function AMFResource(url:String = null, service:String = null, method:String = null, 
			args:Array = null)
		{
			super(url);
			m_service = service;
			m_method = method;
			m_arguments = args || [];
			m_headers = {};
		}
		
		public function setService(service:String):void
		{
			m_service = service;
		}
		
		public function service():String
		{
			return m_service;
		}
		
		public function setMethod(method:String):void
		{
			m_method = method;
		}
		
		public function method():String
		{
			return m_method;
		}
		
		public function setArguments(args:Array):void
		{
			m_arguments = args;
		}
		
		public function arguments():Array
		{
			return m_arguments;
		}
		
		public function setCredentials(userName:String, password:String):void
		{
			addHeader('Credentials', {userid:userName, password:password});
		}
		
		public function addHeader(name:String, value:Object, mustUnderstand:Boolean = false):void
		{
			m_headers[name] = {value:value, mustUnderstand:mustUnderstand};
		}
		
		public function setObjectEncoding(encoding:uint):void
		{
			m_objectEncoding = encoding;
		}
		
		public function objectEncoding():uint
		{
			return m_objectEncoding;
		}
		
		public override function bytesLoaded() : Number
		{
			return 0;
		}
		
		public override function bytesTotal() : Number
		{
			return 0;
		}
		
		
		
		//*****************************************************************************************
		//*                                   Protected Methods                                   *
		//*****************************************************************************************
		override protected function doLoad():void
		{
			m_netConnection = new NetConnection();
			m_netConnection.objectEncoding = m_objectEncoding;
			for (var headerName:String in m_headers)
			{
				var header:Object = m_headers[headerName];
				m_netConnection.addHeader(headerName, header.mustUnderstand, header.value);
			}
			m_netConnection.connect(url());
			var params:Array = [(m_service + '.' + m_method), 
				new Responder(netConnection_result, netConnection_status)];
			params = params.concat(m_arguments);
			m_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, 
				netConnection_securityError);
			m_netConnection.addEventListener(IOErrorEvent.IO_ERROR, 
				netConnection_ioError);
			m_netConnection.call.apply(m_netConnection, params);
		}
		
		override protected function doCancel():void
		{
			m_netConnection.close();
			m_netConnection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, 
				netConnection_securityError);
			m_netConnection.removeEventListener(IOErrorEvent.IO_ERROR, 
				netConnection_ioError);
			m_netConnection = null;
		}
		
		
		
		//*****************************************************************************************
		//*                                         Events                                        *
		//*****************************************************************************************
		protected function netConnection_result(data:Object):void
		{
			if (m_isCancelled) return;
			m_content = data;
			onData(true);
		}
		
		protected function netConnection_status(data:Object):void
		{
			if (m_isCancelled) return;
			m_content = data;
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
	}
}