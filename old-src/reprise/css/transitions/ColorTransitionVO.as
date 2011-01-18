/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css.transitions
{
	import reprise.utils.ColorUtil;

	public class ColorTransitionVO extends PropertyTransitionVO
	{
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function ColorTransitionVO()
		{
		}
		
		public override function setCurrentValueToRatio(ratio : Number) : *
		{
			var startColorRGB : Object = ColorUtil.number2rgbObject(startValue);
			var endColorRGB : Object = ColorUtil.number2rgbObject(endValue);
			
			var r : Number = startColorRGB.r + (endColorRGB.r - startColorRGB.r) * ratio;
			var g : Number = startColorRGB.g + (endColorRGB.g - startColorRGB.g) * ratio;
			var b : Number = startColorRGB.b + (endColorRGB.b - startColorRGB.b) * ratio;
			var a : Number = startValue.opacity() + 
				(endValue.opacity() - startValue.opacity()) * ratio;
			
			currentValue.setRGBAComponents(r, g, b, a);
			return currentValue;
		}
	}
}