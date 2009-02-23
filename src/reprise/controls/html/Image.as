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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	
	import reprise.events.DisplayEvent;
	import reprise.events.ResourceEvent;
	import reprise.external.BitmapResource;
	import reprise.ui.UIComponent; 

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
			m_image = new Bitmap(BitmapData(m_imageLoader.content()));
			m_lowerContentDisplay.addChild(m_image);
			invalidate();
			dispatchEvent(new DisplayEvent(DisplayEvent.LOAD_COMPLETE));
		}
		
		protected override function measure() : void
		{
			if (!(m_imageLoader && m_imageLoader.didSucceed()))
			{
				m_intrinsicWidth = 0;
				m_intrinsicHeight = 0;
				return;
			}
			m_intrinsicWidth = m_image.width;
			m_intrinsicHeight = m_image.height;
		}

		protected override function draw() : void
		{
			if (m_loaded && !m_imageDisplayed)
			{
				m_image.x = m_currentStyles.paddingLeft || 0;
				m_image.y = m_currentStyles.paddingTop || 0;
				m_imageDisplayed = true;
				m_lowerContentDisplay.visible = true;
			}
		}
	}
}