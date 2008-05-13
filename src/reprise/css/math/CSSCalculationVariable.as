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

/**
 * @author till
 */
package reprise.css.math
{
	public class CSSCalculationVariable 
		extends AbstractCSSCalculation 
	{
		/***************************************************************************
		*							private properties							   *
		***************************************************************************/
		private var m_selector : String;
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSCalculationVariable(selector : String)
		{
			m_selector = selector.substr(1, -2);
		}
		
		public override function resolve(
			reference : Number, context : ICSSCalculationContext = null) : Number
		{
			return context.valueBySelector(m_selector);
		}
		
		public function toString() : String
		{
			return "CSSCalculationVariable, selector: " + m_selector;
		}
	}
}