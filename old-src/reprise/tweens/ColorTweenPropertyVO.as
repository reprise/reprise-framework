/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.tweens
{
	import reprise.utils.ColorUtil;
	
	
	public class ColorTweenPropertyVO extends TweenedPropertyVO
	{
		//----------------------               Public Methods               ----------------------//
		public function ColorTweenPropertyVO(
			scope:Object, property:String, startValue:Number, 
			targetValue:Number, tweenFunction:Function, roundResults:Boolean, 
			propertyIsMethod:Boolean, extraParams:Array = null)
		{
			super(scope, property, startValue, targetValue, tweenFunction, 
				roundResults, propertyIsMethod, extraParams);
		}

		
		//----------------------       Private / Protected Properties       ----------------------//
		public override function tweenFunction(
			time:int, start:Number, change:Number, duration:int, ...rest) : Number
		{
			var args : Array = [time, 0, 1, duration].concat(extraParams);
			var percent : Number = super.tweenFunction.apply(null, args);
			
			var startColorRGB : Object = ColorUtil.number2rgbObject(startValue);
			var endColorRGB : Object = ColorUtil.number2rgbObject(targetValue);
			var currentColorRGB : Object = {};
			
			currentColorRGB.r = Math.round(startColorRGB.r + 
				(endColorRGB.r - startColorRGB.r) * percent);
			currentColorRGB.g = Math.round(startColorRGB.g + 
				(endColorRGB.g - startColorRGB.g) * percent);
			currentColorRGB.b = Math.round(startColorRGB.b + 
				(endColorRGB.b - startColorRGB.b) * percent);
			
			return ColorUtil.rgbObject2Number(currentColorRGB);
		}
	}
}