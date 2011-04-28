/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.controls
{
	
	import reprise.controls.Slider;
	import reprise.ui.UIComponent;
	
	
	public class MediaSlider extends Slider
	{
		
		protected var _loadStatusBar:UIComponent;
		protected var _loadValue:Number = 0;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function MediaSlider() {}
		
		
		public override function setValue(value:Number):void
		{
			value = Math.min(value, _maxValue / 100 * _loadValue);
			super.setValue(value);
		}
		
		public function setLoadValue(status:Number):void
		{
			status = Math.max(0, status);
			status = Math.min(100, status);
			_loadValue = status;
			applyLoadValue();
		}
		
		public function loadValue():Number
		{
			return _loadValue;
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function createTrack():void
		{
			super.createTrack();
			_loadStatusBar = addComponent('load_status_bar');
		}
		
		protected override function beforeFirstDraw():void
		{
			applyLoadValue();
		}
		
		protected function applyLoadValue():void
		{
			_loadStatusBar.width = valueToPosition(_loadValue, 0, 100);
		}
	}
}