/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css.transitions
{
	public class VisibilityTransitionVO extends PropertyTransitionVO
	{
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function VisibilityTransitionVO()
		{
		}
		
		public override function setCurrentValueToRatio(ratio : Number) : *
		{
			if (startValue == 'hidden' || startValue == 'none')
			{
				return ratio == 0 ? startValue : endValue;
			}
			return ratio == 1 ? endValue : startValue;
		}
	}
}