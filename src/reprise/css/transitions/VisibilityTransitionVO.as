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
			if (startValue == 'hidden')
			{
				return ratio == 0 ? startValue : endValue;
			}
			if (startValue == 'none')
			{
				return endValue;
			}
			return ratio == 1 ? endValue : startValue;
		}
	}
}