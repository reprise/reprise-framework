/*
 * Copyright (c) 2006-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.resources
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;

	import reprise.commands.AsyncCommandBase;
	import reprise.commands.events.CommandEvent;
	import reprise.resources.events.ResourceEvent;

	public class ResourceBase extends AsyncCommandBase implements IResource
	{
		//----------------------       Private / Protected Properties       ----------------------//
		protected static const PROGRESS_CHECK_TIMER : Timer = new Timer(150);
		protected static var PROGRESS_CHECK_TIMER_CLIENTS : uint = 0;

		protected var _url : String;
		protected var _content : Object;
		protected var _checkPolicyFile : Boolean;
		protected var _attachMode : Boolean;

		protected var _timeout : int = 20000;
		protected var _retryTimes : int = 3;
		protected var _failedAttempts : int;
		protected var _lastBytesLoaded : int;
		protected var _lastCheckTime : int;

		protected var _completed : Boolean;
		protected var _httpStatusCode : int;
		protected var _ioErrorOccured : Boolean;
		protected var _ioErrorText : String;
		protected var _failureReason : int;


		//----------------------               Public Methods               ----------------------//
		public function ResourceBase(url : String = null)
		{
			this.url = url;
		}

		public function load(url : String = null) : void
		{
			if (url)
			{
				this.url = url;
			}
			execute();
		}

		public override function execute() : void
		{
			if (_isExecuting)
			{
				return;
			}
			if (!_url)
			{
				throw new Error('Error loading ' + getQualifiedClassName(this) + ': No URL given');
			}

			super.execute();
			_failedAttempts = 0;
			_lastBytesLoaded = 0;
			_lastCheckTime = getTimer();
			startProgressListening();
			doLoad();
		}

		public function set url(url : String) : void
		{
			_url = url;
		}

		public function get url() : String
		{
			return _url;
		}

		public function set timeout(timeout : uint) : void
		{
			_timeout = timeout;
		}

		public function get timeout() : uint
		{
			return _timeout;
		}

		public function get retryTimes() : uint
		{
			return _retryTimes;
		}

		public function set retryTimes(times : uint) : void
		{
			_retryTimes = times;
		}

		public function set checkPolicyFile(checkPolicyFile : Boolean) : void
		{
			_checkPolicyFile = checkPolicyFile;
		}

		public function get checkPolicyFile() : Boolean
		{
			return _checkPolicyFile;
		}

		public function content() : *
		{
			return _content;
		}

		public function completed() : Boolean
		{
			return _completed;
		}

		public override function cancel() : void
		{
			if (_completed)
			{
				return;
			}
			stopProgressListening();
			doCancel();
			_isExecuting = false;
			_isCancelled = true;
			dispatchEvent(new ResourceEvent(
					CommandEvent.CANCEL, false, ResourceEvent.ERROR_CANCELLED));
		}

		public function get bytesLoaded() : int
		{
			return _completed ? 1 : 0;
		}


		public function get bytesTotal() : int
		{
			return 1;
		}


		//----------------------         Private / Protected Methods        ----------------------//
		protected function doLoad() : void
		{
			throw new Error('Cannot call doLoad of AbstractResource directly!');
		}

		protected function doCancel() : void
		{
			throw new Error('Cannot call doCancel of AbstractResource directly!');
		}

		protected function startProgressListening() : void
		{
			if (PROGRESS_CHECK_TIMER_CLIENTS++ === 0)
			{
				PROGRESS_CHECK_TIMER.start();
			}
			PROGRESS_CHECK_TIMER.addEventListener(TimerEvent.TIMER, checkProgress);
		}

		protected function stopProgressListening() : void
		{
			if (--PROGRESS_CHECK_TIMER_CLIENTS === 0)
			{
				PROGRESS_CHECK_TIMER.stop();
			}
			PROGRESS_CHECK_TIMER.removeEventListener(TimerEvent.TIMER, checkProgress);
		}

		protected function checkProgress(event : TimerEvent) : void
		{
			var bytesLoaded : int = this.bytesLoaded;
			var currentTime : int = getTimer();
			if (_lastBytesLoaded === bytesLoaded)
			{
				// resource received timeout
				if (currentTime - _lastCheckTime >= _timeout)
				{
					setFailureReason(ResourceEvent.ERROR_TIMEOUT);
					notifyComplete(false);
					return;
				}
				// we'll wait until there happens something or we receive a timeout
				return;
			}

			_lastBytesLoaded = bytesLoaded;
			_lastCheckTime = currentTime;

			dispatchEvent(new ResourceEvent(ResourceEvent.PROGRESS));
		}

		protected function onData(success : Boolean) : void
		{
			if (!success)
			{
				if (_httpStatusCode && HTTPStatus.isError(_httpStatusCode))
				{
					setFailureReason(ResourceEvent.ERROR_HTTP);
				}
				if (_ioErrorOccured)
				{
					setFailureReason(ResourceEvent.ERROR_IO);
				}
				else
				{
					setFailureReason(ResourceEvent.ERROR_UNKNOWN);
				}
			}
			notifyComplete(success);
		}

		protected function setHttpStatusCode(httpCode : int) : void
		{
			_httpStatusCode = httpCode;
		}

		protected function setFailureReason(failureReason : int) : void
		{
			_failureReason = failureReason;
		}

		protected override function notifyComplete(success : Boolean) : void
		{
			// needed to guarantee a 100% value for progress broadcasted to listeners
			dispatchEvent(new ResourceEvent(ResourceEvent.PROGRESS));

			stopProgressListening();

			if (!success && ++_failedAttempts < _retryTimes &&
					!(HTTPStatus.cancelRetryAfterReceving(_httpStatusCode)))
			{
				doLoad();
				return;
			}

			_success = success;
			_isExecuting = false;
			_completed = true;

			if (success)
			{
				dispatchEvent(new ResourceEvent(CommandEvent.COMPLETE));
				return;
			}
			
			var errMsg : String = 'Loading of resource "' + _url + '" failed. ';
			switch (_failureReason)
			{
				case ResourceEvent.ERROR_HTTP :
				{
					errMsg += 'HTTP error: ' +
							HTTPStatus.description(_httpStatusCode);
					break;
				}
				case ResourceEvent.ERROR_TIMEOUT :
				{
					errMsg += 'Timeout (' + _timeout + ') exceeded.';
					break;
				}
				case ResourceEvent.ERROR_IO :
				{
					errMsg += 'IO error: ' + _ioErrorText;
					break;
				}
				case ResourceEvent.ERROR_UNKNOWN :
				default:
				{
					errMsg += 'Unknown error. Make sure the resource exists.';
				}
			}
			log('w ' + errMsg);
			dispatchEvent(new ResourceEvent(
					CommandEvent.COMPLETE, false, _failureReason, _httpStatusCode, errMsg));

		}

		protected function resolveAttachSymbol() : Class
		{
			if (!(_url && _url.indexOf('attach://') === 0))
			{
				_attachMode = false;
				return null;
			}
			_attachMode = true;
			//remove protocol
			var symbolId : String = _url.substr(9);

			//get FQCN name of assets class that contains the requested symbol
			var pieces : Array = symbolId.split('/');
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

			// For URLs of the form "attach://symbol/", strip the trailing "/" and just use "symbol"
			if (pieces.length == 1 && pieces[0].length === 0)
			{
				pieces.length = 0;
			}

			//iterate over remaining path parts, getting nested symbols from the assets class
			for (var i : int = 0; i < pieces.length; i++)
			{
				symbol = symbol[pieces[i]];
				if (!symbol)
				{
					log('w Unable to use attach:// procotol. Static property ' + pieces.join('/') +
							' not found on Class ' + className);
					return null;
				}
			}
			if (!(symbol is Class))
			{
				log('w Unable to use attach:// procotol. Static property ' + pieces.join('/') +
						' on Class ' + className + ' is not of type Class.');
				return null;
			}
			return symbol as Class;
		}

		/**
		 * Logs a warning message informing about an incompatible Class type in an asset loaded via
		 * "attach://"
		 * 
		 * @param symbol The symbol with the unsupported type
		 */
		protected function createUnsupportedTypeMessage(symbol : Class) : String
		{
			var symbolId : String = _url.substr(9);
			var className : String = symbolId.substr(0, symbolId.indexOf('/'));
			var propertyName : String = symbolId.substr(symbolId.indexOf('/') + 1);
			var fqcn : String = getQualifiedClassName(symbol);
			var resourceName : String = getQualifiedClassName(this['constructor']);
			return('Unable to use attach:// procotol. Static property ' + propertyName +
					' on Class ' +
					className + ' has type ' + fqcn + ', which is not supported by ' +
					resourceName);
		}
	}
}