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
	
	import reprise.controls.Slider;
	import reprise.ui.UIComponent;
	
	
	public class MediaSlider extends Slider
	{
		
		protected var m_loadStatusBar:UIComponent;
		protected var m_loadValue:Number = 0;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function MediaSlider() {}
		
		
		public override function setValue(value:Number):void
		{
			value = Math.min(value, m_maxValue / 100 * m_loadValue);
			super.setValue(value);
		}
		
		public function setLoadValue(status:Number):void
		{
			status = Math.max(0, status);
			status = Math.min(100, status);
			m_loadValue = status;
			applyLoadValue();
		}
		
		public function loadValue():Number
		{
			return m_loadValue;
		}
		
		
		
		/***************************************************************************
		*							protected methods							   *
		***************************************************************************/
		protected override function createTrack():void
		{
			super.createTrack();
			m_loadStatusBar = addComponent('load_status_bar');
		}
		
		protected override function beforeFirstDraw():void
		{
			applyLoadValue();
		}
		
		protected function applyLoadValue():void
		{
			m_loadStatusBar.width = valueToPosition(m_loadValue, 0, 100);
		}
	}
}