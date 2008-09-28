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
	
		public static function parsePadding(val:String, file:String) : CSSParsingResult
		{
			return strToRectParsingResult(
				val, file, 'padding', '', strToIntProperty);
		}
	}
}