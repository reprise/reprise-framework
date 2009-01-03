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

	/**
	 * @author till
	 */
	public dynamic class ComputedStyles 
	{
		public var top : int;
		public var right : int;
		public var bottom : int;
		public var left : int;
		
		public var width : int;
		public var height : int;
		
		public var marginTop : int;
		public var paddingTop : int;
		public var borderTopWidth : int;
//		public var borderTopStyle : String;
//		public var borderTopColor : AdvancedColor;
		
		public var marginRight : int;
		public var paddingRight : int;
		public var borderRightWidth : int;
//		public var borderRightStyle : String;
//		public var borderRightColor : AdvancedColor;
		
		public var marginBottom : int;
		public var paddingBottom : int;
		public var borderBottomWidth : int;
//		public var borderBottomStyle : String;
//		public var borderBottomColor : AdvancedColor;
		
		public var marginLeft : int;
		public var paddingLeft : int;
		public var borderLeftWidth : int;
//		public var borderLeftStyle : String;
//		public var borderLeftColor : AdvancedColor;
		
		public var borderTopLeftRadius : Number = 0;
		public var borderTopRightRadius : Number = 0;
		public var borderBottomLeftRadius : Number = 0;
		public var borderBottomRightRadius : Number = 0;
		
		public var visibility : String;
		public var display : String;
		public var float : String;
		public var zIndex : int = 0;
//		public var tooltipDelay : Number;
//		public var tooltipRenderer : String;
//		public var opacity : Number;
//		public var rotation : Number;
//		public var overflowY : String;
//		public var overflowX : String;
//		public var tabIndex : int;
//		public var blendMode : String;
//		public var textShadowColor : AdvancedColor;
//		public var cursor : String;
//		public var position : String;
		
		//TODO: remove need for these
//		public var intrinsicWidth : int;
//		public var intrinsicHeight : int;
//		public var scrollbarWidth : int;
		
//		public var boxSizing : String;
//		public var backgroundRenderer : String;
//		public var borderRenderer : String;
//		public var backgroundBlendMode : String;
//		public var frameRate : Number;
//		public var verticalAlign : String;
//		public var selectable : Boolean;
//		public var tabStops : String;
//		public var embedFonts : Boolean;
//		public var antiAliasType : String;
//		public var gridFitType : String;
//		public var sharpness : Number;
//		public var thickness : Number;
//		public var wordWrap : String;
//		public var multiline : Boolean;
//		public var cacheAsBitmap : Boolean;
//		public var autoHide : Boolean;
//		public var pageScrollSize : int;
//		public var lineScrollSize : int;
//		public var scaleScrollThumb : Boolean;
//		public var inputCharRestrict : String;
//		public var inputLengthRestrict : int;
//		public var backgroundColor : AdvancedColor;
//		public var backgroundGradientType : String;
//		public var backgroundGradientColors : Array;
//		public var backgroundGradientRatios : Array;
//		public var backgroundGradientRotation : Number;
//		public var backgroundImage : String;
//		public var backgroundShadowColor : AdvancedColor;
//		public var backgroundImageType : String;
//		public var backgroundRepeat : String;
//		public var backgroundPositionX : int = 0;
//		public var backgroundPositionY : int = 0;
//		public var backgroundScale9Type : String;
//		public var backgroundScale9RectTop : int;
//		public var backgroundScale9RectLeft : int;
//		public var backgroundScale9RectRight : int;
//		public var backgroundScale9RectBottom : int;
//		public var fontSize : Number;
//		public var fontFamily : String;
//		public var textTransform : String;
//		public var leading : Number;
//		public var textAlign : String;
//		public var textShadowYBlur : Number;
//		public var textShadowXBlur : Number;
//		public var textShadowXOffset : int;
//		public var textShadowYOffset : int;
//		public var textShadowStrength : Number;
//		public var textShadowQuality : Number;
//		public var textShadowInner : Boolean;
//		public var textShadowKnockout : Boolean;
//		public var textShadowHideObject : Boolean;
//		
//		public var RepriseTransitionDelay : Array;
//		public var RepriseTransitionProperty : Array;
//		public var RepriseTransitionDuration : Array;
//		public var RepriseTransitionDefaultValue : Array;
//		public var RepriseTransitionTimingFunction : Array;
//		
//		public var color : AdvancedColor;

//		public function diff(otherStyles : ComputedStyles) : Array
//		{
//			var changes : Array = [];
//			var ownProperties:Object = this;
//			var key : String;
//			if (!otherStyles)
//			{
//				for (key in ownProperties)
//				{
//					changes.push(key);
//					changes[key] = true;
//				}
//				return changes;
//			}
//			for (key in ownProperties)
//			{
//				if (ownProperties[key] != otherStyles[key])
//				{
//					changes.push(key);
//					changes[key] = true;
//				}
//			}
//			//we have to compare in both direction as for .. in doesn't allow us 
//			//to know if the other object has more properties
//			for (key in otherStyles)
//			{
//				if (!changes[key] && ownProperties[key] != otherStyles[key])
//				{
//					changes.push(key);
//					changes[key] = true;
//				}
//			}
//			return changes;
//		}
	}
}
