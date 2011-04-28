/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.controls.html
{
	import reprise.controls.BitmapElement;
	import reprise.events.DisplayEvent;
	import reprise.events.ResourceEvent;
	import reprise.external.BitmapResource;
	import reprise.external.IResource;

	import flash.display.BitmapData;
	import flash.events.Event;

	public class Image extends BitmapElement
	{
		//----------------------             Public Properties              ----------------------//
		public static const className:String = "img";
		
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _imageLoader:BitmapResource;
		protected var _loaded : Boolean;
		
		protected var _priority : int = 0;
		private var _cacheBitmap : Boolean = true;

		
		//----------------------               Public Methods               ----------------------//
		public function Image()
		{
		}
		
		public function setSrc(src : String) : void
		{
			if (!src)
			{
				return;
			}
			src = document.resolveURL(src);
			_loaded = false;
			if (_imageLoader)
			{
				_imageLoader.cancel();
			}
			_imageLoader = new BitmapResource();
			_imageLoader.priority = _priority;
			_imageLoader.setCacheBitmap(_cacheBitmap);
			_imageLoader.setURL(src);
			_imageLoader.addEventListener(Event.COMPLETE, imageLoaded);
			_imageLoader.execute();
		}
		
		/**
		 * Obsolete as BitmapResource now checks for a policy file by default
		 */
		public function setCheckPolicyFile(checkPolicyFile : Boolean) : void
		{
		}
		/**
		 * Obsolete as BitmapResource now checks for a policy file by default. Always returns true.
		 */
		public function checkPolicyFile() : Boolean
		{
			return true;
		}
		
		public function setCacheBitmap(cacheBitmap : Boolean) : void
		{
			_cacheBitmap = cacheBitmap;
		}
		public function cacheBitmap() : Boolean
		{
			return _cacheBitmap;
		}
		
		public function setPriority(value : int) : void
		{
			_priority = value;
			if (_imageLoader)
			{
				_imageLoader.priority = value;
			}
		}
		
		public function loader() : IResource
		{
			return _imageLoader;
		}

		override public function remove(...args : *) : void
		{
			if (_imageLoader)
			{
				_imageLoader.cancel();
				_imageLoader.removeEventListener(Event.COMPLETE, imageLoaded);
				_imageLoader = null;
			}
			super.remove(args);
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected function imageLoaded(event : ResourceEvent) : void
		{
			if (!event.success)
			{
				dispatchEvent(new DisplayEvent(DisplayEvent.LOAD_FAIL));
				return;
			}
			_loaded = true;
			setBitmapData(BitmapData(_imageLoader.content()));
			_imageLoader.removeEventListener(Event.COMPLETE, imageLoaded);
			_imageLoader = null;
			dispatchEvent(new DisplayEvent(DisplayEvent.LOAD_COMPLETE));
		}

		override protected function applyInFlowChildPositions() : void
		{
			if (_loaded)
			{
				super.applyInFlowChildPositions();
			}
		}
	}
}