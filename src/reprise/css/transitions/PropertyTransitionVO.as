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
	public class PropertyTransitionVO
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_startValue : *;
		protected var m_endValue : *;
		protected var m_currentValue : *;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
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