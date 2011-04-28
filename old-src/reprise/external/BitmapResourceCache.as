/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.external
{
	import flash.events.Event;

	import reprise.data.collection.IndexedArray;
	import reprise.events.CommandEvent;

	public class BitmapResourceCache
	{//----------------------       Private / Protected Properties       ----------------------//
		protected static var g_instance : BitmapResourceCache;
		
		protected var _imageHolders : Object;
		protected var _cacheList : IndexedArray;
		protected var _temporaryList : IndexedArray;
		protected var _resourceLoader : ResourceLoader;
		protected var _maxParallelExecutionCount : int = 3;
	
	
		//----------------------               Public Methods               ----------------------//
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
			
			var cacheItem : BitmapResourceCacheItem = cacheItemWithURL(bitmapResource.url());
			
			if (cacheItem == null || (bitmapResource.forceReload() && cacheItem.didFinishLoading()))
			{
				var loader : ImageResource;
				var temporaryCacheItem : BitmapResourceCacheItem = temporaryCacheItemWithURL(bitmapResource.url());
				
				if (temporaryCacheItem != null)
				{
					
					if (bitmapResource.forceReload())
					{
						temporaryCacheItem.addTarget(bitmapResource);
					}
					else
					{
						_temporaryList.remove(temporaryCacheItem);
						temporaryCacheItem.setIsTemporary(false);
						_cacheList.push(temporaryCacheItem);
					}
					return;
				}			
				loader = imageResourceForBitmapResource(bitmapResource);
				cacheItem = new BitmapResourceCacheItem(loader);
				cacheItem.addTarget(bitmapResource);
				
				if (bitmapResource.forceReload())
				{
					cacheItem.setIsTemporary(true);
					_temporaryList.push(cacheItem);
				}
				else
				{
					_cacheList.push(cacheItem);
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
			_cacheList.remove(cacheItem);
		}
		
		public function setMaxParallelExecutionCount(count : int) : void
		{
			_maxParallelExecutionCount = isNaN(count) ? 3 : count;
			if (_resourceLoader)
			{
				_resourceLoader.setMaxParallelExecutionCount(_maxParallelExecutionCount);
			}
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		public function BitmapResourceCache()
		{
			_cacheList = new IndexedArray();
			_temporaryList = new IndexedArray();
			_resourceLoader = null;
			_imageHolders = {};
		}
		
		protected function imageResourceForBitmapResource(
			bmpResource:BitmapResource) : ImageResource
		{
			var imageResource : ImageResource = new ImageResource(bmpResource.url());
			imageResource.priority = bmpResource.priority;
			imageResource.setTimeout(bmpResource.timeout());
			imageResource.setForceReload(bmpResource.forceReload());
			imageResource.setCheckPolicyFile(bmpResource.checkPolicyFile());
			imageResource.setRetryTimes(bmpResource.retryTimes());
			//TODO: implement a cleaner way to propagate priority changes
			bmpResource.setContainingImageResource(imageResource);
			return imageResource;
		}
		
		protected function cacheItemWithURL(url:String) : BitmapResourceCacheItem
		{
			return getItemFromListByURL(_cacheList, url);
		}
		
		protected function temporaryCacheItemWithURL(
			url:String) : BitmapResourceCacheItem
		{
			return getItemFromListByURL(_temporaryList, url);
		}

		protected function getItemFromListByURL(list : IndexedArray, url : String) : BitmapResourceCacheItem
		{
			for (var i : int = list.length; i--;)
			{
				var item : BitmapResourceCacheItem = BitmapResourceCacheItem(list[i]);
				if (item.url() == url)
				{
					return item;
				}
			}
			return null;
		}
		
		protected function enqueueCacheItem(cacheItem:BitmapResourceCacheItem) : void
		{
			cacheItem.addEventListener(Event.COMPLETE, cleanupCachingItem);
			if (_resourceLoader == null)
			{
				_resourceLoader = new ResourceLoader();
				_resourceLoader.setMaxParallelExecutionCount(_maxParallelExecutionCount);
				_resourceLoader.addEventListener(Event.COMPLETE, cleanupLoader);
			}
			_resourceLoader.addResource(cacheItem.loader());
			if (!_resourceLoader.isExecuting())
			{
				_resourceLoader.execute();
			}
		}
		
		protected function cleanupCachingItem(e:CommandEvent) : void
		{
			var cacheItem : BitmapResourceCacheItem = BitmapResourceCacheItem(e.target);
			cacheItem.removeEventListener(Event.COMPLETE, cleanupCachingItem);
			if (e.success && cacheItem.cacheBitmap())
			{
				return;
			}		
	
			if (cacheItem.isTemporary())
			{
				_temporaryList.remove(cacheItem);
			}
			else
			{
				_cacheList.remove(cacheItem);
			}
		}
		
		protected function cleanupLoader(event : CommandEvent) : void
		{
			_resourceLoader.removeEventListener(Event.COMPLETE, cleanupLoader);
			_resourceLoader = null;
		}
	}
}