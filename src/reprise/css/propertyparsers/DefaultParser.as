/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css.propertyparsers
{
	import reprise.core.reprise;
	import reprise.css.CSSProperty;
	import reprise.css.CSSPropertyParser; 
	
	use namespace reprise;
	
	public class DefaultParser extends CSSPropertyParser
	{
		public static function parseAnything(
				val:String, selector : String, file:String) : CSSProperty
		{
			return strToStringProperty(val, selector, file);
		}	
	}
}