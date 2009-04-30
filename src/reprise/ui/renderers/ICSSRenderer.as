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

package reprise.ui.renderers
{	
	import reprise.css.CSSDeclaration;
	import reprise.css.ComputedStyles;

	import flash.display.Sprite;

	public interface ICSSRenderer
	{
		function setId(id:String) : void;
		function id() : String;
		
		function setWidth(width : Number) : void;
		function width() : Number;
		function setHeight(height : Number) : void;
		function height() : Number;
		function setSize(width : Number, height : Number) : void;
		
		function setStyles(styles : ComputedStyles) : void;
		function styles() : ComputedStyles;
		function setComplexStyles(styles : CSSDeclaration) : void;
		function complexStyles() : CSSDeclaration;
		function setDisplay(display : Sprite) : void;
		function display() : Sprite;
		
		function draw() : void;
		
		function destroy() : void;
	}
}