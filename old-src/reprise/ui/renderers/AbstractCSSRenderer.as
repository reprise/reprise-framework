/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.ui.renderers 
{	
	import reprise.css.CSSDeclaration;
	import reprise.css.ComputedStyles;

	import flash.display.Sprite;

	public class AbstractCSSRenderer
		implements ICSSRenderer
	{
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _styles : ComputedStyles;
		protected var _complexStyles : CSSDeclaration;
		protected var _width : Number;
		protected var _height : Number;
		protected var _display : Sprite;
	
		protected var _id : String;
			
	
		
		//----------------------               Public Methods               ----------------------//
		public function setId(id : String) : void
		{
			_id = id;
		}
	
		public function id() : String
		{
			return _id;
		}
		
		public function styles() : ComputedStyles
		{
			return _styles;
		}
	
		public function setStyles(val : ComputedStyles) : void
		{
			_styles = val;
		}
		
		public function complexStyles() : CSSDeclaration
		{
			return _complexStyles;
		}
	
		public function setComplexStyles(val : CSSDeclaration) : void
		{
			_complexStyles = val;
		}
		
		public function display() : Sprite
		{
			return _display;
		}
	
		public function setDisplay(val : Sprite) : void
		{
			_display = val;
		}
		
		public function width() : Number
		{
			return _width;
		}
	
		public function setWidth(val : Number) : void
		{
			_width = val;
		}
		
		public function height() : Number
		{
			return _height;
		}
	
		public function setHeight(val : Number) : void
		{
			_height = val;
		}
		
		public function setSize(w : Number, h : Number) : void
		{
			_width = w;
			_height = h;
		}
		
		public function draw() : void
		{
			throw new Error('Cannot call draw of AbstractCSSRenderer directly!');
		}
		
		public function destroy() : void
		{
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		public function AbstractCSSRenderer() {}
	
	}
}