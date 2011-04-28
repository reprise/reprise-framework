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
		protected var m_startValue : *;
		protected var m_endValue : *;
		protected var m_currentValue : *;
		
		
		//----------------------               Public Methods               ----------------------//
		public function PropertyTransitionVO()
		{
		}
		
		public function get startValue() : *
		{
			return m_startValue;
		}
		public function set startValue(value : *) : void
		{
			m_startValue = value;
		}
		
		public function get endValue() : *
		{
			return m_endValue;
		}
		public function set endValue(value : *) : void
		{
			m_endValue = value;
		}
		
		public function get currentValue() : *
		{
			return m_currentValue;
		}
		public function set currentValue(value : *) : void
		{
			m_currentValue = value;
		}
		
		public function setCurrentValueToRatio(ratio : Number) : *
		{
			//has to be implemented in child classes
			return m_currentValue;
		}
	}
}