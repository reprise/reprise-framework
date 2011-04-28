/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css.propertyparsers
{
	import reprise.core.reprise;
	import reprise.css.CSSParsingResult;
	import reprise.css.CSSPropertyParser;	
	
	use namespace reprise;
	
	public class Margin extends CSSPropertyParser
	{
		//----------------------             Public Properties              ----------------------//
		public static const KNOWN_PROPERTIES : Object =
		{
			margin : {parser : parseMargin},
			marginTop : {parser : strToIntProperty},
			marginRight : {parser : strToIntProperty},
			marginBottom : {parser : strToIntProperty},
			marginLeft : {parser : strToIntProperty}
		};
		public static var TRANSITION_SHORTCUTS : Object	=
		{
			margin : 
			[
				'marginTop',
				'marginRight',
				'marginBottom',
				'marginLeft'
			]
		};
		
		public static function parseMargin(val:String, file:String) : CSSParsingResult
		{
			return strToRectParsingResult(
				val, file, 'margin', '', strToIntProperty);
		}
	}
}