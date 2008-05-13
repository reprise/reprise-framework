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
		protected var m_statusCode : Number;
		protected var m_description : String;
		protected	var m_url : String;
		protected var m_isError : Boolean;
		
		
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		// for future versions of HTTP
		public static var HTTP_STATUS_CONTINUE					: Number		= 100;
		public static var HTTP_STATUS_SWITCHING_PROTOCOLS		: Number		= 101;
		                                                    
		// informational states                             
		public static var HTTP_STATUS_OK						: Number		= 200;
		public static var HTTP_STATUS_CREATED					: Number		= 201;
		public static var HTTP_STATUS_ACCEPTED					: Number		= 202;
		public static var HTTP_STATUS_NON_AUTH_INFORMATION		: Number		= 203;
		public static var HTTP_STATUS_NO_CONTENT				: Number		= 204;
		public static var HTTP_STATUS_RESET_CONTENT				: Number		= 205;
		public static var HTTP_STATUS_PARTIAL_CONTENT			: Number		= 206;
				                                            
		// redirection                                      
		public static var HTTP_STATUS_MULTIPLE_CHOICES			: Number		= 300;
		public static var HTTP_STATUS_MOVED_PERMANENTLY			: Number		= 301;
		public static var HTTP_STATUS_MOVED_TEMPORARILY			: Number		= 302;
		public static var HTTP_STATUS_SEE_OTHER					: Number		= 303;
		public static var HTTP_STATUS_NOT_MODIFIED				: Number		= 304;
		public static var HTTP_STATUS_USE_PROXY					: Number		= 305;
		// 306 is reserved but currently not used           
		public static var HTTP_STATUS_TEMPORARY_REDIRECT		: Number		= 307;			
		                                                    
		// client error                                     
		public static var HTTP_STATUS_BAD_REQUEST				: Number		= 400;
		public static var HTTP_STATUS_UNAUTHORIZED				: Number		= 401;
		public static var HTTP_STATUS_PAYMENT_REQUIRED			: Number		= 402;
		public static var HTTP_STATUS_FORBIDDEN					: Number		= 403;
		public static var HTTP_STATUS_NOT_FOUND					: Number		= 404;
		public static var HTTP_STATUS_METHOD_NOT_ALLOWED		: Number		= 405;
		public static var HTTP_STATUS_NOT_ACCEPTABLE			: Number		= 406;
		public static var HTTP_STATUS_PROXY_AUTH_REQUIRED		: Number		= 407;
		public static var HTTP_STATUS_REQUEST_TIMEOUT			: Number		= 408;
		public static var HTTP_STATUS_CONFLICT					: Number		= 409;
		public static var HTTP_STATUS_GONE						: Number		= 410;
		public static var HTTP_STATUS_LENGTH_REQUIRED			: Number		= 411;
		public static var HTTP_STATUS_PRECONDITION_FAILED		: Number		= 412;
		public static var HTTP_STATUS_REQUEST_ENTITY_TOO_LARGE	: Number		= 413;
		public static var HTTP_STATUS_REQUEST_URL_TOO_LONG		: Number		= 414;
		public static var HTTP_STATUS_UNSUPPORTED_MEDIA_TYPE	: Number		= 415;
		public static var HTTP_STATUS_REQ_RANGE_NOT_SATISFIABLE	: Number		= 416;
		public static var HTTP_STATUS_EXPECTATION_FAILED		: Number		= 417;
		
		// server errors
		public static var HTTP_STATUS_INTERNAL_SERVER_ERROR		: Number		= 500;
		public static var HTTP_STATUS_NOT_IMPLEMENTED			: Number		= 501;
		public static var HTTP_STATUS_BAD_GATEWAY				: Number		= 502;
		public static var HTTP_STATUS_SERVICE_UNAVAILABLE		: Number		= 503;
		public static var HTTP_STATUS_GATEWAY_TIMEOUT			: Number		= 504;
		public static var HTTP_STATUS_HTTP_VERSION_NOT_SUPPORTED: Number		= 505;
		
		public static var g_cancelRetryStates : Array;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function HTTPStatus( code : Number, url : String )
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
		
		public function setStatusCode( code : Number ) : void
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