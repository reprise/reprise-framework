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

package reprise.tweens
{
	import reprise.utils.ColorUtil;
	
	
	public class ColorTweenPropertyVO extends TweenedPropertyVO
	{
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function ColorTweenPropertyVO(
			scope:Object, property:String, startValue:Number, 
			targetValue:Number, tweenFunction:Function, roundResults:Boolean, 
			propertyIsMethod:Boolean, extraParams:Array)
		{
			super(scope, property, startValue, targetValue, tweenFunction, 
				roundResults, propertyIsMethod, extraParams);
		}
			
		
		/***************************************************************************
		*							private methods								   *
		***************************************************************************/
		private function tweenedValue(duration:Number, time:Number) : Number
		{
			var args : Array = [time, 0, 1, duration].concat(extraParams);
			var percent : Number = tweenFunction.apply(null, args);
			
			var startColorRGB : Object = ColorUtil.number2rgbObject(startValue);
			var endColorRGB : Object = ColorUtil.number2rgbObject(targetValue);
			var currentColorRGB : Object = {};
			
			currentColorRGB.r = startColorRGB.r + 
				(endColorRGB.r - startColorRGB.r) * percent;
			currentColorRGB.g = startColorRGB.g + 
				(endColorRGB.g - startColorRGB.g) * percent;
			currentColorRGB.b = startColorRGB.b + 
				(endColorRGB.b - startColorRGB.b) * percent;
			
			return ColorUtil.rgbObject2Number(currentColorRGB);
		}
	}
}