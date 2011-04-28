/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

/**
 * @author till
 */
package reprise.css.math
{
	public class CSSCalculationBinding 
		extends AbstractCSSCalculation 
	{
		//----------------------       Private / Protected Properties       ----------------------//
		protected var m_selector : String;
		protected var m_value : String;
		protected var m_property : String;
		
		
		//----------------------               Public Methods               ----------------------//
		public function CSSCalculationBinding(value : String)
		{
			m_value = value;
			value = value.substring(2, value.length - 2);
			var valueParts : Array = value.split(',');
			if (valueParts.length == 1)
			{
				m_selector = '';
				m_property = valueParts[0];
			}
			else
			{
				var selector : String = valueParts[0];
				var lastIDIndex : int = selector.lastIndexOf('#');
				if (lastIDIndex > -1)
				{
					selector = selector.substr(lastIDIndex);
				}
				m_selector = selector;
				m_property = valueParts[1];
			}
		}
		
		public override function resolve(
			reference : Number, context : ICSSCalculationContext = null) : Number
		{
			return context.valueBySelectorProperty(m_selector, m_property);
		}
		
		public function toString() : String
		{
			return "CSSCalculationBinding, value: " + m_value;
		}
	}
}