/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css.transitions
{
	public class BooleanTransitionVO extends PropertyTransitionVO
	{
		//----------------------               Public Methods               ----------------------//
		public function BooleanTransitionVO()
		{
		}
		
		public override function setCurrentValueToRatio(ratio : Number) : *
		{
			return ratio == 1 ? endValue : startValue;
		}
	}
}