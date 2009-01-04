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
	import flash.utils.Dictionary;	
	
	import reprise.core.reprise;
	
	use namespace reprise;
	
	internal class CSSDeclarationList
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_items : Array;
		protected var m_declarationIndex : Number = 0;
		protected var m_declarationCache : Array;
		protected var m_selectorHeadParts : Object = {};	

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSDeclarationList()
		{
			m_items = [];
			m_declarationCache = [];
		}
		
		reprise function addDeclaration(
			declaration : CSSDeclaration, selector : String) : void
		{
			var item : CSSDeclarationListItem = 
				new CSSDeclarationListItem(selector, declaration, m_declarationIndex++);
			var selectorHead : String = selector.split(' ').pop().
				split('#').join('@#').split('.').join('@.').split(':').join('@:');
			var parts : Array = selectorHead.split('@');
			for each (var part : String in parts)
			{
				if (!part)
				{
					continue;
				}
				if (!m_selectorHeadParts[part])
				{
					m_selectorHeadParts[part] = [];
				}
				m_selectorHeadParts[part].push(item);
			}
			m_items.push(item);
		}
		
		reprise function getStyleForSelectorsPath(sp:String) : CSSDeclaration
		{
			// prefer cached results
			var decl : CSSDeclaration = m_declarationCache[ sp ];
			if (decl)
			{
				return decl;
			}
			
			var matches : Array = [];
			var checks : Dictionary = new Dictionary(true);
			var i : int = m_items.length;
			var item : CSSDeclarationListItem;
	 		decl = new CSSDeclaration();
	 		var endParts : Array = sp.split(' ').pop().split('@');
			
			i = endParts.length;
			while (i--)
			{
				var items : Array = m_selectorHeadParts[endParts[i]];
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
	
			matches.sortOn(['declarationSpecificity', 'declarationIndex'], 
				Array.NUMERIC | Array.DESCENDING);
			i = matches.length;
			var matchesHash : String = matches.toString();
			
			if (m_declarationCache[matchesHash])
			{
				decl = m_declarationCache[matchesHash];
				m_declarationCache[sp] = decl;
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
			m_declarationCache[sp] = decl;
			m_declarationCache[matchesHash] = decl;
			
			return decl;
		}
		
//		public function getStyleForStylableElement(
//			element : ICSSStylable) : CSSDeclaration
//		{
//			// prefer cached results
//			var cachedResult : CSSDeclaration = 
//				CSSDeclaration(m_declarationCache[element.selectorPath]);
//			if (cachedResult)
//			{
//				return cachedResult;
//			}
//			
//			var declaration : CSSDeclaration = new CSSDeclaration();
//			
//			var path : String = element.selectorPath;
//			var i : Number = m_items.length;
//			var item : CSSDeclarationListItem;
//			var matches : Array = [];
//			
//			while (i--)
//			{
//				item = m_items[i];
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
//			m_declarationCache[element.selectorPath] = declaration;
//			
//			return declaration;
//		}
	}
}