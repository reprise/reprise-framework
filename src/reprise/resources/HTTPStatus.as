/*
* Copyright (c) 2006-2011 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.resources
{
	import flash.utils.Dictionary;

	public class HTTPStatus
	{
		//----------------------             Public Properties              ----------------------//
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
		
		public static const CANCEL_RETRY_STATES : Dictionary = new Dictionary();
		{
			CANCEL_RETRY_STATES[401] = true;
			CANCEL_RETRY_STATES[403] = true;
			CANCEL_RETRY_STATES[404] = true;
		}



		//----------------------               Public Methods               ----------------------//
		public static function isError(code : uint) : Boolean
		{
			return code < 100 || code >= 400;
		}	
		
		public static function description(httpCode : int) : String
		{
			return generateMessage(httpCode) + ' HTTP code: ' + httpCode;
		}
		
		public static function cancelRetryAfterReceving(httpCode : int) : Boolean
		{
			return CANCEL_RETRY_STATES[httpCode] === true;
		}


		//----------------------         Private / Protected Methods        ----------------------//
		private static function generateMessage(httpCode : int) : String
		{
			// flash error
			if (httpCode < 100)
			{
				return 'Internal error while loading resource. ' +
						'Might be caused by sandbox restrictions';
			}
			if (httpCode < 200)
			{
				throw new Error('invalid HTTP code: ' + httpCode);
			}
			// request went fine
			if (httpCode < 300)
			{
				return 'Ok';
			}
			
			// request was redirected
			if (httpCode < 400)
			{
				return 'Request redirected';
			}
			// client error
			if (httpCode < 500)
			{
				switch (httpCode)
				{
					case HTTP_STATUS_BAD_REQUEST :              return 'Bad request';
					case HTTP_STATUS_FORBIDDEN :                return 'Forbidden';
					case HTTP_STATUS_NOT_FOUND :                return 'Not found';
					case HTTP_STATUS_REQUEST_TIMEOUT :          return 'Request timed out';
					case HTTP_STATUS_UNSUPPORTED_MEDIA_TYPE :   return 'MIME type not supported';
				}
			}
			// server error
			else if (httpCode < 600)
			{
				switch (httpCode)
				{
					case HTTP_STATUS_INTERNAL_SERVER_ERROR :
						return 'Internal server error';
					case HTTP_STATUS_BAD_GATEWAY :
						return 'Bad gateway';
					case HTTP_STATUS_SERVICE_UNAVAILABLE :
						return 'Service unavailable';
					case HTTP_STATUS_HTTP_VERSION_NOT_SUPPORTED :
						return 'HTTP version not supported';
				}
			}
			throw new Error('Invalid HTTP code: ' + httpCode);
		}
	}
}