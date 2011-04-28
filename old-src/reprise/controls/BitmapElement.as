/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.controls
{
	import reprise.core.reprise;
	import reprise.ui.UIComponent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	use namespace reprise;
	 
	public class BitmapElement extends UIComponent
	{
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _smoothing : Boolean = true;
		protected var _image : Bitmap;
		protected var _imageDisplayed : Boolean;

		
		//----------------------               Public Methods               ----------------------//
		public function setSmoothing(enabled : Boolean) : void
		{
			_smoothing = enabled;
			if (_image)
			{
				setBitmapData(_image.bitmapData);
			}
		}
		
		public function setBitmapData(bmpData : BitmapData) : void
		{
			createBitmapDisplay(bmpData);
		}
		
		public function bitmapData() : BitmapData
		{
			if (!_image)
			{
				return null;
			}
			return _image.bitmapData;
		}
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function initDefaultStyles() : void
		{
			_elementDefaultStyles.setStyle('display', 'inline');
		}
		
		protected function createBitmapDisplay(bmpData : BitmapData) : void
		{
			var oldWidth : int;
			var oldHeight : int;
			
			!_lowerContentDisplay && createLowerContentDisplay();
			if (_image && _image.parent)
			{
				oldWidth = _image.width;
				oldHeight = _image.height;
				_image.parent.removeChild(_image);
			}
			_image = new Bitmap(bmpData, 'auto', _smoothing);
			_lowerContentDisplay.addChild(_image);
			if (!_firstDraw)
			{
				validateAfterChildren();
			}
		}

		override protected function applyInFlowChildPositions() : void
		{
			if (!(_image && _image.bitmapData))
			{
				return;
			}
			if (!_imageDisplayed)
			{
				_imageDisplayed = true;
				_lowerContentDisplay.visible = true;
			}
			_image.x = _currentStyles.paddingLeft;
			_image.y = _currentStyles.paddingTop;
			if (_autoFlags.height)
			{
				_image.height = _image.bitmapData.height;
			}
			else
			{
				_image.height = _currentStyles.height;
			}
			if (_autoFlags.width)
			{
				_image.width = _image.bitmapData.width;
			}
			else
			{
				_image.width = _currentStyles.width;
			}
		}
		override protected function applyOutOfFlowChildPositions() : void
		{
		}
		
		override reprise function innerWidth() : int
		{
			return _contentBoxWidth;
		}
		override reprise function innerHeight() : int
		{
			return _contentBoxHeight;
		}

		protected override function measure() : void
		{
			if (!_imageDisplayed)
			{
				_intrinsicWidth = 0;
				_intrinsicHeight = 0;
				return;
			}
			_intrinsicWidth = _image.bitmapData.width;
			_intrinsicHeight = _image.bitmapData.height;
		}
	}
}
