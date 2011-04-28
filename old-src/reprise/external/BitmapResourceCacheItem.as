/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.external { 
	import reprise.events.CommandEvent;
	import reprise.events.ResourceEvent;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	public class BitmapResourceCacheItem extends EventDispatcher
	{
	//----------------------       Private / Protected Properties       ----------------------//
		protected var _isLoading : Boolean;
		protected var _loader : ImageResource;
		protected var _url : String;
		protected var _cacheBitmap : Boolean = false;
		
		protected var _isTemporary : Boolean = false;
		protected var _bitmapDataReference : BitmapData;
		protected var _httpStatus : HTTPStatus;
		protected var _bytesLoaded : int;
		protected var _bytesTotal : int;
		protected var _success : Boolean;
		protected var _targets : Array;
		protected var _loadFinished : Boolean = false;
			
		
		
		//----------------------               Public Methods               ----------------------//
		public function BitmapResourceCacheItem(loader : ImageResource)
		{
			_loader = loader;
			_loader.addEventListener(Event.COMPLETE, loader_complete, false, 0, true);
			_loader.addEventListener(ResourceEvent.PROGRESS, loader_progress, false, 0, true);
			_loader.addEventListener(Event.CANCEL, loader_cancel, false, 0, true);
		}
		
		public function loader() : ImageResource
		{
			return _loader;
		}
		
		public function url() : String
		{
			return _loader.url();
		}
		
		public function destroy() : void
		{
			_bitmapDataReference.dispose();
			_loader = null;
			_targets = null;
		}
		
		public function addTarget(target : BitmapResource) : void
		{
			if (_loadFinished)
			{
				applyDataToTarget(target);
				return;
			}
			
			if (_targets == null)
			{
				_targets = [];
			}
			_targets.push(target);
			_loader.setRetryTimes(Math.max(_loader.retryTimes(), target.retryTimes()));
			_loader.setTimeout(Math.max(_loader.timeout(), target.timeout()));
			_loader.setForceReload(_loader.forceReload() || target.forceReload());
			target.addEventListener(Event.CANCEL, target_cancel, false, 0, true);
			
			if (target.cacheBitmap() && !target.forceReload())
			{
				_cacheBitmap = true;
			}
		}
		
		public function isTemporary() : Boolean
		{
			return _isTemporary;
		}
	
		public function setIsTemporary(val:Boolean) : void
		{
			_isTemporary = val;
		}
		
		public function didFinishLoading() : Boolean
		{
			return _loadFinished;
		}
		
		public function cacheBitmap() : Boolean
		{
			return _cacheBitmap;
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected function removeTarget(target:BitmapResource) : void
		{
			var index : int = _targets.indexOf(target);
			if (index != -1)
			{
				_targets.splice(index, 1);
			}
	
			if (_targets.length == 0)
			{
				_loader.cancel();
			}
		}
		
		protected function applyDataToTarget(target : BitmapResource) : void
		{
			target.setBytesLoaded(_bytesLoaded);
			target.setBytesTotal(_bytesTotal);
			target.updateProgress();
			
			if (!_success)
			{
				target.setContent(null, _httpStatus);
				return;
			}
			
			if (target.cloneBitmap())
			{
				target.setContent(_bitmapDataReference.clone());
			}
			else		
			{
				target.setContent(_bitmapDataReference, _httpStatus);
			}
		}
		
		protected function loader_complete(e:ResourceEvent) : void
		{
			_loadFinished = true;
	
			_httpStatus = _loader.httpStatus();
			_bytesLoaded = _loader.bytesLoaded();
			_bytesTotal = _loader.bytesTotal();
			_success = e.success && !_loader.isCancelled();
			
			if (_success && _loader.content().width && _loader.content().height)
			{
				_bitmapDataReference = new BitmapData(
					_loader.content().width, _loader.content().height, true, 0);
				_bitmapDataReference.draw(_loader.content());
			}
			
			for each (var target : BitmapResource in _targets)
			{
				applyDataToTarget(target);
			}
			_targets = null;
			
			dispatchEvent(e);
		}
		
		protected function loader_progress(e:ResourceEvent) : void
		{
			if (!_targets || !_loader)
			{
				return;
			}
			for each (var target : BitmapResource in _targets)
			{
				target.setBytesLoaded(_loader.bytesLoaded());
				target.setBytesTotal(_loader.bytesTotal());
				target.updateProgress();
			}
		}
		
		protected function loader_cancel(e:CommandEvent) : void
		{
			var event : ResourceEvent = new ResourceEvent(
				Event.COMPLETE, false, ResourceEvent.USER_CANCELLED);
			dispatchEvent(event);
		}
		
		protected function target_cancel(e : CommandEvent) : void
		{		
			removeTarget(BitmapResource(e.target));
		}
	}
}