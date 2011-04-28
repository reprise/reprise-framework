/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css.transitions
{
	public class PropertyTransitionVO
	{//----------------------       Private / Protected Properties       ----------------------//
		protected var _startValue : *;
		protected var _endValue : *;
		protected var _currentValue : *;
		
		
		//----------------------               Public Methods               ----------------------//
		public function PropertyTransitionVO()
		{
		}
		
		public function get startValue() : *
		{
			return _startValue;
		}
		public function set startValue(value : *) : void
		{
			_startValue = value;
		}
		
		public function get endValue() : *
		{
			return _endValue;
		}
		public function set endValue(value : *) : void
		{
			_endValue = value;
		}
		
		public function get currentValue() : *
		{
			return _currentValue;
		}
		public function set currentValue(value : *) : void
		{
			_currentValue = value;
		}
		
		public function setCurrentValueToRatio(ratio : Number) : *
		{
			//has to be implemented in child classes
			return _currentValue;
		}
	}
}