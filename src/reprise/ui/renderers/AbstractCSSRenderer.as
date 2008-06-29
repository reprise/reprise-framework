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

package reprise.ui.renderers { 
	import reprise.css.CSSDeclaration;
	
	import flash.display.Sprite;
	public class AbstractCSSRenderer
		implements ICSSRenderer
	{
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_styles : Object;
		protected var m_complexStyles : CSSDeclaration;
		protected var m_width : Number;
		protected var m_height : Number;
		protected var m_display : Sprite;
	
		protected var m_id : String;
			
	
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function setId(id : String) : void
		{
			m_id = id;
		}
	
		public function id() : String
		{
			return m_id;
		}
		
		public function styles() : Object
		{
			return m_styles;
		}
	
		public function setStyles(val : Object) : void
		{
			m_styles = val;
		}
		
		public function complexStyles() : CSSDeclaration
		{
			return m_complexStyles;
		}
	
		public function setComplexStyles(val : CSSDeclaration) : void
		{
			m_complexStyles = val;
		}
		
		public function display() : Sprite
		{
			return m_display;
		}
	
		public function setDisplay(val : Sprite) : void
		{
			m_display = val;
		}
		
		public function width() : Number
		{
			return m_width;
		}
	
		public function setWidth(val : Number) : void
		{
			m_width = val;
		}
		
		public function height() : Number
		{
			return m_height;
		}
	
		public function setHeight(val : Number) : void
		{
			m_height = val;
		}
		
		public function setSize(w : Number, h : Number) : void
		{
			m_width = w;
			m_height = h;
		}
		
		public function draw() : void
		{
			throw new Error('Cannot call draw of AbstractCSSRenderer directly!');
		}
		
		public function destroy() : void
		{
		}
		
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function AbstractCSSRenderer() {}
	
	}
}