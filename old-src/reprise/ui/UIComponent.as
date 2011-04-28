
/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.ui
{
	import reprise.controls.Scrollbar;
	import reprise.core.UIRendererFactory;
	import reprise.core.reprise;
	import reprise.css.CSSDeclaration;
	import reprise.css.CSSParsingHelper;
	import reprise.css.CSSPropertiesChangeList;
	import reprise.css.CSSProperty;
	import reprise.css.ComputedStyles;
	import reprise.css.math.ICSSCalculationContext;
	import reprise.css.propertyparsers.Filters;
	import reprise.css.transitions.CSSTransitionsManager;
	import reprise.events.DisplayEvent;
	import reprise.ui.layoutmanagers.CSSBoxModelLayoutManager;
	import reprise.ui.layoutmanagers.ILayoutManager;
	import reprise.ui.renderers.ICSSRenderer;
	import reprise.utils.GfxUtil;
	import reprise.utils.StringUtil;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	use namespace reprise;

	public class UIComponent extends UIObject implements ICSSCalculationContext
	{
		//----------------------             Public Properties              ----------------------//
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected static const WIDTH_RELATIVE_PROPERTIES : Array = 
		[
			['marginTop', false],
			['marginBottom', false],
			['marginLeft', false],
			['marginRight', false],
			['paddingTop', false],
			['paddingBottom', false],
			['paddingLeft', false],
			['paddingRight', false],
			['left', true],
			['right', true]
		];
		protected static const EDGE_NAMES : Array = 
		[
			'Top',
			'Right',
			'Bottom',
			'Left'
		];
		protected static const HEIGHT_RELATIVE_PROPERTIES : Array = 
		[
			['top', true],
			['bottom', true],
			['height', true]
		];
		protected static const OWN_WIDTH_RELATIVE_PROPERTIES:Array = 
		[
			['borderTopLeftRadius', false],
			['borderTopRightRadius', false],
			['borderBottomLeftRadius', false],
			['borderBottomRightRadius', false]
		];
		protected static const CHILDREN_INVALIDATING_PROPERTIES : Object = 
		{
			width : true,
			height : true
		};
		
		protected static const DEFAULT_SCROLLBAR_WIDTH : int = 16;
		
		protected static const IDENTITY_MATRIX : Matrix = new Matrix();
		protected static const TRANSFORM_MATRIX : Matrix = new Matrix();
		
		
		//attribute properties
		protected var _xmlDefinition : XML;
		protected var _nodeAttributes : Object;
		protected var _cssClasses : String = "";
		protected var _cssPseudoClasses : String = "";
		protected var _cssId : String = "";
		protected var _selectorPath : String;
		
		//style properties
		protected var _currentStyles : ComputedStyles;
		protected var _complexStyles : CSSDeclaration;
		protected var _specifiedStyles : CSSDeclaration;
		protected var _instanceStyles : CSSDeclaration;
		protected var _weakStyles : CSSDeclaration;
		protected var _elementDefaultStyles : CSSDeclaration;
		protected var _changedStyleProperties : CSSPropertiesChangeList;
		
		protected var _autoFlags : Object = {};
		protected var _positionInFlow : int = 1;
		protected var _positioningType : String;
		
		//validation properties
		protected var _stylesInvalidated : Boolean;
		protected var _dimensionsChanged : Boolean;
		protected var _specifiedDimensionsChanged : Boolean;
		protected var _selectorPathChanged : Boolean;
		protected var _oldContentBoxWidth : int;
		protected var _oldContentBoxHeight : int;
		
		//dimensions and position
		protected var _contentBoxWidth : int = 0;
		protected var _contentBoxHeight : int = 0;
		protected var _borderBoxHeight : int = 0;
		protected var _borderBoxWidth : int = 0;
		protected var _paddingBoxHeight : int = 0;
		protected var _paddingBoxWidth : int = 0;

		protected var _intrinsicWidth : int = -1;
		protected var _intrinsicHeight : int = -1;

		protected var _positionOffset : Point;
		
		//managers and renderers
		protected var _layoutManager : ILayoutManager;
		protected var _borderRenderer : ICSSRenderer;
		protected var _backgroundRenderer : ICSSRenderer;
		
		//displays
		protected var _containingBlock : UIComponent;
		
		protected var _lowerContentDisplay : Sprite;
		protected var _upperContentDisplay : Sprite;
		protected var _backgroundDisplay : Sprite;
		protected var _bordersDisplay : Sprite;
		protected var _upperContentMask : Sprite;
		protected var _lowerContentMask : Sprite;
		protected var _frozenContent : BitmapData;
		protected var _frozenContentDisplay : Bitmap;
		
		protected var _vScrollbar : Scrollbar;
		public var _hScrollbar : Scrollbar;
		
		protected var _dropShadowFilter : DropShadowFilter;
		
		
		//----------------------       Private / Protected Properties       ----------------------//
		private var _explicitContainingBlock : UIComponent;
		private var _transitionsManager : CSSTransitionsManager;
		private var _scrollbarsDisplay : Sprite;
		private var _oldInFlowStatus : int = -1;
		private var _oldOuterBoxDimension : Point;
		private var _invalidateStylesAfterValidation : Boolean;
		private var _forceChildValidation : Boolean;
		private var _isRenderedHasChanged:Boolean;

		
		//----------------------               Public Methods               ----------------------//
		public function UIComponent()
		{
		}
		
		/**
		 * Convenience method that eases the process to add a child element.
		 * 
		 * Creates a new instance of the given componentClass or UIComponent if no class is 
		 * provided. This instance is immediately attached to the elements display list and 
		 * initialized with the given CSS classes and ID.
		 * 
		 * @param cssClasses The css classes the component should have.
		 * @param cssID The css id the component should have.
		 * @param componentClass The ActionScript class to instantiate. If this is 
		 * omitted, an instance of UIComponent will be created.
		 * @param index The index at which the element should be added. If this is 
		 * omitted, the element will be added at the next available index.
		 * 
		 * @return The newly created element
		 */
		public function addComponent(cssClasses : String = null, cssID : String = null, 
			componentClass : Class = null, index : int = -1) : UIComponent
		{
			if (!componentClass)
			{
				componentClass = UIComponent;
			}
			var component : UIComponent = new componentClass();
			return addElement(cssClasses, component, cssID, index);
		}
		
		/**
		 * Convenience method that eases the process to add a child element.
		 * 
		 * Attaches the given element to the display list or creates a new UIComponent if no 
		 * element is provided. This element is then initialized with the given CSS classes and ID.
		 * 
		 * @param cssClasses The css classes the component should have.
		 * @param cssID The css id the component should have.
		 * @param element The Element to add. If this is omitted, an instance of UIComponent will 
		 * be created.
		 * @param index The index at which the element should be added. If this is 
		 * omitted, the element will be added at the next available index.
		 * 
		 * @return The newly added element
		 */
		public function addElement(cssClasses : String = null, element : UIComponent = null, 
			cssID : String = null, index : int = -1) : UIComponent
		{
			if (!element)
			{
				element = new UIComponent();
			}
			if (index == -1)
			{
				addChild(element);
			}
			else
			{
				addChildAt(element, index);
			}
			if (cssID)
			{
				element.cssID = cssID;
			}
			if (cssClasses)
			{
				element.cssClasses = cssClasses;
			}
			return element;
		}

		/**
		 * initializes the UIComponent structure from the given XMLList, 
		 * creating child views as needed.
		 * 
		 * Using setInnerXML, entire structures of child elements can be created based on the 
		 * supplied XML structure. For a description of how the XML is interpreted, see the 
		 * documentation for UIRendererFactory.
		 * 
		 * @param	children	the XMLList to parse
		 * @return				The instance that setInnerXML is invoked on, so that calls can be chained
		 * @see 				UIRendererFactory
		 */
		public function setInnerXML(children : XMLList) : UIComponent
		{
			//We might not have an xmlDefinition for this element at all. While we'll want to change 
			//that later, we ignore it for now.
			_xmlDefinition && _xmlDefinition.setChildren(children);
			parseXMLContent(children);
			return this;
		}
		
		/**
		 * Returns the containing block for this element.
		 * 
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @see http://www.w3.org/TR/CSS21/visudet.html#containing-block-details 
		 * for a formal definition of containing block
		 */
		public function get containingBlock() : UIComponent
		{
			return _containingBlock;
		}

		/**
		 * shortcut for setting the elements width
		 * 
		 * @param value The width to apply
		 */
		public override function set width(value : Number) : void
		{
			setStyle('width', int(value) + "px");
		}
		/**
		 * Returns the elements width excluding padding and borders.
		 * 
		 * Note that this value is only guaranteed to be available for valid elements.
		 */
		public override function get width() : Number
		{
			return _contentBoxWidth;
		}
		/**
		 * Returns the elements width including padding and borders.
		 * 
		 * Note that this value is only guaranteed to be available for valid elements.
		 */
		public function get outerWidth() : int
		{
			return _borderBoxWidth;
		}
		/**
		 * Returns the elements width intrinsic including padding and borders.
		 * 
		 * The returned value is the width that the element occupies naturally, i.e. if no 
		 * other constraints apply to it.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 */
		public function get intrinsicWidth() : int
		{
			return _intrinsicWidth;
		}
		
		/**
		 * shortcut for setting the elements height
		 * 
		 * @param value The height to apply
		 */
		public override function set height(value : Number) : void
		{
			setStyle('height', int(value) + "px");
		}
		/**
		 * Returns the elements height excluding padding and borders.
		 * 
		 * Note that this value is only guaranteed to be available for valid elements.
		 */
		public override function get height() : Number
		{
			return _contentBoxHeight;
		}
		/**
		 * Returns the elements height including padding and borders.
		 * 
		 * Note that this value is only guaranteed to be available for valid elements.
		 */
		public function get outerHeight() : int
		{
			return _borderBoxHeight;
		}
		/**
		 * Returns the elements height intrinsic including padding and borders.
		 * 
		 * The returned value is the height that the element occupies naturally, i.e. if no 
		 * other constraints apply to it.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 */
		public function get intrinsicHeight() : int
		{
			return _intrinsicHeight;
		}
		
		/**
		 * Returns the elements top position.
		 * 
		 * The returned value is the value currently specified and is to be interpreted differently 
		 * depending on the value of the CSS property 'position'.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @see http://www.reprise-framework.org/doc/reprise.css/positioning.html#top
		 * 		CSS documentation for top
		 * @return The elements current top position
		 */
		public function get top() : Number
		{
			if (!isNaN(_currentStyles.top))
			{
				return _currentStyles.top;
			}
			if (!isNaN(_currentStyles.bottom))
			{
				return _containingBlock.calculateContentHeight() -
					_currentStyles.bottom - _borderBoxHeight;
			}
			return 0;
		}
		/**
		 * Sets the elements top position as specified by CSS.
		 * 
		 * The applied value is interpreted differently depending on the value of the CSS property 
		 * 'position'.
		 * <p>
		 * This value is applied immediately and doesn't cause the element to be validated. Because 
		 * of that, it might interfere with transitions specified for the 'top' CSS property, 
		 * meaning it shouldn't be used if a transition is specified.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @see http://www.reprise-framework.org/doc/reprise.css/positioning.html#top
		 * 		CSS documentation for top
		 * @return The elements current top position
		 */
		public function set top(value : Number) : void
		{
			if (isNaN(value))
			{
				value = 0;
			}
			_currentStyles.top = value;
			_instanceStyles.setStyle('top', value + "px");
			_autoFlags.top = false;
			if (!_positionInFlow)
			{
				var absolutePosition : Point = 
					getPositionRelativeToContext(_containingBlock);
				absolutePosition.y -= y;
				y = value + _currentStyles.marginTop - absolutePosition.y;
			}
		}

		/**
		 * Returns the elements left position.
		 * 
		 * The returned value is the value currently specified and is to be interpreted differently 
		 * depending on the value of the CSS property 'position'.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @see http://www.reprise-framework.org/doc/reprise.css/positioning.html#left
		 * 		CSS documentation for left
		 * @return The elements current left position
		 */
		public function get left() : Number
		{
			if (!isNaN(_currentStyles.left))
			{
				return _currentStyles.left;
			}
			if (!isNaN(_currentStyles.right))
			{
				return _containingBlock.calculateContentWidth() -
					_currentStyles.right - _borderBoxWidth;
			}
			return 0;
		}
		/**
		 * Sets the elements left position as specified by CSS.
		 * 
		 * The applied value is interpreted differently depending on the value of the CSS property 
		 * 'position'.
		 * <p>
		 * This value is applied immediately and doesn't cause the element to be validated. Because 
		 * of that, it might interfere with transitions specified for the 'left' CSS property, 
		 * meaning it shouldn't be used if a transition is specified.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @see http://www.reprise-framework.org/doc/reprise.css/positioning.html#left
		 * 		CSS documentation for left
		 * @return The elements current left position
		 */
		public function set left(value : Number) : void
		{
			if (isNaN(value))
			{
				value = 0;
			}
			_currentStyles.left = value;
			_instanceStyles.setStyle('left', value + "px");
			_autoFlags.left = false;
			if (!_positionInFlow)
			{
				var absolutePosition : Point = 
					getPositionRelativeToContext(_containingBlock);
				absolutePosition.x -= x;
				x = value + _currentStyles.marginLeft - absolutePosition.x;
			}
		}
		
		/**
		 * Returns the elements right position.
		 * 
		 * The returned value is the value currently specified and is to be interpreted differently 
		 * depending on the value of the CSS property 'position'.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @see http://www.reprise-framework.org/doc/reprise.css/positioning.html#right
		 * 		CSS documentation for right
		 * @return The elements current right position
		 */
		public function get right() : Number
		{
			if (!isNaN(_currentStyles.left))
			{
				return _currentStyles.left + _borderBoxWidth;
			}
			if (!isNaN(_currentStyles.right))
			{
				return _currentStyles.right;
			}
			return 0 + _borderBoxWidth;
		}
		/**
		 * Sets the elements right position as specified by CSS.
		 * 
		 * The applied value is interpreted differently depending on the value of the CSS property 
		 * 'position'.
		 * <p>
		 * This value is applied immediately and doesn't cause the element to be validated. Because 
		 * of that, it might interfere with transitions specified for the 'right' CSS property, 
		 * meaning it shouldn't be used if a transition is specified.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @see http://www.reprise-framework.org/doc/reprise.css/positioning.html#right
		 * 		CSS documentation for right
		 * @return The elements current right position
		 */
		public function set right(value : Number) : void
		{
			if (isNaN(value))
			{
				value = 0;
			}
			_currentStyles.right = value;
			_instanceStyles.setStyle('right', value + "px");
			_autoFlags.right = false;
			if (!_positionInFlow)
			{
				var absolutePosition : Point = 
					getPositionRelativeToContext(_containingBlock);
				absolutePosition.x -= x;
				x = _containingBlock.calculateContentWidth() - _borderBoxWidth -
					_currentStyles.right - _currentStyles.marginRight - absolutePosition.x;
			}
		}
		
		/**
		 * Returns the elements bottom position.
		 * 
		 * The returned value is the value currently specified and is to be interpreted differently 
		 * depending on the value of the CSS property 'position'.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @see http://www.reprise-framework.org/doc/reprise.css/positioning.html#bottom
		 * 		CSS documentation for bottom
		 * @return The elements current bottom position
		 */
		public function get bottom() : Number
		{
			if (!isNaN(_currentStyles.top))
			{
				return _currentStyles.top + _borderBoxHeight;
			}
			if (!isNaN(_currentStyles.bottom))
			{
				return _currentStyles.bottom;
			}
			return 0 + _borderBoxHeight;
		}
		/**
		 * Sets the elements bottom position as specified by CSS.
		 * 
		 * The applied value is interpreted differently depending on the value of the CSS property 
		 * 'position'.
		 * <p>
		 * This value is applied immediately and doesn't cause the element to be validated. Because 
		 * of that, it might interfere with transitions specified for the 'bottom' CSS property, 
		 * meaning it shouldn't be used if a transition is specified.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @see http://www.reprise-framework.org/doc/reprise.css/positioning.html#bottom
		 * 		CSS documentation for bottom
		 * @return The elements current bottom position
		 */
		public function set bottom(value : Number) : void
		{
			if (isNaN(value))
			{
				value = 0;
			}
			_currentStyles.bottom = value;
			_instanceStyles.setStyle('bottom', value + "px");
			_autoFlags.bottom = false;
			if (!_positionInFlow)
			{
				var absolutePosition : Point = 
					getPositionRelativeToContext(_containingBlock);
				absolutePosition.y -= y;
				y = _containingBlock.calculateContentHeight() - _borderBoxHeight -
					_currentStyles.bottom - _currentStyles.marginBottom - absolutePosition.y;
			}
		}
		
		/**
		 * Returns the node attributes that were defined in this elements XML node.
		 * 
		 * This value is only defined for elements that were created by parsing an XML structure.
		 * 
		 * @return An untyped object containing the elements attributes. 
		 * 		   Changing the values doesn't update the element.
		 */
		public function get attributes() : Object
		{
			return _nodeAttributes;
		}
		
		/**
		 * Returns a Rectangle object that contains the current actual position and 
		 * dimensions of the UIComponent relative to its parentElement.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @return A Rectangle describing the elements position and dimensions in pixels 
		 */
		public function clientRect() : Rectangle
		{
			return new Rectangle(x, y, _borderBoxWidth, _borderBoxHeight);
		}
		
		/**
		 * Returns the width of the element excluding paddings and borders.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @return The width of the element including paddings and borders
		 */
		public function get contentBoxWidth() : int
		{
			return _contentBoxWidth;
		}
		/**
		 * Returns the height of the element excluding paddings and borders.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @return The height of the element including paddings and borders
		 */
		public function get contentBoxHeight() : int
		{
			return _contentBoxHeight;
		}
		/**
		 * Returns the width of the element including paddings but exluding borders.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @return The width of the element including paddings and borders
		 */
		public function get paddingBoxWidth() : int
		{
			return _paddingBoxWidth;
		}
		/**
		 * Returns the height of the element including paddings but exluding borders.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @return The height of the element including paddings and borders
		 */
		public function get paddingBoxHeight() : int
		{
			return _paddingBoxHeight;
		}
		/**
		 * Returns the width of the element including paddings and borders.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @return The width of the element including paddings and borders
		 */
		public function get borderBoxWidth() : int
		{
			return _borderBoxWidth;
		}
		/**
		 * Returns the height of the element including paddings and borders.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @return The height of the element including paddings and borders
		 */
		public function get borderBoxHeight() : int
		{
			return _borderBoxHeight;
		}
		
		/**
		 * Returns the current styles as applied to the element.
		 * <p>
		 * The returned value can only be used for reference, updating them doesn't change the 
		 * element.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @return The elements current styles as a ComputedStyles object
		 * @see ComputedStyles
		 */
		public function get style() : ComputedStyles
		{
			return _currentStyles;
		}
		
		/**
		 * Returns the CSS tag name of this element
		 * 
		 * @return The elements CSS tag name
		 */
		public function get cssTag() : String
		{
			return _elementType;
		}

		/**
		 * Sets the CSS ID and invalidates styling
		 * <p>
		 * CSS IDs
		 * 
		 * @param id The CSS ID to set for the element
		 */
		public function set cssID(id : String) : void
		{
			if (_cssId)
			{
				_rootElement.removeElementID(_cssId);
			}
			_rootElement && _rootElement.registerElementID(id, this);
			_cssId = id;
			invalidateStyles();
		}
		/**
		 * Returns the CSS id of this element
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @return The elements CSS id
		 */
		public function get cssID() : String
		{
			return _cssId;
		}
		/**
		 * Sets the CSS classes and invalidates styling
		 * <p>
		 * Replaces any currently specified CSS classes. Use UIComponent#addCSSClass to add classes.
		 * 
		 * @param classes A space separated list of CSS classes to associate the element with
		 */
		public function set cssClasses(classes : String) : void
		{
			_cssClasses = classes;
			invalidateStyles();
		}
		/**
		 * Returns the CSS classes of this element
		 * 
		 * @return A space separated list of CSS classes specified for the element
		 */
		public function get cssClasses() : String
		{
			return _cssClasses;
		}
		
		/**
		 * adds a CSS class if it's not already in the list of CSS classes and invalidates the 
		 * element.
		 * 
		 * @param name The CSS class to add to the element
		 */
		public function addCSSClass(name : String) : void
		{
			if (StringUtil.delimitedStringContainsSubstring(_cssClasses, name, ' '))
			{
				return;
			}
			_cssClasses += ' ' + name;
			if (_cssClasses.charAt(0) == ' ')
			{
				_cssClasses = _cssClasses.substr(1);
			}
			invalidateStyles();
		}
		/**
		 * removes a CSS class from the list and invalidates the element
		 * 
		 * @param name The CSS class to remove from the object
		 */
		public function removeCSSClass(name : String) : void
		{
			if (!StringUtil.delimitedStringContainsSubstring(_cssClasses, name, ' '))
			{
				return;
			}
			_cssClasses = StringUtil.
				removeSubstringFromDelimitedString(_cssClasses, name, ' ');
			invalidateStyles();
		}
		/**
		 * Returns true if the element has the supplied CSS class
		 * 
		 * @param className The CSS class name to check for
		 * @return A boolean value specifying if the element has the supplied CSS class
		 */
		public function hasCSSClass(className : String) : Boolean
		{
			return StringUtil.delimitedStringContainsSubstring(_cssClasses, className, ' ');
		}
		
		/**
		 * Sets the CSS pseudo classes and invalidates styling
		 * <p>
		 * Replaces any currently specified CSS pseudo classes. 
		 * Use UIComponent#addCSSPseudoClass to add classes.
		 * 
		 * @param classes A space separated list of CSS classes to associate the element with
		 */
		public function set cssPseudoClasses(classes : String) : void
		{
			_cssPseudoClasses = classes;
			invalidateStyles();
		}
		/**
		 * Returns the CSS pseudo classes of this element
		 * 
		 * @return A space separated list of CSS pseudo classes specified for the element
		 */
		public function get cssPseudoClasses() : String
		{
			return _cssPseudoClasses;
		}
		
		/**
		 * adds a CSS pseudo class if it's not already in the list of CSS classes and invalidates 
		 * the element
		 * 
		 * @param name The CSS pseudo class to add to the element
		 */
		public function addCSSPseudoClass(name : String) : void
		{
			if (StringUtil.delimitedStringContainsSubstring(
				_cssPseudoClasses, ':' + name, ' '))
			{
				return;
			}
			_cssPseudoClasses += " :" + name;
			if (_cssPseudoClasses.charAt(0) == ' ')
			{
				_cssPseudoClasses = _cssPseudoClasses.substr(1);
			}
			invalidateStyles();
		}
		/**
		 * removes a CSS pseudo class from the list and invalidates the element
		 * 
		 * @param name The CSS pseudo class to remove from the object
		 */
		public function removeCSSPseudoClass(name : String) : void
		{
			if (!StringUtil.delimitedStringContainsSubstring(
				_cssPseudoClasses, ':' + name, ' '))
			{
				return;
			}
			_cssPseudoClasses = StringUtil.removeSubstringFromDelimitedString(
				_cssPseudoClasses, ':' + name, ' ');
			invalidateStyles();
		}
		
		/**
		 * Sets a single CSS style property and invalidates the element
		 * <p>
		 * The value is added to the elements instance styles and thus overrides all values set for 
		 * the same property through other means, i.e. through external stylesheets or the element 
		 * type supplying a default value.
		 * 
		 * @param name The name of the property to set
		 * @param value The value to set for the property as a String. If no value is supplied, the 
		 * property is removed from the elements instance styles.
		 */
		public function setStyle(name : String, value : String = null) : void
		{
			_instanceStyles.setStyle(name, value);
			invalidateStyles();
		}
		
		/**
		 * @inheritDoc
		 */
		public override function tooltipDelay() : int
		{
			return _currentStyles.tooltipDelay || 0;
		}
		/**
		 * @inheritDoc
		 */
		public override function setTooltipDelay(delay : int) : void
		{
			// we don't need no invalidation
			_instanceStyles.setStyle('tooltipDelay', delay.toString());
			_currentStyles.tooltipDelay = delay;
		}
		/**
		 * @inheritDoc
		 */
		public override function tooltipRenderer() : String
		{
			return _tooltipRenderer;
		}
		/**
		 * @inheritDoc
		 */
		public override function setTooltipRenderer(renderer : String) : void
		{
			// we don't need no invalidation
			_instanceStyles.setStyle('tooltipRenderer', renderer);
			_currentStyles.tooltipRenderer = renderer;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function setFocus(value : Boolean, method : String) : void
		{
			if (value)
			{
				addCSSPseudoClass('focus');
			}
			else
			{
				removeCSSPseudoClass('focus');
			}
		}
		
		/**
		 * sets the views visibility without executing any transitions that might 
		 * be defined in the views' <code>hide</code> and <code>show</code> methods
		 */
		public override function setVisibility(visible : Boolean) : void
		{
			var visibilityProperty : String = (visible ? 'visible' : 'hidden');
			_instanceStyles.setStyle('visibility', visibilityProperty);
			_currentStyles.visibility = visibilityProperty;
			super.setVisibility(visible);
		}

		/**
		* Sets the elements alpha property immediately and without invalidating the element
		* 
		* @param value The value to set alpha to as a fraction between 0 and 1
		* @see #opacity
		*/
		public override function set alpha(value:Number) : void
		{
			opacity = value;
		}
		/**
		 * Returns the elements alpha as a fraction between 0 and 1
		 * 
		 * @return The elements alpha as a fraction between 0 and 1
		 */
		public override function get alpha() : Number
		{
			return opacity;
		}
		
		/**
		 * Sets the elements opacity property immediately and without invalidating the element
		 * 
		 * @param value The elements opacity as a fraction between 0 and 1
		 */
		public function set opacity(value : Number) : void
		{
			super.alpha = value;
			_currentStyles.opacity = value;
			_instanceStyles.setStyle('opacity', value.toString());
		}

		/**
		 * Returns the elements opacity as a fraction between 0 and 1
		 * 
		 * @return The value to set opacity to as a fraction between 0 and 1
		 */
		public function get opacity() : Number
		{
			return _currentStyles.opacity;
		}
		
		/**
		 * Sets the elements rotation as a Number between 0 and 360
		 * 
		 * @return The value to set rotation to as a Number. Value below 0 and above 360 get 
		 * normalized by applying modulo 360.
		 */
		public override function set rotation(value : Number) : void
		{
			super.rotation = value;
			_currentStyles.rotation = value;
			_instanceStyles.setStyle('rotation', value.toString());
		}
		/**
		 * Returns the elements rotation as a value between 0 and 360
		 * 
		 * @return The elements rotation as a value between 0 and 360
		 */
		public override function get rotation() : Number
		{
			return _currentStyles.rotation;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function remove(...args) : void
		{
			if (_cssId && _rootElement)
			{
				_rootElement.removeElementID(_cssId);
			}
			super.remove();
		}
		
		/**
		 * Returns all descentant elements that have the supplied CSS class set
		 * 
		 * @param className The CSS class name to match descendant elements against
		 * @return An Array containing all matching elements
		 */
		public function getElementsByClassName(className : String) : Array
		{
			var elements : Array = [];
			
			var len : int = _children.length;
			for (var i : int = 0; i < len; i++)
			{
				var child : DisplayObject = _children[i];
				if (!(child is UIComponent))
				{
					continue;
				}
				var childView : UIComponent = child as UIComponent;
				if (childView.hasCSSClass(className))
				{
					elements.push(childView);
				}
				var subElements : Array = childView.getElementsByClassName(className);
				if (subElements.length)
				{
					elements = elements.concat(subElements);
				}
			}		
			return elements;		
		}
		
		/**
		 * Returns all descentant elements that match the supplied CSS selector
		 * <p>
		 * //TODO: describe the selector path format
		 * 
		 * @param selector The selector path to match descendant elements against
		 * @return An Array conaining all matching elements
		 */
		public function getElementsBySelector(selector : String) : Array
		{
			var matches : Array = [];
			var selectorParts : Array;
			var element : UIComponent;
			var candidates : Array = [];
			//find last ID in the selector and discard everything before that
			var lastIDIndex : int = selector.lastIndexOf('#');
			if (lastIDIndex != -1)
			{
				//find element for ID and make it the root candidate
				selector = selector.substr(lastIDIndex + 1);
				selectorParts = selector.split(' ');
				var id : String = selectorParts.shift();
				//discard every other information in the ID selector
				id = ((id.split('.')[0] as String).split('[')[0] as String).split(':')[0];
				element = _rootElement.getElementById(id);
				if (!element)
				{
					//if there's no element for the ID, there's nothing to return
					return matches;
				}
				candidates.push(element);
			}
			else
			{
				//no ID found, make current element the root candidate
				candidates.push(this);
				selectorParts = selector.split(' ');
			}
			
			while (candidates.length && selectorParts.length)
			{
				var index : int;
				var currentSelectorPart : String = selectorParts.shift();
				//extract index suffix from path
				var fragments : Array = currentSelectorPart.split('[');
				var currentPath : String = fragments[0];
				if (fragments[1])
				{
					index = parseInt(fragments[1]);
				}
				
				var oldCandidates : Array = candidates;
				candidates = [];
				var children : Array;
				
				//split into tag and classes
				var classes : Array = currentPath.split('.');
				var className : String;
				var tag : String = classes.shift();
				//find first
				if (tag.length)
				{
					while (oldCandidates.length)
					{
						element = oldCandidates.shift();
						children = element.getElementsByTagName(tag);
						if (children.length)
						{
							candidates = candidates.concat(children);
						}
					}
				}
				else
				{
					className = classes.shift();
					while (oldCandidates.length)
					{
						element = oldCandidates.shift();
						children = element.getElementsByClassName(className);
						if (children.length)
						{
							candidates = candidates.concat(children);
						}
					}
				}
			}
			
			matches = candidates;
			return matches;
		}
		/**
		 * Returns the first descentant element that matches the supplied CSS selector
		 * <p>
		 * //TODO: describe the selector path format
		 * 
		 * @param selector The selector path to match descendant elements against
		 * @return The first descentant element that matches the supplied CSS selector
		 */
		public function getElementBySelector(selector : String) : UIComponent
		{
			return getElementsBySelector(selector)[0];
		}
		
		/**
		 * @private
		 * 
		 * Only used internally but implements an interface and interface methods can only be public
		 */
		public function valueBySelectorProperty(
			selector : String, property : String, ...rest : Array) : *
		{
			var target : UIComponent;
			
			//If there's no selector, this element is the target
			if (!selector)
			{
				target = this;
			}
			else
			{
				target = getElementBySelector(selector);
			}
			
			var targetProperty : *;
			try
			{
				targetProperty = target[property];
			}
			catch (error : Error)
			{
				if (target._currentStyles[property])
				{
					return target._currentStyles[property];
				}
				throw error;
			}
			if (targetProperty is Function)
			{
				targetProperty = (targetProperty as Function).apply(target, rest);
			}
			
			return targetProperty;
		}
		
		/**
		 * @private
		 */
		public function setIdAttribute(value : String) : void
		{
			cssID = value;
		}
		/**
		 * @private
		 */
		public function setClassAttribute(value : String) : void
		{
			cssClasses = value;
		}
		/**
		 * @private
		 */
		public function setStyleAttribute(value : String) : void
		{
			_instanceStyles = CSSParsingHelper.parseDeclarationString(value, applicationURL());
		}

		/**
		 * @private
		 */
		public function setTooltipAttribute(value : String) : void
		{
			setTooltipData(value);
		}
		/**
		 * @private
		 */
		public function setTitleAttribute(value : String) : void
		{
			if (!_tooltipData)
			{
				setTooltipData(value);
			}
		}
		
		/**
		 * Returns true if this element has any currently running CSS transitions
		 * 
		 * @return Boolean value indicating if the element has active CSS transitions
		 */
		public function hasActiveTransitions() : Boolean
		{
			return _transitionsManager.isActive();
		}
		
		/**
		 * Returns true if this element has a currently running CSS transition for the 
		 * given style
		 * 
		 * @param style The name of the CSS property to check for transitions for
		 * @return Boolean value indicating if the element has an active CSS transition for the 
		 * supplied CSS property
		 */
		public function hasActiveTransitionForStyle(style : String) : Boolean
		{
			return _transitionsManager.hasActiveTransitionForStyle(style);
		}
		
		
		public function get hScroll():Number
		{
			if (!_hScrollbar) return 0;
			return _hScrollbar.scrollPosition;
		}
		
		public function set hScroll(val:Number):void
		{
			if (!_hScrollbar) return;
			_hScrollbar.scrollPosition = val;
			_lowerContentDisplay && (_lowerContentDisplay.x = -_hScrollbar.scrollPosition);
			_upperContentDisplay && (_upperContentDisplay.x = -_hScrollbar.scrollPosition);
		}
		
		public function get vScroll():Number
		{
			if (!_vScrollbar) return 0;
			return _vScrollbar.scrollPosition;
		}
		
		public function set vScroll(val:Number):void
		{
			if (!_vScrollbar) return;
			_vScrollbar.scrollPosition = val;
			_lowerContentDisplay && (_lowerContentDisplay.y = -_vScrollbar.scrollPosition);
			_upperContentDisplay && (_upperContentDisplay.y = -_vScrollbar.scrollPosition);
		}
		
		
		/***************************************************************************
		 *							reprise methods								   *
		 ***************************************************************************/
		/**
		 * Allows to explicitly specify a containing block for the element.
		 * 
		 * Use this method if you need to override the element that's used as a frame of reference 
		 * for resolving relative properties in the CSS box model.
		 * 
		 * @param containingBlock The element to use as the containing block for this element
		 * @see http://www.w3.org/TR/CSS21/visudet.html#containing-block-details 
		 * 		formal definition of containing block
		 */
		reprise function overrideContainingBlock(
			containingBlock : UIComponent) : void
		{
			_explicitContainingBlock = containingBlock;
		}

		/**
		 * Returns the width that is available to child elements.
		 */
		reprise function innerWidth() : int
		{
			if (_vScrollbar && _vScrollbar.visibility())
			{
				return _currentStyles.width - _vScrollbar.outerWidth;
			}
			return _currentStyles.width;
		}
		
		/**
		 * Returns the height that is available to child elements.
		 */
		reprise function innerHeight() : int
		{
			if (_hScrollbar && _hScrollbar.visibility())
			{
				return _currentStyles.height - _hScrollbar.outerWidth;
			}
			return _currentStyles.height;
		}
		reprise function get autoFlags() : Object
		{
			return _autoFlags;
		}
		reprise function get positionInFlow() : int
		{
			return _positionInFlow;
		}
		reprise function get selectorPath() : String
		{
			return _selectorPath;
		}
		

		//----------------------         Private / Protected Methods        ----------------------//
		override protected function preinitialize() : void
		{
			super.preinitialize();
			_instanceStyles = new CSSDeclaration();
		}
		
		protected override function initialize() : void
		{
			if (!_class.basicStyles)
			{
				_class.basicStyles = new CSSDeclaration();
				_elementDefaultStyles = _class.basicStyles;
				initDefaultStyles();
			}
			else
			{
				_elementDefaultStyles = _class.basicStyles;
			}
			_transitionsManager = new CSSTransitionsManager(this);
			_layoutManager = new CSSBoxModelLayoutManager();
			_currentStyles = new ComputedStyles();
			_weakStyles = new CSSDeclaration();
			_stylesInvalidated = true;
			if (_cssId)
			{
				_rootElement.registerElementID(_cssId, this);
			}
			super.initialize();
		}
		
		protected function createLowerContentDisplay() : void
		{
			// create container for elements with z-index < 0
			_lowerContentDisplay = new Sprite();
			_contentDisplay.addChild(_lowerContentDisplay);
			_lowerContentDisplay.name = 'lower_content_display';
			_lowerContentDisplay.mouseEnabled = false;
		}
		protected function createUpperContentDisplay() : void
		{
			// create container for elements with z-index >= 0
			_upperContentDisplay = new Sprite();
			_contentDisplay.addChild(_upperContentDisplay);
			_upperContentDisplay.name = 'upper_content_display';
			_upperContentDisplay.mouseEnabled = false;
		}

		override protected function addChildToContentDisplay(child : UIObject, index : int) : void
		{
			if (!(child is UIComponent))
			{
				super.addChildToContentDisplay(child, index);
			}
		}

		/**
		 * Resets the elements styles.
		 * 
		 * Mostly used in debugging to enable style reloading.
		 */
		reprise function resetStyles() : void
		{
			_complexStyles = null;
			_specifiedStyles = null;
			for each (var child : UIComponent in _children)
			{
				child.resetStyles();
			}
			invalidateStyles();
		}
		
		/**
		 * Executes element validation, refreshing and applying all style properties and 
		 * redrawing the element.
		 * 
		 * Components shouldn't need to override this method, since it only starts the 
		 * validation cycle and doesn't really implement functionality that's worth 
		 * overriding.
		 */
		protected override function validateElement(
			forceValidation : Boolean = false, validateStyles : Boolean = false) : void
		{
			if (!_isInvalidated && !forceValidation)
			{
				_changedStyleProperties = new CSSPropertiesChangeList();
				_selectorPathChanged = false;
				validateChildren();
				return;
			}
			_rootElement.increaseValidatedElementsCount();
			if (validateStyles)
			{
				_stylesInvalidated = true;
			}
			super.validateElement(forceValidation);
		}
		
		/**
		 * Hook method, executed before the UIComponents' children get validated.
		 * 
		 * Stores values for some settings for later comparison and executes style 
		 * validation. If that results in changed settings, it applies those.
		 */
		protected override function validateBeforeChildren() : void
		{
			_contentDisplay.transform.matrix = IDENTITY_MATRIX;
			if (_scrollbarsDisplay)
			{
				_scrollbarsDisplay.transform.matrix = _contentDisplay.transform.matrix;
			}
			_oldInFlowStatus = _positionInFlow;
			
			_oldContentBoxWidth = _contentBoxWidth;
			_oldContentBoxHeight = _contentBoxHeight;
			var oldSpecifiedWidth : int = _currentStyles.width;
			var oldSpecifiedHeight : int = _currentStyles.height;
			
			if (_stylesInvalidated)
			{
				var isCurrentlyRendered : Boolean = _isRendered;
				calculateStyles();
				
				if (_parentElement is UIComponent)
				{
					hookIntoDisplayList(); 
				}
				if (_firstDraw)
				{
					dispatchEvent(new DisplayEvent(DisplayEvent.ADDED_TO_DOCUMENT, true));
				}

				_isRenderedHasChanged = isCurrentlyRendered != _isRendered;
				
				if (!_isRendered)
				{
					visible = false;
					if (_parentElement &&
						isCurrentlyRendered && !UIComponent(_parentElement)._isValidating)
					{
						UIComponent(_parentElement).validateAfterChildren();
					}
					return;
				}
				
				visible = _visible;
				if (_stylesInvalidated)
				{
					if (_currentStyles.overflowY == 'scroll')
					{
						if (!_vScrollbar)
						{
							_vScrollbar = createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
						}
						else
						{
							_vScrollbar.setVisibility(true);
						}
					}
					
					if (_currentStyles.overflowX == 'scroll')
					{
						if (!_hScrollbar)
						{
							_hScrollbar = createScrollbar(Scrollbar.ORIENTATION_HORIZONTAL);
						}
						else
						{
							_hScrollbar.setVisibility(true);
						}
					}
					applyStyles();
					if (_currentStyles.width != oldSpecifiedWidth ||
						_currentStyles.height != oldSpecifiedHeight)
					{
						_specifiedDimensionsChanged = true;
					}
				}
			}
		}
		
		protected function hookIntoDisplayList() : void
		{
			(_parentElement as UIComponent).addComponentToDisplayList(this,
				_positionInFlow == 1 && _currentStyles.zIndex < 1 || _currentStyles.zIndex < 0);
		}

		/**
		 * Hook method, executed after the UIObjects' children get validated
		 */
		protected override function validateAfterChildren() : void
		{
			if (!_isRendered)
			{
				return;
			}
			
			var oldIntrinsicWidth : int = _intrinsicWidth;
			var oldIntrinsicHeight : int = _intrinsicHeight;
			applyInFlowChildPositions();
			_layoutManager.applyDepthSorting(_lowerContentDisplay, _upperContentDisplay);
			
			measure();
			
			if (_autoFlags.width && (_currentStyles.display == 'inline' ||
				(!_positionInFlow && (_autoFlags.left || _autoFlags.right))))
			{
				if (_transitionsManager.hasTransitionForStyle('width'))
				{
					if (_weakStyles.hasStyle('width') &&
						_weakStyles.getStyle('width').specifiedValue() == _intrinsicWidth)
					{
						_contentBoxWidth = _currentStyles.width;
					}
					else
					{
						//TODO: deal with inline elements adapting to the intermittend sizes, 
						//changing the intrinsic width
						_weakStyles.setStyle('width', _intrinsicWidth + 'px', true);
						_specifiedStyles.setStyle('width', _oldContentBoxWidth + 'px');
						_transitionsManager.registerAdjustedStartTimeForProperty(
							_rootElement.frameTime(), 'width');
						_contentBoxWidth = _oldContentBoxWidth;
						_invalidateStylesAfterValidation = true;
						_stylesInvalidated = true;
						invalidate();
					}
				}
				else
				{
					_contentBoxWidth = _intrinsicWidth;
				}
			}
			if (_autoFlags.height && _intrinsicHeight != -1)
			{
				if (_transitionsManager.hasTransitionForStyle('height'))
				{
					if (_weakStyles.hasStyle('height') &&
						_weakStyles.getStyle('height').specifiedValue() == _intrinsicHeight)
					{
						_contentBoxHeight = _currentStyles.height;
					}
					else
					{
						_weakStyles.setStyle('height', _intrinsicHeight + 'px', true);
						_specifiedStyles.setStyle('height', _oldContentBoxHeight + 'px');
						_transitionsManager.registerAdjustedStartTimeForProperty(
							_rootElement.frameTime(), 'height');
						_contentBoxHeight = _oldContentBoxHeight;
						_invalidateStylesAfterValidation = true;
						_stylesInvalidated = true;
						invalidate();
					}
				}
				else
				{
					_contentBoxHeight = _intrinsicHeight;
				}
			}
			
			_paddingBoxHeight = _contentBoxHeight +
				_currentStyles.paddingTop + _currentStyles.paddingBottom;
			_borderBoxHeight = _paddingBoxHeight +
				_currentStyles.borderTopWidth + _currentStyles.borderBottomWidth;
			_paddingBoxWidth = _contentBoxWidth +
				_currentStyles.paddingLeft + _currentStyles.paddingRight;
			_borderBoxWidth = _paddingBoxWidth +
				_currentStyles.borderLeftWidth + _currentStyles.borderRightWidth;
			
			var outerBoxDimensions : Point = new Point(
				_borderBoxWidth + _currentStyles.marginLeft + _currentStyles.marginRight,
				_borderBoxHeight +
				_currentStyles.collapsedMarginTop + _currentStyles.collapsedMarginBottom);
			_dimensionsChanged =
				!(_oldOuterBoxDimension  && _oldOuterBoxDimension.equals(outerBoxDimensions));
			_oldOuterBoxDimension = outerBoxDimensions;
			
			var parentReflowNeeded : Boolean = false;
			
			//apply final relative position/borderWidths to content
			_contentDisplay.y = _positionOffset.y + _currentStyles.borderTopWidth;
			_contentDisplay.x = _positionOffset.x + _currentStyles.borderLeftWidth;
			
			if (_dimensionsChanged || _stylesInvalidated)
			{
				applyBackgroundAndBorders();
				applyOverflowProperty();
				if ((_currentStyles.float || _positionInFlow) && _dimensionsChanged)
				{
					parentReflowNeeded = true;
	//				log("f reason for parentReflow: dims of in-flow changed");
				}
			}
			else if (_contentBoxHeight != _oldContentBoxHeight ||
				_contentBoxWidth != _oldContentBoxWidth ||
				_intrinsicHeight != oldIntrinsicHeight ||
				_intrinsicWidth != oldIntrinsicWidth)
			{
				applyOverflowProperty();
			}
			
			if (!(_parentElement is UIComponent && _parentElement != this &&
				UIComponent(_parentElement)._isValidating))
			{
				if ((_oldInFlowStatus == -1 || _dimensionsChanged) && !_positionInFlow)
				{
					//The element is positioned absolutely or fixed.
					//check if at least one of the vertical and one of the 
					//horizontal dimensions is specified. If not, we need to 
					//let the parent do the positioning
					if ((_autoFlags.top && _autoFlags.bottom) ||
						(_autoFlags.left && _autoFlags.right))
					{
						parentReflowNeeded = true;
	//					log("f reason for reflow: All positions in " +
	//						"absolute positioned element are auto");
					}
				}
				else if (_oldInFlowStatus != _positionInFlow)
				{
					parentReflowNeeded = true;
	//				log("f reason for parentReflow: flowPos changed");
				}
				else if (_isRenderedHasChanged)
				{
					parentReflowNeeded = true;
	//				log("f reason for parentReflow: isRendered changed");
				}
				else if (_changedStyleProperties['zIndex'])
				{
					parentReflowNeeded = true;
	//				log("f reason for parentReflow: z-index changed");
				}
				if (_parentElement && _parentElement != this)
				{
					if (parentReflowNeeded && !UIComponent(_parentElement)._isValidating)
					{
//						log("w parentreflow needed in " + 
//							_elementType + "#"+_cssId + "."+_cssClasses);
						UIComponent(_parentElement).validateAfterChildren();
						return;
					}
					else if (!UIComponent(_parentElement)._isValidating)
					{
//						log("w no parentreflow needed in " + 
//							_elementType + "#"+_cssId + "."+_cssClasses);
						UIComponent(_parentElement).applyOutOfFlowChildPositions();
					}
				}
				else
				{
					applyOutOfFlowChildPositions();
				}
			}
			
			applyTransform();
		}
		protected override function finishValidation() : void
		{
			super.finishValidation();
			
			_dimensionsChanged = false;
			_specifiedDimensionsChanged = false;
			_isRenderedHasChanged = false;
			
			if (_invalidateStylesAfterValidation)
			{
				_invalidateStylesAfterValidation = false;
				invalidateStyles();
			}
			else
			{
				_stylesInvalidated = false;
			}
		}

		protected override function validateChildren() : void
		{
			if (!_isRendered)
			{
				return;
			}
			
			_forceChildValidation = _selectorPathChanged;
			if (!_forceChildValidation)
			{
				for (var key : String in _changedStyleProperties)
				{
					if (CHILDREN_INVALIDATING_PROPERTIES[key])
					{
						_forceChildValidation = true;
						break;
					}
					if (CSSDeclaration.INHERITABLE_PROPERTIES[key])
					{
						_forceChildValidation = true;
						break;
					}
				}
			}
			super.validateChildren();
		}
		protected override function validateChild(child:UIObject) : void
		{
			if (child is UIComponent)
			{
				UIComponent(child).validateElement(_forceChildValidation, _forceChildValidation);
			}
			else
			{
				super.validateChild(child);
			}
		}
		
		/**
		 * Hook for specifying styles that a components instances should have by default
		 */
		protected function initDefaultStyles() : void
		{
		}
		
		protected function refreshSelectorPath() : void
		{
			var oldPath : String = _selectorPath;
			var path : String;
			if (_parentElement)
			{
				path = (_parentElement as UIComponent).selectorPath + " ";
			}
			else 
			{
				path = "";
			}
			path += "@" + _elementType.toLowerCase() + "@";
			if (_cssId)
			{
				path += "@#" + _cssId + "@";
			}
			if (_cssClasses)
			{
				path += "@." + _cssClasses.split(' ').join('@.') + "@";
			}
			if (_cssPseudoClasses.length)
			{
				path += _cssPseudoClasses.split(" :").join("@:") + "@";
			}
			if (_isFirstChild)
			{
				path += "@:first-child@";
			}
			if (_isLastChild)
			{
				path += "@:last-child@";
			}
			if (path != oldPath)
			{
				_selectorPath = path;
				_selectorPathChanged = true;
				return;
			}
			_selectorPathChanged = false;
		}
		
		/**
		 * parses all styles associated with this element and its classes and creates a 
		 * combined style object.
		 * CalculateStyles also invokes processing of transitions and resolution of 
		 * relative values.
		 */
		protected function calculateStyles() : void
		{
			var oldSelectorPath : String = _selectorPath;
			refreshSelectorPath();
			
			var styles : CSSDeclaration = new CSSDeclaration();
			var oldStyles : CSSDeclaration = _specifiedStyles;
			
			styles.mergeCSSDeclaration(_instanceStyles);
			if (_rootElement.styleSheet)
			{
				styles.mergeCSSDeclaration(_rootElement.styleSheet.
					getStyleForEscapedSelectorPath(_selectorPath), false, true);
			}
			if (_parentElement != this && _parentElement is UIComponent)
			{
				styles.mergeCSSDeclaration(
					UIComponent(_parentElement)._complexStyles, true, true);
			}
			
			styles.mergeCSSDeclaration(_elementDefaultStyles, false, true);
			
			styles.mergeCSSDeclaration(_weakStyles, false, true);
			
			//check if styles or other relevant factors have changed and stop validation 
			//if not.
			_changedStyleProperties = styles.compare(oldStyles);
			if (!(_containingBlock && _containingBlock._specifiedDimensionsChanged) &&
				!_changedStyleProperties.length && !_transitionsManager.isActive() &&
				!(this == _rootElement && DocumentView(this).stageDimensionsChanged))
			{
				_stylesInvalidated = false;
				return;
			}
			
			_specifiedStyles = styles;
			styles = _transitionsManager.processTransitions(oldStyles, styles,
				_changedStyleProperties, stage.frameRate, _rootElement.frameTime());
			_complexStyles = styles;
			_currentStyles.updateValues(styles, _changedStyleProperties);
			
			if (_transitionsManager.isActive())
			{
				invalidateStyles();
			}
			
			//this element might have been removed in a transitions event handler. Return if so.
			_isRendered = !(styles.hasStyle('display') &&
				styles.getStyle('display').specifiedValue() == 'none') && _rootElement;
			if (!_isRendered)
			{
				//We want changes to the selectorPath picked up during the next real validation
				_selectorPath = oldSelectorPath;
				return;
			}
			
			resolvePositioningProperties();
			resolveContainingBlock();
			resolveRelativeStyles(styles);
		}

		/**
		 * Applies a wide array of style settings.
		 * When implementing components, this method should be overridden to implement 
		 * additional settings derived from stylesheets.
		 */
		protected function applyStyles() : void
		{	
			_positionOffset = new Point(0, 0);
			if (_positioningType == 'relative')
			{
				_positionOffset.x = _currentStyles.left;
				_positionOffset.y = _currentStyles.top;
			}
			
			
			_tabIndex = _currentStyles.tabIndex;
			
			_tooltipRenderer = _currentStyles.tooltipRenderer;
			_tooltipDelay = _currentStyles.tooltipDelay;
			
			_contentDisplay.blendMode = _currentStyles.blendMode;
			
			if (_dropShadowFilter != null)
			{
				removeFilter(_dropShadowFilter);
			}
			if (_currentStyles.textShadowColor != null)
			{
				_dropShadowFilter = Filters.dropShadowFilterFromStyleObjectForName(
					_currentStyles, 'text');
				addFilter(_dropShadowFilter);
			}
			
			if (_currentStyles.visibility == 'hidden' && _visible)
			{
				_visible = visible = false;
			}
			else if (_currentStyles.visibility != 'hidden' && !_visible)
			{
				_visible = visible = true;
			}
			
			if (_currentStyles.cursor == 'pointer')
			{
				if (!buttonMode)
				{
					buttonMode = true;
					useHandCursor = true;
				}
			}
			else if (buttonMode)
			{
				buttonMode = false;
				useHandCursor = false;
			}
			
			super.rotation = _currentStyles.rotation;
			super.alpha = _currentStyles.opacity;
		}
		
		protected function resolvePositioningProperties() : void
		{
			if (_currentStyles.float == 'none')
			{
				_currentStyles.float = null;
			}
			
			var positioning : String = _positioningType = _currentStyles.position;
			
			if (!_currentStyles.float &&
				(positioning == 'static' || positioning == 'relative'))
			{
				_positionInFlow = 1;
			}
			else
			{
				_positionInFlow = 0;
			}
		}
		
		protected function addComponentToDisplayList(component : UIComponent, lower : Boolean) : void
		{
			if (lower)
			{
				!_lowerContentDisplay && createLowerContentDisplay();
				component.parent != _lowerContentDisplay &&
					_lowerContentDisplay.addChild(component);
			}
			else
			{
				!_upperContentDisplay && createUpperContentDisplay();
				component.parent != _upperContentDisplay &&
					_upperContentDisplay.addChild(component);
			}
		}

		/**
		 * resolves the element that acts as the containing block for this element.
		 * 
		 * The containing block is defined as follows:
		 * - if an explicit containg block is provided using 
		 * overrideContainingBlock, the override is used
		 * - if the elements' position is 'static' or 'relative', its 
		 * containing block is its parentElement
		 * - if the elements' position is 'absolute', its containing block
		 * is the next ancestor with a position other than 'static'
		 * - if the elements' position is 'static', its containing block
		 * is the viewPort
		 */
		protected function resolveContainingBlock() : void
		{
			if (_explicitContainingBlock)
			{
				_containingBlock = _explicitContainingBlock;
			}
			else
			{
				var parentComponent : UIComponent = UIComponent(_parentElement);
				if (_positioningType == 'fixed')
				{
					_containingBlock = _rootElement;
				}
				else if (_positioningType == 'absolute')
				{
					var inspectedBlock : UIComponent = parentComponent;
					while (inspectedBlock && 
						inspectedBlock._positioningType == 'static')
					{
						inspectedBlock = inspectedBlock._containingBlock;
					}
					_containingBlock = inspectedBlock;
				}
				else
				{
					_containingBlock = parentComponent;
				}
			}
		}
		
		protected function resolveRelativeStyles(styles : CSSDeclaration, 
			parentW : int = -1, parentH : int = -1) : void
		{
			var borderBoxSizing : Boolean = _currentStyles.boxSizing == 'border-box';
			
			if (parentW == -1)
			{
				parentW = _containingBlock.innerWidth();
			}
			if (parentH == -1)
			{
				parentH = _containingBlock.innerHeight();
			}
			
			resolvePropsToValue(styles, WIDTH_RELATIVE_PROPERTIES, parentW);
			
			//calculate border widths. width resolution relies on correct border widths, 
			//so we have to do this here.
			for each (var borderName : String in EDGE_NAMES)
			{
				var style : String = _currentStyles['border' + borderName + 'Style'];
				if (style == 'none')
				{
					_currentStyles['border' + borderName + 'Width'] = 0;
				}
			}
			
			
			var wProp : CSSProperty = styles.getStyle('width');
			var baseWidth : int = _currentStyles.width;
			if (!wProp || wProp.specifiedValue() == 'auto')
			{
				_autoFlags.width = true;
				if (!_positionInFlow)
				{
					_contentBoxWidth = _currentStyles.width = parentW -
						_currentStyles.left - _currentStyles.right -
						_currentStyles.marginLeft - _currentStyles.marginRight -
						_currentStyles.paddingLeft - _currentStyles.paddingRight -
						_currentStyles.borderLeftWidth - _currentStyles.borderRightWidth;
				}
				else
				{
					_contentBoxWidth = _currentStyles.width = parentW -
						_currentStyles.marginLeft - _currentStyles.marginRight -
						_currentStyles.paddingLeft - _currentStyles.paddingRight -
						_currentStyles.borderLeftWidth - _currentStyles.borderRightWidth;
				}
			}
			else if (wProp.isWeak())
			{
				_autoFlags.width = true;
			}
			else
			{
				_autoFlags.width = false;
				if (wProp.isRelativeValue())
				{
					var relevantWidth : int = parentW;
					if (_positioningType == 'absolute')
					{
						relevantWidth += 
							_containingBlock._currentStyles.paddingLeft +
							_containingBlock._currentStyles.paddingRight;
					}
					_currentStyles.width =
						wProp.resolveRelativeValueTo(relevantWidth, this);
				}
				else if (borderBoxSizing)
				{
					_currentStyles.width = wProp.specifiedValue();
				}
				if (borderBoxSizing)
				{
					_currentStyles.width -=
						_currentStyles.borderLeftWidth + _currentStyles.paddingLeft +
						_currentStyles.borderRightWidth + _currentStyles.paddingRight;
					if (_currentStyles.width < 0)
					{
						_currentStyles.width = 0;
					}
				}
				_contentBoxWidth = _currentStyles.width || 0;
			}
			if (!_changedStyleProperties.width && _currentStyles.width != baseWidth)
			{
				_changedStyleProperties.addChange('width');
			}
			
			resolvePropsToValue(styles, HEIGHT_RELATIVE_PROPERTIES, parentH);
			_contentBoxHeight = _currentStyles.height;
			
			if (borderBoxSizing && !_autoFlags.height)
			{
				var baseHeight : int = styles.getStyle('height').resolveRelativeValueTo(parentH);
				_contentBoxHeight = baseHeight -
					(_currentStyles.borderTopWidth + _currentStyles.paddingTop +
					_currentStyles.borderBottomWidth + _currentStyles.paddingBottom);
				if (_contentBoxHeight < 0)
				{
					_contentBoxHeight = 0;
				}
				_currentStyles.height = _contentBoxHeight;
				if (!_changedStyleProperties.height && _contentBoxHeight != baseHeight)
				{
					_changedStyleProperties.addChange('height');
				}
			}
			//TODO: verify that we should really resolve the border-radii this way
			resolvePropsToValue(styles, OWN_WIDTH_RELATIVE_PROPERTIES, 
				_contentBoxWidth + _currentStyles.borderTopWidth);
			
			//reset collapsed margins to be identical with initial margins
			_currentStyles.collapsedMarginTop = _currentStyles.marginTop;
			_currentStyles.collapsedMarginBottom =  _currentStyles.marginBottom;
		}
		
		protected function resolvePropsToValue(styles : CSSDeclaration, 
			props : Array, baseValue : Number) : void
		{
			for (var i : int = props.length; i--;)
			{
				var propName : String = props[i][0];
				var cssProperty : CSSProperty = styles.getStyle(propName);
				if (cssProperty)
				{
					if (cssProperty.isRelativeValue())
					{
						var oldValue : int = _currentStyles[propName];
						_currentStyles[propName] = Math.round(
							cssProperty.resolveRelativeValueTo(baseValue, this));
						if (!_changedStyleProperties[propName] &&
							_currentStyles[propName] != oldValue)
						{
							_changedStyleProperties.addChange('propName');
						}
					}
					_autoFlags[propName] = cssProperty.isAuto() || cssProperty.isWeak();
				}
				else 
				{
					_autoFlags[propName] = props[i][1];
					_currentStyles[propName] = 0;
				}
			}
		}
		
		/**
		 * calculates the vertical space taken by this elements' content
		 */
		protected function calculateContentHeight() : int
		{
			return _contentBoxHeight;
		}
		
		/**
		 * calculates the horizontal space taken by this elements' content
		 */
		protected function calculateContentWidth() : int
		{
			return _contentBoxWidth;
		}

		protected function applyInFlowChildPositions() : void
		{
			_layoutManager.applyFlowPositions(this, _children);
			_intrinsicWidth = _currentStyles.intrinsicWidth;
			_intrinsicHeight = _currentStyles.intrinsicHeight;
		}
		
		protected function applyOutOfFlowChildPositions() : void
		{
			if (!_isRendered)
			{
				return;
			}
			_layoutManager.applyAbsolutePositions(this, _children);
			for each (var child : UIObject in _children)
			{
				//only deal with rendered children that derive from UIComponent
				if (!(child is UIComponent) || !UIComponent(child).isRendered())
				{
					continue;
				}
				UIComponent(child).applyOutOfFlowChildPositions();
			}
			super.calculateKeyLoop();
		}

		/**
		 * this override prevents key loop calculation from happening before all 
		 * relevant data is gathered. Specifically, element positions aren't finalized 
		 * before applyOutOfFlowChildPositions is invoked recursively from the outermost 
		 * invalid element. Because of this relationship, we invoke the super 
		 * implementation from applyOutOfFlowChildPositions.
		 */
		protected override function calculateKeyLoop() : void
		{
		}
		
		
		/**
		 * parses the elements' xmlDefinition as set through innerHTML
		 */
		protected function parseXMLDefinition(xmlDefinition : XML) : void
		{
			_xmlDefinition = xmlDefinition;
			parseXMLAttributes(xmlDefinition);
			parseXMLContent(xmlDefinition.children());
			
			invalidateStyles();
		}
		
		protected function invalidateStyles() : void
		{
			if (_isValidating)
			{
				_invalidateStylesAfterValidation = true;
			}
			else
			{
				_stylesInvalidated = true;
				invalidate();
			}
		}

		protected function parseXMLAttributes(node : XML) : void
		{
			if (node.nodeKind() == 'text')
			{
				//TODO: check if this can happen at all. Shouldn't a text node be 
				//rendered by the label component anyway?
				//this element is a textNode and is therefore guaranteed to have no
				//styles attached. It should completely use its parents' styles.
				//_domPath = _parentElement.domPath;
				_elementType = "p";
			}
			else 
			{
				var attributes : Object = {};
				for each (var attribute : XML in node.@*)
				{
					if (attribute.nodeKind() != 'text')
					{
						var attributeName : String = attribute.localName().toString();
						var attributeValue : String = attribute.toString();
						attributes[attributeName] = attributeValue;
						assignValueFromAttribute(attributeName, attributeValue);
					}
				}
				_nodeAttributes = attributes;
				_elementType = node.localName().toString();
			}
		}
		
		/**
		 * Tries invoking a setter named after the schema 
		 * 'set[capitalized attribute name]Attribute'. 
		 * If that fails, the method invokes setValueForKey to try to assign the value 
		 * by other means.
		 */
		private function assignValueFromAttribute(
			attribute : String, value : String) : void
		{
			var usedValue : * = resolveBindings(value);
			try
			{
				var attributeSetterName : String = 'set' + 
					attribute.charAt(0).toUpperCase() + attribute.substr(1) + 'Attribute';
				this[attributeSetterName](usedValue);
			}
			catch (error : Error)
			{
				try
				{
					setValueForKey(attribute, usedValue);
				}
				catch (error : Error)
				{
				}
			}
		}
		protected function resolveBindings(text : String) : *
		{
			var result : * = text;
			var valueParts : Array = text.split(/(?<!\\){|(?<!\\)}/);
			if (valueParts.length > 1)
			{
				for (var i : int = 1; i < valueParts.length; i += 2)
				{
					var bindingParts : Array = valueParts[i].split(/\s*,\s*/);
					var selectorPath : String = '';
					if (bindingParts.length == 2)
					{
						selectorPath = bindingParts.shift();
					}
					var propertyParts : Array = bindingParts[0].split(/\s*:\s*/);
					try
					{
						valueParts[i] = valueBySelectorProperty.
							apply(this, [selectorPath].concat(propertyParts));
					}
					catch (error : Error)
					{
						valueParts[i] = '{' + valueParts[i] + '}';
					}
				}
				if (valueParts.length > 3 || valueParts[0] != '' || valueParts[2] != '')
				{
					result = valueParts.join('');
				}
				else
				{
					result = valueParts[1];
				}
			}
			return result;
		}
		
		/**
		 * parses and displays the elements' childNodes
		 */
		protected function parseXMLContent(children : XMLList) : void
		{
			XML.prettyPrinting = false;
			var childNode : XML = children[0];
			var state : Object = {nodeIsEmpty : false};
			while (childNode)
			{
				childNode = preprocessTextNode(childNode, state);
				if (state.nodeIsEmpty)
				{
					childNode = childNode.parent().children()[childNode.childIndex() + 1];
					state.nodeIsEmpty = false;
					continue;
				}
				var child : UIComponent = 
					_rootElement.uiRendererFactory().rendererByNode(childNode);
				if (child)
				{
					addChild(child);
					child.parseXMLDefinition(childNode);
				}
				else
				{
					log("f No handler found for node: " + childNode.toXMLString());
				}
				childNode = childNode.parent().children()[childNode.childIndex() + 1];
			}
		}
		
		protected function preprocessTextNode(node : XML, state : Object = null) : XML
		{
			var textNodeTags : String = UIRendererFactory.TEXTNODE_TAGS;
			if (textNodeTags.indexOf(node.localName() + ",") == -1)
			{
				return node;
			}
			var nodesToCombine : XMLList = new XMLList(node);
			var parentNode : XML = node.parent() as XML;
			var siblings : XMLList = parentNode ? parentNode.* : null;
			if (!siblings)
			{
				return node;
			}
			//TODO: find a cleaner way to combine text nodes
			for (var i : int = node.childIndex() + 1; 
				i < XMLList(parentNode.*).length();)
			{
				var sibling : XML = XMLList(parentNode.*)[i];
				if (textNodeTags.indexOf(sibling.localName() + ',') == -1)
				{
					break;
				}
				nodesToCombine += sibling;
				delete parentNode.*[i];
			}
			XML.ignoreWhitespace = false;
			var xmlParser : XML = <p/>;
			xmlParser.setChildren(nodesToCombine);
			siblings[node.childIndex()] = xmlParser;
			XML.ignoreWhitespace = true;
			if (state && xmlParser.text().toString().search(/\S/g) == -1)
			{
				state.nodeIsEmpty = true;
			}
			return xmlParser;
		}
		
		
		/**
		 * draws the background rect and borders according to the styles 
		 * specified for this element.
		 */
		protected function applyBackgroundAndBorders() : void
		{
			if (_currentStyles.backgroundColor || _currentStyles.backgroundImage ||
				(_currentStyles.backgroundGradientColors &&
				_currentStyles.backgroundGradientType))
			{
				var backgroundRendererId : String = 
					_currentStyles.backgroundRenderer || "";
				if (!_backgroundRenderer ||
					_backgroundRenderer.id() != backgroundRendererId)
				{
					if (_backgroundDisplay)
					{
						_backgroundRenderer.destroy();
						removeChild(_backgroundDisplay);
					}
					_backgroundDisplay = new Sprite();
					_backgroundDisplay.name = "background_" + backgroundRendererId;
					_contentDisplay.addChildAt(_backgroundDisplay, 0);
					_backgroundRenderer = _rootElement.uiRendererFactory().
						backgroundRendererById(backgroundRendererId);
					_backgroundRenderer.setDisplay(_backgroundDisplay);
				}
				_backgroundDisplay.visible = true;
				
				_backgroundDisplay.x = 0 - _currentStyles.borderLeftWidth;
				_backgroundDisplay.y = 0 - _currentStyles.borderTopWidth;
				_backgroundRenderer.setSize(_borderBoxWidth, _borderBoxHeight);
				_backgroundRenderer.setStyles(_currentStyles);
				_backgroundRenderer.setComplexStyles(_complexStyles);
				_backgroundRenderer.draw();
				//TODO: move into renderer
				_backgroundDisplay.blendMode =
					_currentStyles.backgroundBlendMode || 'normal';
			}
			else
			{
				if (_backgroundDisplay)
				{
					_backgroundDisplay.visible = false;
				}
			}
			
			if (_currentStyles.borderTopStyle || _currentStyles.borderRightStyle ||
				_currentStyles.borderBottomStyle || _currentStyles.borderLeftStyle)
			{
				var borderRendererId : String = _currentStyles.borderRenderer || "";
				if (!_borderRenderer || _borderRenderer.id() != borderRendererId)
				{
					if (_bordersDisplay)
					{
						_borderRenderer.destroy();
						removeChild(_bordersDisplay);
					}
					_bordersDisplay = new Sprite();
					_bordersDisplay.name = "border_" + borderRendererId;
					_contentDisplay.addChildAt(_bordersDisplay, _upperContentDisplay
						? _contentDisplay.getChildIndex(_upperContentDisplay)
						: _contentDisplay.numChildren);
					_borderRenderer = _rootElement.uiRendererFactory().
						borderRendererById(borderRendererId);
					_borderRenderer.setDisplay(_bordersDisplay);
				}
				_bordersDisplay.visible = true;
				
				_bordersDisplay.x = 0 - _currentStyles.borderLeftWidth;
				_bordersDisplay.y = 0 - _currentStyles.borderTopWidth;
				
				_borderRenderer.setSize(_borderBoxWidth, _borderBoxHeight);
				_borderRenderer.setStyles(_currentStyles);
				_borderRenderer.setComplexStyles(_complexStyles);
				_borderRenderer.draw();
			}
			else
			{
				if (_bordersDisplay)
				{
					_bordersDisplay.visible = false;
				}
			}
		}
		protected function applyOverflowProperty() : void
		{
			var maskNeeded : Boolean = false;
			var scrollersNeeded : Boolean = false;
			
			var ofx : * = _currentStyles.overflowX;
			var ofy : * = _currentStyles.overflowY;
			
			if (ofx == 'visible' || ofx == null || ofx == 'hidden')
			{
				if (_hScrollbar)
				{
					_hScrollbar.setVisibility(false);
					hScroll = 0;
				}
				if (ofx == 'hidden') maskNeeded = true;
			}
			else
			{
				maskNeeded = scrollersNeeded = true;
			}
			
			if (ofy == 'visible' || ofy == null || ofy == 'hidden')
			{
				if (_vScrollbar)
				{
					_vScrollbar.setVisibility(false);
					vScroll = 0;
				}
				if (ofy == 'hidden') maskNeeded = true;
			}
			else
			{
				maskNeeded = scrollersNeeded = true;
			}
			
			if (scrollersNeeded) 
			{
				applyScrollbars();
			}
			
			if (maskNeeded)
			{
				applyMask();
			}
			else
			{
				_lowerContentDisplay && (_lowerContentDisplay.mask = null);
				_upperContentDisplay && (_upperContentDisplay.mask = null);
			}
		}

		protected function applyMask() : void
		{
			var maskW : int = 
				(_currentStyles.overflowX == 'visible' || _currentStyles.overflowX == null)
					? _borderBoxWidth
					: innerWidth() + _currentStyles.paddingLeft + _currentStyles.paddingRight;
			var maskH : int = 
				(_currentStyles.overflowY == 'visible' || _currentStyles.overflowY == null)
					? _borderBoxHeight
					: innerHeight() + _currentStyles.paddingTop + _currentStyles.paddingBottom;
			
			var radii : Array = 
			[
				_currentStyles['borderTopLeftRadius'] || 0,
				_currentStyles['borderTopRightRadius'] || 0,
				_currentStyles['borderBottomRightRadius'] || 0,
				_currentStyles['borderBottomLeftRadius'] || 0
			];
			
			if (_lowerContentDisplay)
			{
				if (!_lowerContentMask)
				{
					_lowerContentMask = new Sprite();
					addChild(_lowerContentMask);
					_lowerContentMask.visible = false;
				}
				
				_lowerContentMask.x = _currentStyles.borderLeftWidth;
				_lowerContentMask.y = _currentStyles.borderTopWidth;
				
				_lowerContentMask.graphics.clear();
				_lowerContentMask.graphics.beginFill(0x00ff00, 50);
				GfxUtil.drawRoundRect(_lowerContentMask, 0, 0, maskW, maskH, radii);
				
				_lowerContentDisplay.mask = _lowerContentMask;
			}
			if (_upperContentDisplay)
			{
				if (!_upperContentMask)
				{
					_upperContentMask = new Sprite();
					addChild(_upperContentMask);
					_upperContentMask.visible = false;
				}
				
				_upperContentMask.x = _currentStyles.borderLeftWidth;
				_upperContentMask.y = _currentStyles.borderTopWidth;
				
				_upperContentMask.graphics.clear();
				_upperContentMask.graphics.beginFill(0x00ff00, 50);
				GfxUtil.drawRoundRect(_upperContentMask, 0, 0, maskW, maskH, radii);
				
				_upperContentDisplay.mask = _upperContentMask;
			}
		}
		
		protected function applyScrollbars() : void
		{
			function childWidth() : int
			{
				var widestChildWidth : int = 0;
				var childCount : int = _children.length;
				while (childCount--)
				{
					var child : UIComponent = _children[childCount] as UIComponent;
					var childX : int = 
						child._currentStyles.position == 'absolute' ? child.x : 0;
					widestChildWidth = Math.max(
						childX + child._borderBoxWidth + child._currentStyles.marginRight -
						_currentStyles.paddingLeft, widestChildWidth);
				}
				return widestChildWidth;
			}
			
			var vScrollerNeeded : Boolean;
			var hScrollerNeeded : Boolean;
			
			if (_currentStyles.overflowY == 0 && _intrinsicHeight > _currentStyles.height)
			{
				if (!_vScrollbar)
				{
					_vScrollbar = createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
					addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel_turn);
				}
				_vScrollbar.setVisibility(true);
				if (_currentStyles.overflowX == 'scroll' || _currentStyles.overflowX == 0)
				{
					validateChildren();
					applyInFlowChildPositions();
					_intrinsicWidth = childWidth();
				}
				vScrollerNeeded = true;
			}
			
			if (_currentStyles.overflowY == 'scroll')
			{
				vScrollerNeeded = true;
			}
			
			if (_currentStyles.overflowX == 0 && _intrinsicWidth > _currentStyles.width)
			{
				if (!_hScrollbar)
				{
					_hScrollbar = createScrollbar(Scrollbar.ORIENTATION_HORIZONTAL);
				}
				_hScrollbar.setVisibility(true);
				if (vScrollerNeeded)
				{
					var oldIntrinsicWidth : int = _intrinsicWidth;
					validateChildren();
					applyInFlowChildPositions();
					applyOutOfFlowChildPositions();
					_intrinsicWidth = oldIntrinsicWidth;
				}
				hScrollerNeeded = true;
			}

			if (_currentStyles.overflowX == 'scroll')
			{
				hScrollerNeeded = true;
			}

			if (vScrollerNeeded)
			{
				_vScrollbar.setScrollProperties(innerHeight(), 0,
					_intrinsicHeight - innerHeight());
				_vScrollbar.top = 0;
				_vScrollbar.height =
					innerHeight() + _currentStyles.paddingTop + _currentStyles.paddingBottom;
				_vScrollbar.left = _currentStyles.width - _vScrollbar.outerWidth +
					_currentStyles.paddingLeft + _currentStyles.paddingRight;
				(_vScrollbar as UIComponent).validateElement(true, true);
				verticalScrollbar_change();
			}
			else
			{
				if (_vScrollbar)
				{
					_vScrollbar.setVisibility(false);
					vScroll = 0;
				}
			}
			
			if (hScrollerNeeded)
			{
				_hScrollbar.setScrollProperties(
					innerWidth(), 0, _intrinsicWidth - innerWidth());
				_hScrollbar.top = _currentStyles.height +
					_currentStyles.paddingTop + _currentStyles.paddingRight;
				_hScrollbar.height =
					innerWidth() + _currentStyles.paddingLeft + _currentStyles.paddingRight;
				(_hScrollbar as UIComponent).validateElement(true, true);
				horizontalScrollbar_change();
			}
			else
			{
				if (_hScrollbar)
				{
					_hScrollbar.setVisibility(false);
					hScroll = 0;
				}
			}
		}
		
		protected function createScrollbar(
			orientation : String, skipListenerRegistration : Boolean = false) : Scrollbar
		{
			if (!_scrollbarsDisplay)
			{
				_scrollbarsDisplay = new Sprite();
				_scrollbarsDisplay.name = 'scrollbars_display';
				addChild(_scrollbarsDisplay);
			}
			var scrollbar : Scrollbar = new Scrollbar();
			scrollbar.setOverflowScrollMode(true);
			scrollbar.setParent(this);
			scrollbar.overrideContainingBlock(this);
			_scrollbarsDisplay.addChild(scrollbar);
			scrollbar.cssClasses = orientation + "Scrollbar";
			scrollbar.setStyle('position', 'absolute');
			scrollbar.setStyle('autoHide', 'false');
			//TODO: remove scrollbarWidth property
			scrollbar.setStyle(
				'width', (_currentStyles.scrollbarWidth || DEFAULT_SCROLLBAR_WIDTH) + 'px');
			if (orientation == Scrollbar.ORIENTATION_HORIZONTAL)
			{
				scrollbar.rotation = -90;
			}
			if (!skipListenerRegistration)
			{
				scrollbar.addEventListener(
					Event.CHANGE, this[orientation + 'Scrollbar_change']);
			}
			scrollbar.addEventListener(MouseEvent.CLICK, scrollbar_click);
			(scrollbar as UIComponent).validateElement(true, true);
			return scrollbar;
		}
		
		protected function scrollbar_click(event : Event) : void
		{
			event.stopImmediatePropagation();
			event.stopPropagation();
		}
		
		protected function verticalScrollbar_change(event : Event = null) : void
		{
			_lowerContentDisplay && (_lowerContentDisplay.y = -_vScrollbar.scrollPosition);
			_upperContentDisplay && (_upperContentDisplay.y = -_vScrollbar.scrollPosition);
		}
		
		protected function horizontalScrollbar_change(event : Event = null) : void
		{
			_lowerContentDisplay && (_lowerContentDisplay.x = -_hScrollbar.scrollPosition);
			_upperContentDisplay && (_upperContentDisplay.x = -_hScrollbar.scrollPosition);
		}
		
		protected function mouseWheel_turn(event : MouseEvent) : void
		{
			if (event.shiftKey && _hScrollbar)
			{
				_hScrollbar.scrollPosition -= _hScrollbar.lineScrollSize * event.delta;
				_lowerContentDisplay && (_lowerContentDisplay.x = -_hScrollbar.scrollPosition);
				_upperContentDisplay && (_upperContentDisplay.x = -_hScrollbar.scrollPosition);
			}
			else if ((!event.shiftKey && _vScrollbar) ||
				(event.shiftKey && (!_hScrollbar || !_hScrollbar.visibility())))
			{
				_vScrollbar.scrollPosition -= _vScrollbar.lineScrollSize * event.delta;
				_lowerContentDisplay && (_lowerContentDisplay.y = -_vScrollbar.scrollPosition);
				_upperContentDisplay && (_upperContentDisplay.y = -_vScrollbar.scrollPosition);
			}
		}
		
		protected function i18n(key : String, defaultReturnValue : * = null) : *
		{
			return _rootElement.applicationContext().i18n(key, defaultReturnValue);
		}

		protected function track(trackingId : String) : void
		{
			_rootElement.applicationContext().track(trackingId);
		}

		/**
		 * Hook method. Measures the intrinsic dimensions of the component.
		 * The default implementation calculates the intrinsic height based
		 * on the bottom of the last child that's positioned in-flow and the 
		 * intrinsic width based on the style defined value.
		 * This value is then applied to the height property as the calculated value.
		 */
		protected function measure() : void
		{
		}
		
		reprise function valueForKey(key : String) : *
		{
			return this[key];
		}

		reprise function setValueForKey(key : String, value : *) : void
		{
			//try to assign to a setter method by prepending 'set'
			try
			{
				var setterName : String = 'set' + key.charAt(0).toUpperCase() + key.substr(1);
				this[setterName](value);
			}
			catch (error : Error)
			{
				//failed, try to assign to a property
				this[key] = value;
			}
		}
		
		public function applyTransform() : void
		{
			if (_currentStyles.transform)
			{
				var originX : Number = _borderBoxWidth / 2;
				var originY : Number = _borderBoxHeight / 2;
				if (_complexStyles.hasStyle('transformOriginX'))
				{
					originX = _complexStyles.getStyle('transformOriginX').
						resolveRelativeValueTo(_borderBoxWidth);
				}
				else
				{
					originX = _borderBoxWidth / 2;
				}
				if (_complexStyles.hasStyle('transformOriginY'))
				{
					originY = _complexStyles.getStyle('transformOriginY').
						resolveRelativeValueTo(_borderBoxHeight);
				}
				else
				{
					originY = _borderBoxHeight / 2;
				}
				
				var transformations : Array = _currentStyles.transform;
				var matrix : Matrix = TRANSFORM_MATRIX;
				matrix.identity();
				
				matrix.translate(-originX, -originY);
				var length : int = transformations.length;
				for (var i : int = length; i--;)
				{
					var transformation : Object = transformations[i];
					var parameters : Array = transformation.parameters;
					switch (transformation.type)
					{
						case 'translate' : 
						{
							matrix.translate(
								CSSProperty(parameters[0]).
								resolveRelativeValueTo(_borderBoxWidth),
								CSSProperty(parameters[1]).
								resolveRelativeValueTo(_borderBoxHeight));
							break;
						}
						case 'translateX' : 
						{
							matrix.translate(
								CSSProperty(parameters[0]).
								resolveRelativeValueTo(_borderBoxWidth), 0);
							break;
						}
						case 'translateY' : 
						{
							matrix.translate(0,
								CSSProperty(parameters[1]).
								resolveRelativeValueTo(_borderBoxHeight));
							break;
						}
						case 'rotate' : 
						{
							matrix.rotate(parameters[0]);
							break;
						}
						case 'scale' : 
						{
							matrix.scale(parameters[0], parameters[1]);
							break;
						}
						case 'scaleX' : 
						{
							matrix.scale(parameters[0], 1);
							break;
						}
						case 'scaleY' : 
						{
							matrix.scale(1, parameters[1]);
							break;
						}
						case 'skew' : 
						{
							matrix.concat(new Matrix(1, parameters[1], parameters[0]));
							break;
						}
						case 'skewX' : 
						{
							matrix.concat(new Matrix(1, 0, parameters[0]));
							break;
						}
						case 'skewY' : 
						{
							matrix.concat(new Matrix(1, parameters[1]));
							break;
						}
						case 'matrix' : 
						{
							matrix.concat(Matrix(parameters[0]));
							break;
						}
					}
				}
				matrix.translate(originX, originY);
				if (_positioningType == 'relative')
				{
					matrix.translate(_currentStyles.left, _currentStyles.top);
				}
				_contentDisplay.transform.matrix = matrix;
				if (_scrollbarsDisplay)
				{
					_scrollbarsDisplay.transform.matrix = matrix;
				}
			}
		}
	}
}