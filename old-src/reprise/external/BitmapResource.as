/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.external { 
	import reprise.commands.TimeCommandExecutor;
	
	import flash.display.BitmapData;
	
	
	public class BitmapResource extends AbstractResource
	{//----------------------       Private / Protected Properties       ----------------------//
		protected var _cacheBitmap : Boolean;
		protected var _cloneBitmap : Boolean;
		protected var _bytesLoaded : int;
		protected var _bytesTotal : int;
		protected var _applicationURL : String;
		protected var _data : BitmapData;
		
		protected var _containingImageResource : ImageResource;
		
		
		//----------------------               Public Methods               ----------------------//
		public function BitmapResource(url:String = null, 
			cacheBitmap:Boolean = true, cloneBitmap:Boolean = true)
		{
			_url = url;
			_cacheBitmap = cacheBitmap;
			_cloneBitmap = cloneBitmap;
			_checkPolicyFile = true;
		}

		public override function execute(...rest) : void
		{
			super.execute();
			// we rely on the events dispatched by ImageResource
			TimeCommandExecutor.instance().removeCommand(_controlDelegate);
		}
		
		public override function bytesLoaded() : int
		{
			return _bytesLoaded;
		}
		
		public override function bytesTotal() : int
		{
			return _bytesTotal;
		}	
		
		public override function content() : *
		{
			return _data;
		}	
		
		public function setCacheBitmap(bFlag:Boolean) : void
		{
			_cacheBitmap = bFlag;
		}
		
		public function cacheBitmap() : Boolean
		{
			return _cacheBitmap;
		}
		
		public function setCloneBitmap(bFlag:Boolean) : void
		{
			_cloneBitmap = bFlag;
		}
		
		public function cloneBitmap() : Boolean
		{
			return _cloneBitmap;
		}
		
		
		
		/**
		* Do not call these directly
		* following methods are meant to be used by BitmapResourceCache only
		**/
		public function setContent(bitmap:BitmapData, httpStatus:HTTPStatus = null) : void
		{
			_data = bitmap;
			_httpStatus = httpStatus;
			onData(bitmap != null);
		}
		
		public function setBytesLoaded(bytesLoaded:Number) : void
		{
			_bytesLoaded = bytesLoaded;
		}
		
		public function setBytesTotal(bytesTotal:Number) : void
		{
			_bytesTotal = bytesTotal;
		}
		
		public function updateProgress() : void
		{
			checkProgress();		
		}
		
		/**
		 * Used to propagate priority changes from a BitmapResource to the 
		 * ImageResource that does the actual loading.
		 * 
		 * TODO: find a better way to do this.
		 */
		public function setContainingImageResource(
			imageResource : ImageResource) : void
		{
			_containingImageResource = imageResource;
		}
		
		public override function set priority(value : int) : void
		{
			super.priority = value;
			// @FIXME
			if (_containingImageResource)
			{
				_containingImageResource.priority = value;
			}
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function doLoad() : void
		{
			var cache : BitmapResourceCache = BitmapResourceCache.instance();
			cache.loadBitmapResource(this);
		}
		protected override function doCancel() : void
		{
			// BitmapResourceCacheItem takes care of cancelling
		}
	}
}