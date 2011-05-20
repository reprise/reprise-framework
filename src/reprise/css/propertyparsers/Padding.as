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
	
	public class Padding extends CSSPropertyParser
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const KNOWN_PROPERTIES : Object =
		{
			padding : {parser : parsePadding},
			paddingTop : {parser : strToIntProperty},
			paddingRight : {parser : strToIntProperty},
			paddingBottom : {parser : strToIntProperty},
			paddingLeft : {parser : strToIntProperty}
		};
		public static var TRANSITION_SHORTCUTS : Object	=
		{
			padding : 
			[
				'paddingTop',
				'paddingRight',
				'paddingBottom',
				'paddingLeft'
			]
		};
	
		public static function parsePadding(
				val:String, selector:String, file:String) : CSSParsingResult
		{
			return strToRectParsingResult(
					val, selector, file, 'padding', '', strToIntProperty);
		}
	}
}