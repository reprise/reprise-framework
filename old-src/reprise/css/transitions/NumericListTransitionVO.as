/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css.transitions
{
	public class NumericListTransitionVO extends PropertyTransitionVO
	{
		//----------------------               Public Methods               ----------------------//
		public function NumericListTransitionVO()
		{
		}
		
		public override function setCurrentValueToRatio(ratio : Number) : *
		{
			var i : int = (startValue as Array).length;
			while (i--)
			{
				currentValue[i] = startValue[i] + (endValue[i] - startValue[i]) * ratio;
			}
			
			return currentValue;
		}
	}
}