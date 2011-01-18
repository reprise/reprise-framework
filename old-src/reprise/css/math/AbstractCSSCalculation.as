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
	public class AbstractCSSCalculation 
	{
		public function resolve(
			reference : Number, context : ICSSCalculationContext = null) : Number
		{
			//TODO: check if returned 0 is the better strategy
			return NaN;
		}
	}
}