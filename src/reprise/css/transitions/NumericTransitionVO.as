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
	public class NumericTransitionVO extends PropertyTransitionVO
	{
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function NumericTransitionVO()
		{
		}
		
		public override function setCurrentValueToRatio(ratio : Number) : *
		{
			currentValue = startValue + (endValue - startValue) * ratio;
			
			return currentValue;
		}
	}
}