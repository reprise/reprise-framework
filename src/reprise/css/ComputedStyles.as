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

	public dynamic class ComputedStyles 
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const BASELINE : ComputedStyles = new ComputedStyles();
		
		
		public var top : Number;
		public var right : Number;
		public var bottom : Number;
		public var left : Number;
		
		public var width : int;
		public var height : int;
		
		public var intrinsicWidth : int;
		public var intrinsicHeight : int;
		
		public var collapsedMarginTop : int;
		public var marginTop : int;
		public var paddingTop : int;
		public var borderTopWidth : int = 0;
		public var borderTopStyle : String = 'none';
		public var borderTopColor : AdvancedColor;
		
		public var marginRight : int;
		public var paddingRight : int;
		public var borderRightWidth : int = 0;
		public var borderRightStyle : String = 'none';
		public var borderRightColor : AdvancedColor;
		
		public var collapsedMarginBottom : int;
		public var marginBottom : int;
		public var paddingBottom : int;
		public var borderBottomWidth : int = 0;
		public var borderBottomStyle : String = 'none';
		public var borderBottomColor : AdvancedColor;
		
		public var marginLeft : int;
		public var paddingLeft : int;
		public var borderLeftWidth : int = 0;
		public var borderLeftStyle : String = 'none';
		public var borderLeftColor : AdvancedColor;
		
		public var borderTopLeftRadius : Number = 0;
		public var borderTopRightRadius : Number = 0;
		public var borderBottomLeftRadius : Number = 0;
		public var borderBottomRightRadius : Number = 0;
		
		public var visibility : String = 'visible';
		public var display : String = 'block';
		public var float : String = 'none';
		public var zIndex : int = 0;
		public var tooltipDelay : Number;
		public var tooltipRenderer : String;
		public var opacity : Number = 1;
		public var rotation : Number = 0;
//		public var overflowY : String;
//		public var overflowX : String;
		public var tabIndex : int = 0;
		public var blendMode : String = 'normal';
		public var textShadowColor : AdvancedColor;
		public var cursor : String = 'default';
		public var position : String = 'static';
		
		//TODO: remove need for these
//		public var scrollbarWidth : int;
		
		public var boxSizing : String = 'content-box';
		public var backgroundRenderer : String;
		public var borderRenderer : String;
		public var backgroundBlendMode : String;
		public var frameRate : Number;
		public var verticalAlign : String;
		public var selectable : Boolean;
		public var tabStops : String;
		public var embedFonts : Boolean;
		public var antiAliasType : String;
		public var gridFitType : String;
		public var sharpness : Number;
		public var thickness : Number;
		public var wordWrap : String;
		public var multiline : Boolean;
		public var cacheAsBitmap : Boolean;
		public var autoHide : Boolean;
		public var pageScrollSize : int;
		public var lineScrollSize : int;
		public var scaleScrollThumb : Boolean;
		public var inputCharRestrict : String;
		public var inputLengthRestrict : int;
		public var backgroundColor : AdvancedColor;
		public var backgroundGradientType : String;
		public var backgroundGradientColors : Array;
		public var backgroundGradientRatios : Array;
		public var backgroundGradientRotation : Number;
		public var backgroundImage : String = 'none';
		public var backgroundShadowColor : AdvancedColor;
		public var backgroundImageType : String;
		public var backgroundRepeat : String;
		public var backgroundPositionX : int = 0;
		public var backgroundPositionY : int = 0;
		public var backgroundScale9Type : String = 'none';
//		public var backgroundScale9RectTop : int;
//		public var backgroundScale9RectLeft : int;
//		public var backgroundScale9RectRight : int;
//		public var backgroundScale9RectBottom : int;
		public var fontSize : Number;
		public var fontFamily : String;
		public var textTransform : String;
		public var leading : Number;
		public var textAlign : String;
		public var textShadowYBlur : Number;
		public var textShadowXBlur : Number;
		public var textShadowXOffset : int;
		public var textShadowYOffset : int;
		public var textShadowStrength : Number;
		public var textShadowQuality : Number;
		public var textShadowInner : Boolean;
		public var textShadowKnockout : Boolean;
		public var textShadowHideObject : Boolean;
		
		public var RepriseTransitionDelay : Array;
		public var RepriseTransitionProperty : Array;
		public var RepriseTransitionDuration : Array;
		public var RepriseTransitionDefaultValue : Array;
		public var RepriseTransitionTimingFunction : Array;
		
		public var color : AdvancedColor;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function ComputedStyles()
		{
		}
		
		/**
		 * Merges in style changes.
		 * For properties that have been removed from the declaration, the base values are 
		 * retrieved from the BASELINE ComputedStyles object.
		 */
		public function updateValues(
			styles : CSSDeclaration, changedProperties : CSSPropertiesChangeList) : void
		{
			for (var key : String in changedProperties)
			{
				if (styles.hasStyle(key))
				{
					this[key] = styles.getStyle(key).valueOf();
					continue;
				}
				if (BASELINE.hasOwnProperty(key))
				{
					this[key] = BASELINE[key];
					continue;
				}
				delete this[key];
			}
		}
	}
}
