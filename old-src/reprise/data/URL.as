/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.data
{ 
	public class URL
	{//----------------------       Private / Protected Properties       ----------------------//
		protected static const URL_PARSER : RegExp = new RegExp(
			'(?:' +										//match absolute path parts only if a 
														//protocol is given
				'(?P<protocol>[a-z]*(?=[:]//))' +		//match protocol
				'[:]//(?P<credentials>[^@]*(?=@))?@?' + //match user credentials
				'(?P<host>[^/:]*(?=[:/]|$))?' + 			//match host
				'[:]?(?P<port>(?<=[:])[0-9]*)?' + 		//match port
			'|)' + 										//end absolute path stuff
			'(?P<path>[^?]+)?' +						//match relative path on server
			'(?:[?](?P<query>[^#]+))?' +				//match query part
			'(?:[#](?P<anchor>.*))?'					//match anchor part
			, '');
		
		protected var _scheme : String;
		protected var _host : String = '';
		protected var _user : String;
		protected var _password : String;
		protected var _path : String;
		protected var _port : int;
		protected var _query : String;
		protected var _queryObject : Object;
		protected var _fragment : String;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function URL(urlString:String = null)
		{
			if (urlString)
			{
				parseURL(urlString);
			}
		}
		
		public function scheme() : String
		{
			return _scheme ? _scheme + '://' : null;
		}
	
		public function setScheme(val:String) : void
		{
			if (val.indexOf('://') != -1)
			{
				val = val.substr(0, val.indexOf('://'));
			}
			_scheme = val;
		}
		
		public function host() : String
		{
			return _host;
		}
	
		public function setHost(val:String) : void
		{
			_host = val;
		}
		
		public function user() : String
		{
			return _user;
		}
	
		public function setUser(val:String) : void
		{
			_user = val;
		}
		
		public function password() : String
		{
			return _password;
		}
	
		public function setPassword(val:String) : void
		{
			_password = val;
		}
		
		public function path() : String
		{
			return _path;
		}
	
		public function setPath(val:String) : void
		{
			_path = val;
		}
		
		public function port() : int
		{
			return _port;
		}
	
		public function setPort(val:int) : void
		{
			_port = val;
		}
		
		public function query() : String
		{
			return _query;
		}
	
		public function setQuery(val:String) : void
		{
			_query = val;
			_queryObject = {};
			var parts:Array = _query.split('&');
			for each (var part:String in parts)
			{
				if (!part || !part.length)
				{
					continue;
				}
				var keyValueParts:Array = part.split('=');
				_queryObject[keyValueParts[0]] = keyValueParts[1];
			}
		}
		
		public function queryObject():Object
		{
			return _queryObject;
		}
		
		public function fragment() : String
		{
			return _fragment;
		}
	
		public function setFragment(val:String) : void
		{
			_fragment = val;
		}
		
		public function isFileURL() : Boolean
		{
			return _scheme == 'file';
		}
		
		public function isAbsoluteURL() : Boolean
		{
			return _path.indexOf('/') == 0;
		}
		
		
		public function valueOf() : String
		{
			var str : String = '';
			if (_scheme)
			{
				str += _scheme + '://';
			}
			if (_user)
			{
				str += _user;
				if (_password)
				{
					str += ':' + _password;
				}
				str += '@';
			}
			if (_host)
			{
				str += _host;
				if (!isNaN(_port))
				{
					str += ':' + _port;
				}
				if (_path.charAt(0) != '/')
				{
					str += '/';
				}
			}
			if (_path)
			{
				str += _path;
			}
			if (_query)
			{
				str += '?' + _query;
			}
			if (_fragment)
			{
				str += '#' + _fragment;
			}
			return str;
		}
		
		public function toString() : String
		{
			return '[URL] ' + valueOf();
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected function parseURL(urlString : String) : void
		{
			var match : Array = URL_PARSER.exec(urlString);
			_scheme = match['protocol'];
			var credentials : Array = match['credentials'].split(':');
			_user = credentials[0];
			_password = credentials[1] || '';
			_host = match['host'];
			_port = parseInt(match['port']);
			_path = match['path'];
			setQuery(match['query']);
			_fragment = match['anchor'];
		}	
	}
}