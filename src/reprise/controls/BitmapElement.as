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

package reprise.controls
{
	import reprise.core.reprise;
	import reprise.ui.UIComponent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	use namespace reprise;
	 
	public class BitmapElement extends UIComponent
	{
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		protected var m_smoothing : Boolean = true;
		protected var m_image : Bitmap;
		protected var m_imageDisplayed : Boolean;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function setSmoothing(enabled : Boolean) : void
		{
			m_smoothing = enabled;
			if (m_image)
			{
				setBitmapData(m_image.bitmapData);
			}
		}
		
		public function setBitmapData(bmpData : BitmapData) : void
		{
			createBitmapDisplay(bmpData);
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
		
		protected function createBitmapDisplay(bmpData : BitmapData) : void
		{
			!m_lowerContentDisplay && createLowerContentDisplay();
			if (!m_firstDraw)
			{
				m_imageDisplayed = false;
				m_lowerContentDisplay.visible = false;
			}
			if (m_image && m_image.parent)
			{
				m_image.parent.removeChild(m_image);
			}
			m_image = new Bitmap(bmpData, 'auto', m_smoothing);
			m_lowerContentDisplay.addChild(m_image);
			invalidate();
		}

		override protected function applyInFlowChildPositions() : void
		{
			if (!(m_image && m_image.bitmapData))
			{
				return;
			}
			if (!m_imageDisplayed)
			{
				m_imageDisplayed = true;
				m_lowerContentDisplay.visible = true;
			}
			m_image.x = m_currentStyles.paddingLeft;
			m_image.y = m_currentStyles.paddingTop;
			if (m_autoFlags.height)
			{
				m_image.height = m_image.bitmapData.height;
			}
			else
			{
				m_image.height = m_currentStyles.height;
			}
			if (m_autoFlags.width)
			{
				m_image.width = m_image.bitmapData.width;
			}
			else
			{
				m_image.width = m_currentStyles.width;
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
			if (!m_imageDisplayed)
			{
				m_intrinsicWidth = 0;
				m_intrinsicHeight = 0;
				return;
			}
			m_intrinsicWidth = m_image.bitmapData.width;
			m_intrinsicHeight = m_image.bitmapData.height;
		}
	}
}
