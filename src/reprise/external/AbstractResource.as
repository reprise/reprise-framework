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
	import reprise.commands.AbstractAsynchronousCommand;
	import reprise.commands.TimeCommandExecutor;
	import reprise.events.CommandEvent;
	import reprise.events.ResourceEvent;
	import reprise.utils.Delegate;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	public class AbstractResource extends AbstractAsynchronousCommand
		implements IResource
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_url : String;
		protected var m_request : URLRequest;
		protected	var m_timeout : Number = 5000;
		protected var m_retryTimes : Number = 3;
		protected var m_failedTimes : Number;
		protected var m_forceReload : Boolean;
		protected var m_content : String;
		protected var m_controlDelegate : Delegate;
		protected var m_lastBytesLoaded : Number;
		protected var m_lastCheckTime : Number;
		protected var m_httpStatus : HTTPStatus;
		protected var m_didFinishLoading : Boolean = false;		
		private var m_failureReason : Number;
		protected var m_checkPolicyFile : Boolean;

		
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
				return;
			}
				
			m_failedTimes = 0;
			m_lastBytesLoaded = 0;
			m_lastCheckTime = getTimer();
			super.execute();
			TimeCommandExecutor.instance().addCommand(m_controlDelegate, 150);
			doLoad();
		}
			
		public function setURL(theURL : String) : void
		{		
			m_url = theURL;
			m_request = new URLRequest(theURL);	
		}
		
		public function url() : String
		{
			return m_url;
		}
		
		public function timeout() : Number
		{
			return m_timeout;
		}
	
		public function setTimeout(timeout : Number) : void
		{
			m_timeout = timeout;
		}
		
		public function retryTimes() : Number
		{
			return m_retryTimes;
		}
	
		public function setRetryTimes(times : Number) : void
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
		
		public function bytesLoaded() : Number
		{
			throw new Error(
				'Cannot call bytesLoaded of AbstractResource directly!');
			return null;
		}
		
		public function bytesTotal() : Number
		{
			throw new Error(
				'Cannot call bytesTotal of AbstractResource directly!');
			return null;
		}
		
		public function getProgress() : Number
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
			m_isExecuting = false;
			m_isCancelled = true;
			doCancel();
			dispatchEvent(new CommandEvent(Event.CANCEL));
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
			m_controlDelegate = new Delegate(this, checkProgress);		
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
		protected function setFailureReason(failureReason:Number) : void
		{
			m_failureReason = failureReason;
		}
		
		protected override function notifyComplete(success:Boolean) : void
		{
			// needed to guarantee a 100% value for progress broadcasted to listeners
			dispatchEvent(new ResourceEvent(ResourceEvent.PROGRESS));
			TimeCommandExecutor.instance().removeCommand(m_controlDelegate);
			
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
						errMsg += 'There was an unknown error. ' + 
							'Make sure that the file exists!';
				}
				trace(errMsg);
			}
			
			m_didSucceed = success;
			
			dispatchEvent(new ResourceEvent(Event.COMPLETE, 
				success, m_failureReason, m_httpStatus));
			m_isExecuting = false;
			m_didFinishLoading = true;
		}
		
		protected function loader_httpStatus(statusCode : Number) : void
		{
			m_httpStatus = new HTTPStatus(statusCode, m_url);
		}
	}
}