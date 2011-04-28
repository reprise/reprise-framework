/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css.transitions
{
	public class ColorListTransitionVO extends PropertyTransitionVO
	{//----------------------       Private / Protected Properties       ----------------------//
		protected var _transitions : Array;
		
		
		//----------------------               Public Methods               ----------------------//
		public override function set startValue(value : *) : void
		{
			_startValue = value;
			_transitions = null;
		}
		public override function set endValue(value : *) : void
		{
			_endValue = value;
			_transitions = null;
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
			if (!_transitions)
			{
				_transitions = [];
				i = startValues.length;
				while (i--)
				{
					transition = new ColorTransitionVO();
					transition.startValue = startValues[i];
					transition.endValue = endValues[i];
					transition.currentValue = currentValues[i];
					_transitions[i] = transition;
				}
			}
			i = _transitions.length;
			while (i--)
			{
				transition = _transitions[i];
				transition.setCurrentValueToRatio(ratio);
			}
			
			return currentValue;
		}
	}
}