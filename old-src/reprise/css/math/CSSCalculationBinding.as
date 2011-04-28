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
		protected var _selector : String;
		protected var _value : String;
		protected var _property : String;
		
		
		//----------------------               Public Methods               ----------------------//
		public function CSSCalculationBinding(value : String)
		{
			_value = value;
			value = value.substring(2, value.length - 2);
			var valueParts : Array = value.split(',');
			if (valueParts.length == 1)
			{
				_selector = '';
				_property = valueParts[0];
			}
			else
			{
				var selector : String = valueParts[0];
				var lastIDIndex : int = selector.lastIndexOf('#');
				if (lastIDIndex > -1)
				{
					selector = selector.substr(lastIDIndex);
				}
				_selector = selector;
				_property = valueParts[1];
			}
		}
		
		public override function resolve(
			reference : Number, context : ICSSCalculationContext = null) : Number
		{
			return context.valueBySelectorProperty(_selector, _property);
		}
		
		public function toString() : String
		{
			return "CSSCalculationBinding, value: " + _value;
		}
	}
}