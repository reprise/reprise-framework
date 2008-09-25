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

package reprise.css.propertyparsers
{
	import reprise.core.reprise;
	import reprise.css.CSSProperty;
	import reprise.css.CSSPropertyParser; 
	
	use namespace reprise;
	
	public class DefaultParser extends CSSPropertyParser
	{
		
		
		public static function get defaultValues() : Object
		{
			return null;
		}
		
		public static function parseAnything(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}	
	}
}