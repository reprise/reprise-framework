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
	import reprise.data.collection.IndexedArray;
	import reprise.events.CommandEvent;
	
	import flash.events.Event;
	public class BitmapResourceCache
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_instance : BitmapResourceCache;
		
		protected var m_imageHolders : Object;
		protected var m_cacheList : IndexedArray;
		protected var m_temporaryList : IndexedArray;
		protected var m_resourceLoader : ResourceLoader;
		protected var m_maxParallelExecutionCount : Number = 3;
	
	
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static function instance() : BitmapResourceCache
		{
			if (g_instance == null)
			{
				g_instance = new BitmapResourceCache();
			}
			return g_instance;
		}
			
		public function loadBitmapResource(bitmapResource:BitmapResource) : void
		{
			if (bitmapResource.isCancelled())
			{
				return;
			}
			
			var cacheItem : BitmapResourceCacheItem = 
				cacheItemWithURL(bitmapResource.url());
			
			if (cacheItem == null || 
				(bitmapResource.forceReload() && cacheItem.didFinishLoading()))
			{
				var loader : ImageResource;
				var temporaryCacheItem : BitmapResourceCacheItem = 
					temporaryCacheItemWithURL(bitmapResource.url());
				
				if (temporaryCacheItem != null)
				{
					
					if (bitmapResource.forceReload())
					{
						temporaryCacheItem.addTarget(bitmapResource);
					}
					else
					{
						m_temporaryList.remove(temporaryCacheItem);
						temporaryCacheItem.setIsTemporary(false);
						m_cacheList.push(temporaryCacheItem);
					}
					return;
				}			
				
				loader = imageResourceForBitmapResource(bitmapResource);
				cacheItem = new BitmapResourceCacheItem(loader);
				cacheItem.addTarget(bitmapResource);
				
				if (bitmapResource.forceReload())
				{
					cacheItem.setIsTemporary(true);
					m_temporaryList.push(cacheItem);
				}
				else
				{
					m_cacheList.push(cacheItem);				
				}			
				enqueueCacheItem(cacheItem);
			}
			else
			{
				cacheItem.addTarget(bitmapResource);
			}
		}
		
		public function destroyBitmapWithURL(url:String) : void
		{
			var cacheItem : BitmapResourceCacheItem = cacheItemWithURL(url);
			cacheItem.destroy();
			m_cacheList.remove(cacheItem);
		}
		
		public function setMaxParallelExecutionCount(count : Number) : void
		{
			m_maxParallelExecutionCount = isNaN(count) ? 3 : count;
			if (m_resourceLoader)
			{
				m_resourceLoader.setMaxParallelExecutionCount(
					m_maxParallelExecutionCount);
			}
		}
		
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function BitmapResourceCache()
		{
			m_cacheList = new IndexedArray();
			m_temporaryList = new IndexedArray();
			m_resourceLoader = null;
			m_imageHolders = {};
		}
		
		protected function imageResourceForBitmapResource(
			bmpResource:BitmapResource) : ImageResource
		{
			var imageResource : ImageResource = 
				new ImageResource(bmpResource.url());
			imageResource.setPriority(bmpResource.priority());
			imageResource.setTimeout(bmpResource.timeout());
			imageResource.setForceReload(bmpResource.forceReload());
			imageResource.setRetryTimes(bmpResource.retryTimes());
			//TODO: implement a cleaner way to propagate priority changes
			bmpResource.setContainingImageResource(imageResource);
			return imageResource;
		}
		
		protected function cacheItemWithURL(url:String) : BitmapResourceCacheItem
		{
			var i : Number = m_cacheList.length;
			var item : BitmapResourceCacheItem;
			while (i--)
			{	
				item = BitmapResourceCacheItem(m_cacheList[i]);
				if (item.url() == url)
				{
					return item;
				}
			}
			return null;
		}
		
		protected function temporaryCacheItemWithURL(
			url:String) : BitmapResourceCacheItem
		{
			var i : Number = m_temporaryList.length;
			var item : BitmapResourceCacheItem;
			while (i--)
			{	
				item = BitmapResourceCacheItem(m_temporaryList[i]);
				if (item.url() == url)
				{
					return item;
				}
			}
			return null;
		}
		
		protected function enqueueCacheItem(cacheItem:BitmapResourceCacheItem) : void
		{
			cacheItem.addEventListener(Event.COMPLETE, 
			 cleanupCachingItem);
			if (m_resourceLoader == null)
			{
				m_resourceLoader = new ResourceLoader();
				m_resourceLoader.setMaxParallelExecutionCount(
					m_maxParallelExecutionCount);
				m_resourceLoader.addEventListener(Event.COMPLETE, 
				 cleanupLoader);
			}
			m_resourceLoader.addResource(cacheItem.loader());
			if (!m_resourceLoader.isExecuting())
			{
				m_resourceLoader.execute();
			}
		}
		
		protected function cleanupCachingItem(e:CommandEvent) : void
		{
			var cacheItem : BitmapResourceCacheItem = 
				BitmapResourceCacheItem(e.target);		
			cacheItem.removeEventListener(Event.COMPLETE, cleanupCachingItem);
			if (e.success && cacheItem.cacheBitmap())
			{
				return;
			}		
	
			if (cacheItem.isTemporary())
			{
				m_temporaryList.remove(cacheItem);
			}
			else
			{
				m_cacheList.remove(cacheItem);
			}
		}
		
		protected function cleanupLoader(event : CommandEvent) : void
		{
			m_resourceLoader.removeEventListener(Event.COMPLETE, cleanupLoader);
			m_resourceLoader = null;
		}
	}
}