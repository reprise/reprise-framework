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
	public class ColorListTransitionVO extends PropertyTransitionVO
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_transitions : Array;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public override function set startValue(value : *) : void
		{
			m_startValue = value;
			m_transitions = null;
		}
		public override function set endValue(value : *) : void
		{
			m_endValue = value;
			m_transitions = null;
		}
		
		public function ColorListTransitionVO()
		{
		}
		
		public override function setCurrentValueToRatio(ratio : Number) : *
		{
			var startValues : Array = startValue as Array;
			var endValues : Array = endValue as Array;
			var currentValues : Array = currentValue as Array;
			
			var i : int;
			var transition : ColorTransitionVO;
			if (!m_transitions)
			{
				m_transitions = [];
				i = startValues.length;
				while (i--)
				{
					transition = new ColorTransitionVO();
					transition.startValue = startValues[i];
					transition.endValue = endValues[i];
					transition.currentValue = currentValues[i];
					m_transitions[i] = transition;
				}
			}
			i = m_transitions.length;
			while (i--)
			{
				transition = m_transitions[i];
				transition.setCurrentValueToRatio(ratio);
			}
			
			return currentValue;
		}
	}
}