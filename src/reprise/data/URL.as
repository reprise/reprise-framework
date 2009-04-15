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

package reprise.data
{ 
	public class URL
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static const URL_PARSER : RegExp = new RegExp(
			'(?:' +										//match absolute path parts only if a 
														//protocol is given
				'(?P<protocol>[a-z]*(?=[:]//))' +		//match protocol
				'[:]//(?P<credentials>[^@]*(?=@))?@?' + //match user credentials
				'(?P<host>[^/:]*(?=[:/]))?' + 			//match host
				'[:]?(?P<port>(?<=[:])[0-9]*)?' + 		//match port
			'|)' + 										//end absolute path stuff
			'(?P<path>[^?]+)?' +						//match relative path on server
			'(?:[?](?P<query>[^#]+))?' +				//match query part
			'(?:[#](?P<anchor>.*))?'					//match anchor part
			, '');
		
		protected var m_scheme : String;
		protected var m_host : String = '';
		protected var m_user : String;
		protected var m_password : String;
		protected var m_path : String;
		protected var m_port : Number;
		protected var m_query : String;
		protected var m_queryObject : Object;
		protected var m_fragment : String;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function URL(urlString:String = null)
		{
			if (urlString)
			{
				parseURL(urlString);
			}
		}
		
		public function scheme() : String
		{
			return m_scheme ? m_scheme + '://' : null;
		}
	
		public function setScheme(val:String) : void
		{
			if (val.indexOf('://') != -1)
			{
				val = val.substr(0, val.indexOf('://'));
			}
			m_scheme = val;
		}
		
		public function host() : String
		{
			return m_host;
		}
	
		public function setHost(val:String) : void
		{
			m_host = val;
		}
		
		public function user() : String
		{
			return m_user;
		}
	
		public function setUser(val:String) : void
		{
			m_user = val;
		}
		
		public function password() : String
		{
			return m_password;
		}
	
		public function setPassword(val:String) : void
		{
			m_password = val;
		}
		
		public function path() : String
		{
			return m_path;
		}
	
		public function setPath(val:String) : void
		{
			m_path = val;
		}
		
		public function port() : Number
		{
			return m_port;
		}
	
		public function setPort(val:Number) : void
		{
			m_port = val;
		}
		
		public function query() : String
		{
			return m_query;
		}
	
		public function setQuery(val:String) : void
		{
			m_query = val;
			m_queryObject = {};
			var parts:Array = m_query.split('&');
			for each (var part:String in parts)
			{
				if (!part || !part.length)
				{
					continue;
				}
				var keyValueParts:Array = part.split('=');
				m_queryObject[keyValueParts[0]] = keyValueParts[1];
			}
		}
		
		public function queryObject():Object
		{
			return m_queryObject;
		}
		
		public function fragment() : String
		{
			return m_fragment;
		}
	
		public function setFragment(val:String) : void
		{
			m_fragment = val;
		}
		
		public function isFileURL() : Boolean
		{
			return m_scheme == 'file';
		}
		
		public function isAbsoluteURL() : Boolean
		{
			return m_path.indexOf('/') == 0;
		}
		
		
		public function valueOf() : String
		{
			var str : String = '';
			if (m_scheme)
			{
				str += m_scheme + '://';
			}
			if (m_user)
			{
				str += m_user;
				if (m_password)
				{
					str += ':' + m_password;
				}
				str += '@';
			}
			if (m_host)
			{
				str += m_host;
				if (!isNaN(m_port))
				{
					str += ':' + m_port;
				}
				if (m_path.charAt(0) != '/')
				{
					str += '/';
				}
			}
			if (m_path)
			{
				str += m_path;
			}
			if (m_query)
			{
				str += '?' + m_query;
			}
			if (m_fragment)
			{
				str += '#' + m_fragment;
			}
			return str;
		}
		
		public function toString() : String
		{
			return '[URL] ' + valueOf();
		}
		
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function parseURL(urlString : String) : void
		{
			var match : Array = URL_PARSER.exec(urlString);
			m_scheme = match['protocol'];
			var credentials : Array = match['credentials'].split(':');
			m_user = credentials[0];
			m_password = credentials[1] || '';
			m_host = match['host'];
			m_port = parseInt(match['port']);
			m_path = match['path'];
			setQuery(match['query']);
			m_fragment = match['anchor'];
		}	
	}
}