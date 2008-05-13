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

package reprise.css
{ 
	import reprise.data.AdvancedColor;
	import reprise.data.URL;
	import reprise.utils.PathUtil;
	import reprise.utils.StringUtil;
	
	public class CSSParsingHelper
	{
		public static var percentageExpression : RegExp = /\d+%/;
		public static var lengthExpression : RegExp = /\d+px|\d+/;
		public static var URIExpression : RegExp = 
			/(?:url\([ ]*(['"]).*\1[ ]*\)|url\([ ]*[^'"][^)]*\))/;
		public static var repeatExpression : RegExp = 
			/repeat[-]x|repeat[-]y|no[-]repeat|repeat/;
		
		public static var positionExpression : RegExp = 
			new RegExp('(?:(?:left|center|right|' + 
			CSSParsingHelper.percentageExpression.source + '|' + 
			CSSParsingHelper.lengthExpression.source + 
			')[ ]?(?:center|top|bottom|' + CSSParsingHelper.percentageExpression.source + 
			'|' + CSSParsingHelper.lengthExpression.source + ')?)|' + 
			'(?:(?:left|center|right|top|bottom)[ ]?(?:left|center|right|top|bottom)?)');
		
		public static var attachmentExpression : RegExp = /scroll|fixed/;
		public static var preloadExpression : RegExp = /no[-]preload|preload/;
		
		
		protected static var g_colorExpression : RegExp;
		
		public function CSSParsingHelper() {}
		
		
		public static function parseColor(str:String) : AdvancedColor
		{
			var clr : AdvancedColor = new AdvancedColor();
			clr.setColorString(str);
			return clr;
		}	
		
		
		public static function parseURL(str:String, file:String) : String
		{				
			var url:String = StringUtil.stringBetweenMarkers(str, '(', ')', true);
			if (url == null)
			{
				return str;
			}
			url = resolvePathAgainstPath(url, file);
			return url;
		}
		
		public static function removeImportantFlagFromString(str:String) : Object
		{
			var important : Boolean = false;
			var index : Number = str.indexOf( CSSProperty.IMPORTANT_FLAG );
			
			if ( index > -1 && index == str.length - CSSProperty.IMPORTANT_FLAG.length )
			{
				important = true;
				str = str.substr( 0, -CSSProperty.IMPORTANT_FLAG.length );
			}
			
			return { important : important, result : str };
		}
		
		public static function valueIsColor(val:String) : Boolean
		{
			val = val.toLowerCase();
			if (val.indexOf('#') == 0 ||
				val.indexOf('rgb') == 0 ||
				val == 'transparent' ||
				AdvancedColor.g_htmlColors[val] != null)
			{
				return true;
			}
			return false;
		}
		
		public static function resolvePathAgainstPath(targetPath:String, sourcePath:String) : String
		{
			var targetURL : URL = new URL(targetPath);
			if (!targetURL.isFileURL())
			{
				// sourcePath is an absolute URL
				if (targetURL.scheme() != null)
				{
					return targetPath;
				}
				else if (PathUtil.isAbsolutePath(targetPath))
				{
					return targetPath;
				}
			}
			else
			{
				targetPath = targetURL.path();
			}
			
			var sourceURL : URL = new URL(sourcePath);
			var sourceIsURL : Boolean = sourceURL.scheme() != null || sourceURL.isFileURL();
	
			if (sourceIsURL)
			{
				sourcePath = sourceURL.path();
			}
			
			if (PathUtil.pathExtension(sourcePath) != '')
			{
				sourcePath = PathUtil.stringByDeletingLastPathComponent(sourcePath);
			}
			
			var absolutePath : String = PathUtil.absolutePathToBase(targetPath, sourcePath);
	
			if (!sourceIsURL)
			{
				return absolutePath;
			}
	
			var host : String = sourceURL.host() || '';
			return (sourceURL.scheme() || '') + host + absolutePath;
		}
		
		public static function extractUnitFromString(str:String) : String
		{
			var unit : String;
			
			if ( str.indexOf( CSSProperty.UNIT_PIXEL ) != -1 )
				return CSSProperty.UNIT_PIXEL;
			if ( str.indexOf( CSSProperty.UNIT_PERCENT ) != -1 )
				return CSSProperty.UNIT_PERCENT;
			else if ( str.indexOf( CSSProperty.UNIT_EM ) != -1 )
				return CSSProperty.UNIT_EM;
			
			return null;
		}
		
		public static function valueShouldInherit(str:String) : Boolean
		{
			return str.indexOf( CSSProperty.INHERIT_FLAG ) > -1;
		}
		
		public static function parseDeclarationString(
			declarationString : String, url : String) : CSSDeclaration
		{
			var declaration : CSSDeclaration = new CSSDeclaration();
			
			var splitter : RegExp = /([\w\-]+)\s*[:]\s*(.+)[;]/g;
			while (true)
			{
				var result : Array = splitter.exec(declarationString);
				if (!result)
				{
					break;
				}
				var name : String = camelCaseCSSValueName(result[1]);
				var value : String = result[2];
				declaration.setValueForKeyDefinedInFile(value, name, url);
			}
			return declaration;
		}
		
		public static function camelCaseCSSValueName(name : String) : String
		{
			var nameParts : Array = name.split('-');
			for (var i : int = nameParts.length; i-- > 1;)
			{
				var part : String = nameParts[i];
				nameParts[i] = part.charAt(0).toUpperCase() + part.substr(1);
			}
			return nameParts.join('');
		}
		
		public static function get colorExpression() : RegExp
		{
			if (!g_colorExpression)
			{
				var expression : String = 
					'(?:#[0-9abcdefABCDEF]{8}|#[0-9abcdefABCDEF]{6}|' + 
					'#[0-9abcdefABCDEF]{4}|#[0-9abcdefABCDEF]{3})(?!\\d)|' + 
					'rgb\\(\\s*\\d+%?\\s*,\\s*\\d+%?\\s*,\\s*\\d+%?\\s*\\)|' + 
					'rgba\\(\\s*\\d+%?\\s*,\\s*\\d+%?\\s*,\\s*\\d+%?\\s*,\\s*[0-9.]*%?\\s*\\)';
				var colorNames : Object = AdvancedColor.g_htmlColors;
				for (var name : String in colorNames)
				{
					expression += '|' + name;
				}
				g_colorExpression = new RegExp(expression);
			}
			return g_colorExpression;
		}
	}
}