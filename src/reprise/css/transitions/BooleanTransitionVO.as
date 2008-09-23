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
	public class BooleanTransitionVO extends PropertyTransitionVO
	{
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function BooleanTransitionVO()
		{
		}
		
		public override function setCurrentValueToRatio(ratio : Number) : *
		{
			return ratio == 1 ? endValue : startValue;
		}
	}
}