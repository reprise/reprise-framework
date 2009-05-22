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
	public class HTTPStatus
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_statusCode : int;
		protected var m_description : String;
		protected	var m_url : String;
		protected var m_isError : Boolean;
		
		
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		// for future versions of HTTP
		public static const HTTP_STATUS_CONTINUE					: int		= 100;
		public static const HTTP_STATUS_SWITCHING_PROTOCOLS			: int		= 101;
		                                                    
		// informational states                             
		public static const HTTP_STATUS_OK							: int		= 200;
		public static const HTTP_STATUS_CREATED						: int		= 201;
		public static const HTTP_STATUS_ACCEPTED					: int		= 202;
		public static const HTTP_STATUS_NON_AUTH_INFORMATION		: int		= 203;
		public static const HTTP_STATUS_NO_CONTENT					: int		= 204;
		public static const HTTP_STATUS_RESET_CONTENT				: int		= 205;
		public static const HTTP_STATUS_PARTIAL_CONTENT				: int		= 206;
				                                            
		// redirection                                      
		public static const HTTP_STATUS_MULTIPLE_CHOICES			: int		= 300;
		public static const HTTP_STATUS_MOVED_PERMANENTLY			: int		= 301;
		public static const HTTP_STATUS_MOVED_TEMPORARILY			: int		= 302;
		public static const HTTP_STATUS_SEE_OTHER					: int		= 303;
		public static const HTTP_STATUS_NOT_MODIFIED				: int		= 304;
		public static const HTTP_STATUS_USE_PROXY					: int		= 305;
		// 306 is reserved but currently not used           
		public static const HTTP_STATUS_TEMPORARY_REDIRECT			: int		= 307;			
		                                                    
		// client error                                     
		public static const HTTP_STATUS_BAD_REQUEST					: int		= 400;
		public static const HTTP_STATUS_UNAUTHORIZED				: int		= 401;
		public static const HTTP_STATUS_PAYMENT_REQUIRED			: int		= 402;
		public static const HTTP_STATUS_FORBIDDEN					: int		= 403;
		public static const HTTP_STATUS_NOT_FOUND					: int		= 404;
		public static const HTTP_STATUS_METHOD_NOT_ALLOWED			: int		= 405;
		public static const HTTP_STATUS_NOT_ACCEPTABLE				: int		= 406;
		public static const HTTP_STATUS_PROXY_AUTH_REQUIRED			: int		= 407;
		public static const HTTP_STATUS_REQUEST_TIMEOUT				: int		= 408;
		public static const HTTP_STATUS_CONFLICT					: int		= 409;
		public static const HTTP_STATUS_GONE						: int		= 410;
		public static const HTTP_STATUS_LENGTH_REQUIRED				: int		= 411;
		public static const HTTP_STATUS_PRECONDITION_FAILED			: int		= 412;
		public static const HTTP_STATUS_REQUEST_ENTITY_TOO_LARGE	: int		= 413;
		public static const HTTP_STATUS_REQUEST_URL_TOO_LONG		: int		= 414;
		public static const HTTP_STATUS_UNSUPPORTED_MEDIA_TYPE		: int		= 415;
		public static const HTTP_STATUS_REQ_RANGE_NOT_SATISFIABLE	: int		= 416;
		public static const HTTP_STATUS_EXPECTATION_FAILED			: int		= 417;
		
		// server errors
		public static const HTTP_STATUS_INTERNAL_SERVER_ERROR		: int		= 500;
		public static const HTTP_STATUS_NOT_IMPLEMENTED				: int		= 501;
		public static const HTTP_STATUS_BAD_GATEWAY					: int		= 502;
		public static const HTTP_STATUS_SERVICE_UNAVAILABLE			: int		= 503;
		public static const HTTP_STATUS_GATEWAY_TIMEOUT				: int		= 504;
		public static const HTTP_STATUS_HTTP_VERSION_NOT_SUPPORTED	: int		= 505;
		
		public static var g_cancelRetryStates : Array;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function HTTPStatus( code : int, url : String )
		{
			m_url = url;
			setStatusCode( code );
			
			if (g_cancelRetryStates == null)
			{
				g_cancelRetryStates = new Array();
				g_cancelRetryStates[401] = true;
				g_cancelRetryStates[403] = true;
				g_cancelRetryStates[404] = true;
			}
		}	
		
		public function setStatusCode( code : int ) : void
		{
			m_statusCode = code;
			generateMessage();
		}	
			
		public function isError() : Boolean
		{
			return m_isError;
		}	
		
		public function description() : String
		{
			return m_description;
		}
		
		public function clone() : HTTPStatus
		{
			return new HTTPStatus(m_statusCode, m_url);
		}
		
		public function cancelRetry() : Boolean
		{
			return g_cancelRetryStates[m_statusCode] == true;
		}
		
		public function toString() : String
		{
			return '[HTTPStatus] error: ' + m_isError + ' description: ' + m_description;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function generateMessage() : void
		{
			var err : Boolean = false;
			var msg : String = '';
					
			// flash error
		    if ( m_statusCode < 100 ) 
			{
				err = true;
				msg = 'Flash encountered an internal error while loading from ' + m_url +
				 	'. This may also be a security problem!';
		    }
			// should never get here
		    else if ( m_statusCode < 200 ) 
			{
				// do nothing
		    }
			// request went fine
		    else if( m_statusCode < 300 ) 
			{
				// do nothing
		    }
			// request was redirected
		    else if( m_statusCode < 400 ) 
			{
				msg = 'Request was redirected';
		    }
			// client error
		    else if( m_statusCode < 500 ) 
			{
				err = true;			
				switch ( m_statusCode )
				{
					case HTTP_STATUS_BAD_REQUEST :
						msg = 'Flash sent bad request';
						break;
					case HTTP_STATUS_FORBIDDEN :
						msg = 'Flash tried to receive a protected file';
						break;
					case HTTP_STATUS_NOT_FOUND :
						msg = 'Flash requested a file which does not exist';
						break;
					case HTTP_STATUS_REQUEST_TIMEOUT :
						msg = 'Flash received a timeout';
						break;
					case HTTP_STATUS_UNSUPPORTED_MEDIA_TYPE :
						msg = 'Flash sent an unsupported MIME type';
						break;
				}
		    }
			// server error
		    else if( m_statusCode < 600 ) 
			{
				err = true;
				switch ( m_statusCode )
				{
					case HTTP_STATUS_INTERNAL_SERVER_ERROR :
						msg = 'Server sent an internal error message';
						break;
					case HTTP_STATUS_BAD_GATEWAY :
						msg = 'Server sent a bad gateway message';
						break;
					case HTTP_STATUS_SERVICE_UNAVAILABLE :
						msg = 'Server is currently unavailable';
						break;
					case HTTP_STATUS_HTTP_VERSION_NOT_SUPPORTED :
						msg = 'Server does not support the HTTP version we sent';
						break;
				}
			}
			
			m_isError = err;
			m_description = msg + ' (HTTP Status Code: ' + m_statusCode + ')';		
		}	
	}
}