/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css
{
	import flash.utils.Dictionary;	
	
	import reprise.core.reprise;
	
	use namespace reprise;
	
	internal class CSSDeclarationList
	{//----------------------       Private / Protected Properties       ----------------------//
		protected var _items : Array;
		protected var _declarationIndex : int = 0;
		protected var _declarationCache : Array;
		protected var _selectorHeadParts : Object = {};
		protected var _starSelectors : Array = [];

		
		//----------------------               Public Methods               ----------------------//
		public function CSSDeclarationList()
		{
			_items = [];
			_declarationCache = [];
		}
		
		reprise function addDeclaration(
			declaration : CSSDeclaration, selector : String) : void
		{
			var item : CSSDeclarationListItem = 
				new CSSDeclarationListItem(selector, declaration, _declarationIndex++);
			var selectorHead : String = selector.split(' ').pop().
				split('#').join('@#').split('.').join('@.').split(':').join('@:');
			var parts : Array = selectorHead.split('@');
			for each (var part : String in parts)
			{
				if (!part)
				{
					continue;
				}
				if (part == '*')
				{
					_starSelectors.push(item);
					continue;
				}
				if ('.:#'.indexOf(part.charAt(0)) == -1)
				{
					part = part.toLowerCase();
				}
				if (!_selectorHeadParts[part])
				{
					_selectorHeadParts[part] = [];
				}
				_selectorHeadParts[part].push(item);
			}
			_items.push(item);
		}
		
		reprise function getStyleForSelectorsPath(sp:String) : CSSDeclaration
		{
			// prefer cached results
			var decl : CSSDeclaration = _declarationCache[ sp ];
			if (decl)
			{
				return decl;
			}
			
			var matches : Array = [];
			var checks : Dictionary = new Dictionary(true);
			var item : CSSDeclarationListItem;
	 		decl = new CSSDeclaration();
	 		var endParts : Array = sp.split(' ').pop().split('@');
			
			for (var i : int = endParts.length; i--;)
			{
				var items : Array = _selectorHeadParts[endParts[i]];
				if (!items)
				{
					continue;
				}
				for (var j : int = items.length; j--;)
				{
					item = items[j];
					if (item && !checks[item])
					{
						checks[item] = true;
						if (item.matchesSubjectPath(sp))
						{
							matches.push(item);
						}
					}
				}
			}
			for (j = _starSelectors.length; j--;)
			{
				item = _starSelectors[j];
				if (item && !checks[item])
				{
					checks[item] = true;
					if (item.matchesSubjectPath(sp))
					{
						matches.push(item);
					}
				}
			}
	
			matches.sortOn(['declarationSpecificity', 'declarationIndex'], 
				Array.NUMERIC | Array.DESCENDING);
			i = matches.length;
			var matchesHash : String = matches.toString();
			
			if (_declarationCache[matchesHash])
			{
				decl = _declarationCache[matchesHash];
				_declarationCache[sp] = decl;
				return CSSDeclaration(decl);
			}
			if (i == 1)
			{
				decl = CSSDeclarationListItem(matches[0]).declaration();
			}
			else
			{
				while (i--)
				{
					decl.mergeCSSDeclaration(CSSDeclarationListItem(matches[i]).declaration());
				}
			}
			
			// cache result
			_declarationCache[sp] = decl;
			_declarationCache[matchesHash] = decl;
			
			return decl;
		}
		
//		public function getStyleForStylableElement(
//			element : ICSSStylable) : CSSDeclaration
//		{
//			// prefer cached results
//			var cachedResult : CSSDeclaration = 
//				CSSDeclaration(_declarationCache[element.selectorPath]);
//			if (cachedResult)
//			{
//				return cachedResult;
//			}
//			
//			var declaration : CSSDeclaration = new CSSDeclaration();
//			
//			var path : String = element.selectorPath;
//			var i : int = _items.length;
//			var item : CSSDeclarationListItem;
//			var matches : Array = [];
//			
//			while (i--)
//			{
//				item = _items[i];
//				if (item.matchesElement(element))
//				{
//					matches.push(item);
//				}
//			}
//	
//			matches.sortOn(['declarationSpecificity', 'declarationIndex'], 
//				Array.NUMERIC);
//			i = matches.length;
//			
//			while (i--)
//			{
//				declaration.
//					mergeCSSDeclaration(CSSDeclarationListItem(matches[i]).declaration());
//			}
//			
//			// cache result
//			_declarationCache[element.selectorPath] = declaration;
//			
//			return declaration;
//		}
	}
}