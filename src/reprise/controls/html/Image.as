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
	import reprise.core.reprise;
	import reprise.css.CSSParsingHelper;
	import reprise.events.DisplayEvent;
	import reprise.events.ResourceEvent;
	import reprise.external.BitmapResource;
	import reprise.ui.UIComponent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	
	use namespace reprise;

	public class Image extends UIComponent
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var className:String = "img";
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_imageLoader:BitmapResource;
		protected var m_image : Bitmap;
		
		protected var m_loaded : Boolean;
		protected var m_imageDisplayed : Boolean;
		
		protected var m_smoothing : Boolean = true;
		
		protected var m_priority : Number = 0;
		protected var m_checkPolicyFile : Boolean;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function Image()
		{
		}
		
		
		public function setSrc(src:String) : void
		{
			if (!src)
			{
				return;
			}
			src = CSSParsingHelper.resolvePathAgainstPath(src, m_xmlURL);
			m_loaded = false;
			m_imageLoader = new BitmapResource();
			m_imageLoader.setCheckPolicyFile(m_checkPolicyFile);
			m_imageLoader.priority = m_priority;
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
		
		public function setPriority(value : Number) : void
		{
			m_priority = value;
			if (m_imageLoader)
			{
				m_imageLoader.priority = value;
			}
		}
		
		public function setSmoothing(enabled : Boolean) : void
		{
			//TODO: found out how to enable smoothing
			m_smoothing = enabled;
		}
		
		public function bitmapData() : BitmapData
		{
			if (!m_image)
			{
				return null;
			}
			return m_image.bitmapData;
		}

		
		/***************************************************************************
		*							protected methods							   *
		***************************************************************************/
		protected override function initDefaultStyles() : void
		{
			m_elementDefaultStyles.setStyle('display', 'inline');
		}
		
		protected function imageLoaded(e:ResourceEvent):void
		{
			if (!e.success)
			{
				dispatchEvent(new DisplayEvent(DisplayEvent.LOAD_FAIL));
				return;
			}
			m_loaded = true;
			if (!m_firstDraw)
			{
				m_imageDisplayed = false;
				m_lowerContentDisplay.visible = false;
			}
			if (m_image)
			{
				m_lowerContentDisplay.removeChild(m_image);
			}
			m_image = new Bitmap(BitmapData(m_imageLoader.content()), 'auto', m_smoothing);
			m_lowerContentDisplay.addChild(m_image);
			invalidate();
			dispatchEvent(new DisplayEvent(DisplayEvent.LOAD_COMPLETE));
		}

		override protected function applyInFlowChildPositions() : void
		{
			if (m_loaded)
			{
				if (!m_imageDisplayed)
				{
					m_imageDisplayed = true;
					m_lowerContentDisplay.visible = true;
				}
				m_image.x = m_currentStyles.paddingLeft;
				m_image.y = m_currentStyles.paddingTop;
				if (m_autoFlags.height)
				{
					m_image.height = BitmapData(m_imageLoader.content()).height;
				}
				else
				{
					m_image.height = m_currentStyles.height;
				}
				if (m_autoFlags.width)
				{
					m_image.width = BitmapData(m_imageLoader.content()).width;
				}
				else
				{
					m_image.width = m_currentStyles.width;
				}
			}
		}
		override protected function applyOutOfFlowChildPositions() : void
		{
		}
		
		override reprise function innerWidth() : int
		{
			return m_contentBoxWidth;
		}
		override reprise function innerHeight() : int
		{
			return m_contentBoxHeight;
		}

		protected override function measure() : void
		{
			if (!(m_imageLoader && m_imageLoader.didSucceed()))
			{
				m_intrinsicWidth = 0;
				m_intrinsicHeight = 0;
				return;
			}
			m_intrinsicWidth = BitmapData(m_imageLoader.content()).width;
			m_intrinsicHeight = BitmapData(m_imageLoader.content()).height;
		}
	}
}