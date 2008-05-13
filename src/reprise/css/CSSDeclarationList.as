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
	public class CSSDeclarationList
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_items : Array;
		protected	var m_declarationIndex : Number = 0;
		protected	var m_declarationCache : Array;	
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSDeclarationList()
		{
			m_items = [];
			m_declarationCache = [];		
		}
		
		public function addDeclaration(
			declaration : CSSDeclaration, selector : String) : void
		{
			m_items.push(
				new CSSDeclarationListItem(selector, declaration, m_declarationIndex++));
		}
		
		public function getStyleForSelectorsPath(sp:String) : CSSDeclaration
		{
			// prefer cached results
			var decl : CSSDeclaration = CSSDeclaration(m_declarationCache[ sp ]);
			if (decl)
			{
				return decl;
			}
			
			var matches : Array = [];
			var i : int = m_items.length;
			var item : CSSDeclarationListItem;
	 		decl = new CSSDeclaration();
			
			while (i--)
			{
				item = m_items[i];
				if (item.matchesSubjectPath(sp))
				{
					matches.push(item);
				}
			}
	
			matches.sortOn(['m_declarationSpecificity', 'm_declarationIndex'], 
				Array.NUMERIC | Array.DESCENDING);
			i = matches.length;
			
			while (i--)
			{
				decl.mergeCSSDeclaration(CSSDeclarationListItem(matches[i]).declaration());
			}
			
			// cache result
			m_declarationCache[sp] = decl;
			
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
//			matches.sortOn(['m_declarationSpecificity', 'm_declarationIndex'], 
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