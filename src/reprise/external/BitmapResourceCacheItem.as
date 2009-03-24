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

package reprise.external { 
	import reprise.events.CommandEvent;
	import reprise.events.ResourceEvent;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	public class BitmapResourceCacheItem extends EventDispatcher
	{
	
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_isLoading : Boolean;
		protected var m_loader : ImageResource;
		protected var m_url : String;
		protected var m_cacheBitmap : Boolean = false;
		
		protected var m_isTemporary : Boolean = false;
		protected var m_bitmapDataReference : BitmapData;
		protected var m_httpStatus : HTTPStatus;
		protected var m_bytesLoaded : Number;
		protected var m_bytesTotal : Number;
		protected var m_success : Boolean;
		protected var m_targets : Array;
		protected var m_loadFinished : Boolean = false;
			
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function BitmapResourceCacheItem(loader : ImageResource)
		{
			m_loader = loader;
			m_loader.addEventListener(Event.COMPLETE, loader_complete, false, 0, true);
			m_loader.addEventListener(ResourceEvent.PROGRESS, loader_progress, false, 0, true);
			m_loader.addEventListener(Event.CANCEL, loader_cancel, false, 0, true);
		}
		
		public function loader() : ImageResource
		{
			return m_loader;
		}
		
		public function url() : String
		{
			return m_loader.url();
		}
		
		public function destroy() : void
		{
			m_bitmapDataReference.dispose();
			m_loader = null;
			m_targets = null;
		}
		
		public function addTarget(target : BitmapResource) : void
		{
			if (m_loadFinished)
			{
				applyDataToTarget(target);
				return;
			}
			
			if (m_targets == null)
			{
				m_targets = [];
			}
			m_targets.push(target);
			m_loader.setRetryTimes(Math.max(m_loader.retryTimes(), target.retryTimes()));
			m_loader.setTimeout(Math.max(m_loader.timeout(), target.timeout()));
			m_loader.setForceReload(m_loader.forceReload() || target.forceReload());
			target.addEventListener(Event.CANCEL, target_cancel, false, 0, true);
			
			if (target.cacheBitmap() && !target.forceReload())
			{
				m_cacheBitmap = true;
			}
		}
		
		public function isTemporary() : Boolean
		{
			return m_isTemporary;
		}
	
		public function setIsTemporary(val:Boolean) : void
		{
			m_isTemporary = val;
		}
		
		public function didFinishLoading() : Boolean
		{
			return m_loadFinished;
		}
		
		public function cacheBitmap() : Boolean
		{
			return m_cacheBitmap;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function removeTarget(target:BitmapResource) : void
		{
			var i : uint = m_targets.length;
			var numTargets : Number = 0;
			var foundTarget : BitmapResource;
			
			while (i--)
			{
				foundTarget = m_targets[i];
				if (foundTarget == target)
				{
					m_targets[i] = null;
				}
				else if (foundTarget != null)
				{
					numTargets++;
				}
			}
	
			if (numTargets == 0)
			{
				m_loader.cancel();
			}
		}
		
		protected function applyDataToTarget(target : BitmapResource) : void
		{
			target.setBytesLoaded(m_bytesLoaded);
			target.setBytesTotal(m_bytesTotal);
			target.updateProgress();
			
			if (!m_success)
			{
				target.setContent(null, m_httpStatus);
				return;
			}
			
			if (target.cloneBitmap())
			{
				target.setContent(m_bitmapDataReference.clone());
			}
			else		
			{
				target.setContent(m_bitmapDataReference, m_httpStatus);
			}
		}
		
		protected function loader_complete(e:ResourceEvent) : void
		{
			m_loadFinished = true;
	
			m_httpStatus = m_loader.httpStatus();
			m_bytesLoaded = m_loader.bytesLoaded();
			m_bytesTotal = m_loader.bytesTotal();
			m_success = e.success && !m_loader.isCancelled();
			
			if (m_success && m_loader.content().width && m_loader.content().height)
			{
				m_bitmapDataReference = new BitmapData(
					m_loader.content().width, m_loader.content().height, true, 0);
				m_bitmapDataReference.draw(m_loader.content());
			}
			
			for each (var target : BitmapResource in m_targets)
			{
				// target can be null. @see removeTarget
				if (target) applyDataToTarget(target);
			}
			m_targets = null;
			
			dispatchEvent(e);
		}
		
		protected function loader_progress(e:ResourceEvent) : void
		{
			if (!m_targets || !m_loader)
			{
				return;
			}
			var i : int = m_targets.length;
			while (i--)
			{
				var target : BitmapResource = BitmapResource(m_targets[i]);
				target.setBytesLoaded(m_loader.bytesLoaded());
				target.setBytesTotal(m_loader.bytesTotal());
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