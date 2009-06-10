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

package reprise.controls.html
{
	import reprise.controls.BitmapElement;
	import reprise.css.CSSParsingHelper;
	import reprise.events.DisplayEvent;
	import reprise.events.ResourceEvent;
	import reprise.external.BitmapResource;

	import flash.display.BitmapData;
	import flash.events.Event;

	public class Image extends BitmapElement
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const className:String = "img";
		
		
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		protected var m_imageLoader:BitmapResource;
		protected var m_loaded : Boolean;
		
		protected var m_priority : int = 0;
		protected var m_checkPolicyFile : Boolean;
		private var m_cacheBitmap : Boolean = true;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function Image()
		{
		}
		
		public function setSrc(src : String) : void
		{
			if (!src)
			{
				return;
			}
			src = CSSParsingHelper.resolvePathAgainstPath(src, m_xmlURL);
			m_loaded = false;
			if (m_imageLoader)
			{
				m_imageLoader.cancel();
			}
			m_imageLoader = new BitmapResource();
			m_imageLoader.setCheckPolicyFile(m_checkPolicyFile);
			m_imageLoader.priority = m_priority;
			m_imageLoader.setCacheBitmap(m_cacheBitmap);
			m_imageLoader.setURL(src);
			m_imageLoader.addEventListener(Event.COMPLETE, imageLoaded);
			m_imageLoader.execute();
		}
		
		public function setCheckPolicyFile(checkPolicyFile : Boolean) : void
		{
			m_checkPolicyFile = checkPolicyFile;
		}
		public function checkPolicyFile() : Boolean
		{
			return m_checkPolicyFile;
		}
		
		public function setCacheBitmap(cacheBitmap : Boolean) : void
		{
			m_cacheBitmap = cacheBitmap;
		}
		public function cacheBitmap() : Boolean
		{
			return m_cacheBitmap;
		}
		
		public function setPriority(value : int) : void
		{
			m_priority = value;
			if (m_imageLoader)
			{
				m_imageLoader.priority = value;
			}
		}

		override public function remove(...args : *) : void
		{
			if (m_imageLoader)
			{
				m_imageLoader.cancel();
				m_imageLoader.removeEventListener(Event.COMPLETE, imageLoaded);
				m_imageLoader = null;
			}
			super.remove(args);
		}
		
		
		/***************************************************************************
		*							protected methods							   *
		***************************************************************************/
		protected function imageLoaded(event : ResourceEvent) : void
		{
			if (!event.success)
			{
				dispatchEvent(new DisplayEvent(DisplayEvent.LOAD_FAIL));
				return;
			}
			m_loaded = true;
			setBitmapData(BitmapData(m_imageLoader.content()));
			m_imageLoader.removeEventListener(Event.COMPLETE, imageLoaded);
			m_imageLoader = null;
			dispatchEvent(new DisplayEvent(DisplayEvent.LOAD_COMPLETE));
		}

		override protected function applyInFlowChildPositions() : void
		{
			if (m_loaded)
			{
				super.applyInFlowChildPositions();
			}
		}
	}
}