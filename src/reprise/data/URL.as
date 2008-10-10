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
			return m_scheme;
		}
	
		public function setScheme(val:String) : void
		{
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
			return m_scheme == 'file://';
		}
		
		public function isAbsoluteURL() : Boolean
		{
			return m_path.indexOf('/') == 0;
		}
		
		
		public function valueOf() : String
		{
			var str : String = '';
			if (m_scheme != null )
			{
				str += m_scheme;
			}
			if (m_user != null && m_password != null)
			{
				str += m_user + ':' + m_password + '@';
			}
			if (m_host != null)
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
			if (m_path != null)
			{
				str += m_path;
			}
			if (m_query != null)
			{
				str += '?' + m_query;
			}
			if (m_fragment != null)
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
			var schemeEndIndex : Number = urlString.indexOf('://');
			if (schemeEndIndex != -1)
			{
				m_scheme = urlString.substring(0, schemeEndIndex + 3);
				urlString = urlString.substr(schemeEndIndex + 3);
			}
			
			var networkLocationEndIndex : Number = urlString.indexOf('/');
			if (networkLocationEndIndex > 0)
			{
				var networkLocation : String = 
					urlString.substring(0, networkLocationEndIndex);
				urlString = urlString.substr(networkLocationEndIndex);
				var hostParts : Array;
			
				var networkLocationParts : Array = m_host.split('@');
				if (networkLocationParts.length == 2)
				{
					var credentialParts : Array = networkLocationParts[0].split(':');
	
					m_user = credentialParts[0];			
					if (credentialParts.length == 2)
					{
						m_password = credentialParts[1];
					}
				
					hostParts = networkLocationParts[1].split(':');
					m_host = hostParts[0];		
					if (hostParts.length == 2)
					{
						m_port = parseInt(hostParts[1]);
					}
				}
				else
				{
					hostParts = networkLocation.split(':');
					m_host = hostParts[0];
					if (hostParts.length == 2)
					{
						m_port = parseInt(hostParts[1]);
					}
				}
			}
			
			var queryStartIndex : Number = urlString.indexOf('?');		
			if (queryStartIndex != -1)
			{
				var query : String = urlString.substring(queryStartIndex + 1);
				var queryParts : Array = query.split('#');
				setQuery(queryParts[0]);
				m_fragment = queryParts[1];
				m_path = urlString.substring(0, queryStartIndex);
			}
			else
			{
				var pathParts : Array = urlString.split('#');
				m_path = pathParts[0];
				if (pathParts.length == 2)
				{
					m_fragment = pathParts[1];
				}
			}
		}	
	}
}