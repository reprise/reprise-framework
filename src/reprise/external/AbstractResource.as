/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.external
{
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;

	import reprise.commands.AbstractAsynchronousCommand;
	import reprise.commands.TimeCommandExecutor;
	import reprise.events.ResourceEvent;
	import reprise.utils.Delegate;

	public class AbstractResource extends AbstractAsynchronousCommand
		implements IResource
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_url : String;
		protected var m_timeout : int = 20000;
		protected var m_retryTimes : int = 3;
		protected var m_failedTimes : int;
		protected var m_forceReload : Boolean;
		protected var m_content : Object;
		protected var m_controlDelegate : Delegate;
		protected var m_lastBytesLoaded : int;
		protected var m_lastCheckTime : int;
		protected var m_httpStatus : HTTPStatus;
		protected var m_didFinishLoading : Boolean = false;		
		protected var m_checkPolicyFile : Boolean;
		protected var m_attachMode : Boolean;

		private var m_failureReason : int;


		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function load(url : String = null) : void
		{
			setURL(url);
			execute();
		}
		
		public override function execute(...rest) : void
		{	
			if (m_isExecuting)
			{
				return;
			}
			if (m_url == null)
			{
				throw new Error('You didn\'t specify an URL for your ' + 
					'resource! Make sure you do this before calling execute!');
			}

			super.execute();
			m_failedTimes = 0;
			m_lastBytesLoaded = 0;
			m_lastCheckTime = getTimer();
			m_controlDelegate = new Delegate(this, checkProgress);
			TimeCommandExecutor.instance().addCommand(m_controlDelegate, 150);
			doLoad();
		}
			
		public function setURL(theURL : String) : void
		{		
			m_url = theURL;
		}
		
		public function url() : String
		{
			return m_url;
		}
		
		public function timeout() : int
		{
			return m_timeout;
		}
	
		public function setTimeout(timeout : int) : void
		{
			m_timeout = timeout;
		}
		
		public function retryTimes() : int
		{
			return m_retryTimes;
		}
	
		public function setRetryTimes(times : int) : void
		{
			m_retryTimes = times;
		}
		
		public function forceReload() : Boolean
		{
			return m_forceReload;
		}
	
		public function setForceReload(bFlag : Boolean) : void
		{
			m_forceReload = bFlag;
		}
		
		public function setCheckPolicyFile(checkPolicyFile : Boolean) : void
		{
			m_checkPolicyFile = checkPolicyFile;
		}
		public function checkPolicyFile() : Boolean
		{
			return m_checkPolicyFile;
		}
		
		public function content() : *
		{
			return m_content;
		}
		
		public function bytesLoaded() : int
		{
			throw new Error('Cannot call bytesLoaded of AbstractResource directly!');
		}
		
		public function bytesTotal() : int
		{
			throw new Error('Cannot call bytesTotal of AbstractResource directly!');
		}
		
		public function progress() : Number
		{
			var progress : Number = 
				Math.round(bytesLoaded() / (bytesTotal() / 100));
			if (isNaN(progress))
			{
				progress = 0;
			}
			return progress;
		}
		
		public function httpStatus() : HTTPStatus
		{
			return m_httpStatus;
		}
		
		public function didFinishLoading() : Boolean
		{
			return m_didFinishLoading;
		}
		
		public override function cancel() : void
		{
			if (m_didFinishLoading)
			{
				return;
			}
			TimeCommandExecutor.instance().removeCommand(m_controlDelegate);
			m_controlDelegate = null;
			doCancel();
			m_isExecuting = false;
			m_isCancelled = true;
			dispatchEvent(new ResourceEvent(Event.CANCEL));
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function AbstractResource(url:String = null)
		{
			if (url)
			{
				setURL(url);
			}
		}
		
		protected function doLoad() : void
		{
			throw new Error(
				'Cannot call doLoad of AbstractResource directly!');
		}
		
		protected function doCancel() : void
		{
			throw new Error(
				'Cannot call doCancel of AbstractResource directly!');		
		}
		
		protected function timestamp() : String
		{
			var d : Date = new Date();
			return d.getTime().toString();
		}
		
		protected function urlByAppendingTimestamp() : String
		{
			var urlSeparator : String = m_url.indexOf('?') != -1 ? '&' : '?';
			var url : String;
			//TODO: find a replacement for _root._url
			if (true)//_root._url.indexOf("http://") != 0 && m_url.indexOf("http://") != 0)
			{
				url = m_url;
			}
			else
			{
			 	url = m_url + (m_forceReload ? 
			 		urlSeparator + 'forcereload=' + timestamp() : '');
			}
	
			return ResourceProxy.instance().modifiedURLStringForString(url);
		}
		
		//TODO: probably don't call using delegate and check the args
		protected function checkProgress(...rest : Array) : void
		{
			// no progress this time
			if (m_lastBytesLoaded == bytesLoaded())
			{
				// resource received timeout
				if (getTimer() - m_lastCheckTime >= m_timeout)
				{
					setFailureReason(ResourceEvent.ERROR_TIMEOUT);
					notifyComplete(false);
					return;
				}
				// we'll wait until there happens something or we receive a timeout
				return;
			}
			
			m_lastBytesLoaded = bytesLoaded();
			m_lastCheckTime = getTimer();
			
			dispatchEvent(new ResourceEvent(ResourceEvent.PROGRESS));
		}
		
		protected function onData(success : Boolean) : void
		{
			if (m_httpStatus && m_httpStatus.isError() && !success)
			{
				setFailureReason(ResourceEvent.ERROR_HTTP);
				notifyComplete(false);
				return;
			}
			if (!success)
			{
				setFailureReason(ResourceEvent.ERROR_UNKNOWN);
				notifyComplete(false);
				return;
			}
			notifyComplete(success);
		}
		
		protected function setHttpStatus(httpStatus : HTTPStatus) : void
		{
			m_httpStatus = httpStatus;
		}
		protected function setFailureReason(failureReason:int) : void
		{
			m_failureReason = failureReason;
		}
		
		protected override function notifyComplete(success:Boolean) : void
		{
			// needed to guarantee a 100% value for progress broadcasted to listeners
			dispatchEvent(new ResourceEvent(ResourceEvent.PROGRESS));
			TimeCommandExecutor.instance().removeCommand(m_controlDelegate);
			m_controlDelegate = null;
			
			if (!success && ++m_failedTimes < m_retryTimes && 
				!(httpStatus() && httpStatus().cancelRetry()))
			{
				doLoad();
				return;
			}
			
			if (!success)
			{
				var errMsg : String = 'w Loading of resource "' + 
					m_url + '" failed. ';
				
				switch (m_failureReason)
				{
					case ResourceEvent.ERROR_HTTP :
						errMsg += 'There was an HTTP error. ' + 
							m_httpStatus.description();
						break;
						
					case ResourceEvent.ERROR_TIMEOUT : 
						errMsg += 'Timeout (' + m_timeout + ') exceeded.';
						break;
						
					case ResourceEvent.ERROR_UNKNOWN :
					default:
						errMsg += 'There was an unknown error. ' + 
							'Make sure that the file exists!';
				}
				log(errMsg);
			}
			
			m_didSucceed = success;
			m_isExecuting = false;
			m_didFinishLoading = true;
			
			dispatchEvent(new ResourceEvent(Event.COMPLETE, 
				success, m_failureReason, m_httpStatus));
		}
		
		protected function loader_httpStatus(statusCode : int) : void
		{
			m_httpStatus = new HTTPStatus(statusCode, m_url);
		}

		protected function resolveAttachSymbol() : Class
		{
			if (!(m_url && m_url.indexOf('attach://') === 0))
			{
				m_attachMode = false;
				return null;
			}
			m_attachMode = true;
			//remove protocol
			var symbolId:String = m_url.substr(9);

			//get FQCN name of assets class that contains the requested symbol
			var pieces:Array = symbolId.split('/');
			var className : String = pieces.shift();
			try
			{
				var symbol : Object = getDefinitionByName(className);
			}
			catch (e : Error)
			{
				log('w Unable to use attach:// procotol. Symbol ' + symbolId + ' not found.');
				return null;
			}

            pieces = pieces.join('/').split(/[.-]/).join('_').split('/');
			//iterate over remaining path parts, getting nested symbols from the assets class
			for (var i:int = 0; i < pieces.length; i++)
			{
				symbol = symbol[pieces[i]];
				if (!symbol)
				{
					log('w Unable to use attach:// procotol! Static property ' + pieces.join('.') +
							' not found on Class ' + className);
					return null;
				}
			}
			if (!(symbol is Class))
			{
				log('w Unable to use attach:// procotol. Static property ' + pieces.join('.') +
						' on Class ' + className + ' is not of type Class.');
				return null;
			}
			return symbol as Class;
		}

		/**
		 * Logs a warning message informing about an incompatible Class type in an asset loaded via "attach://"
		 * @param symbol The symbol with the unsupported type
		 */
		protected function logUnsupportedTypeMessage(symbol : Class) : void
		{
			var symbolId : String = m_url.substr(9);
			var className : String = symbolId.substr(0, symbolId.indexOf('/'));
			var propertyName : String = symbolId.substr(symbolId.indexOf('/') + 1);
			var fqcn : String = getQualifiedClassName(symbol);
			var resourceName : String = getQualifiedClassName(this['constructor']);
			log('w Unable to use attach:// procotol. Static property ' + propertyName + ' on Class ' +
					className + ' has type ' + fqcn + ', which is not supported by ' + resourceName);
		}
	}
}