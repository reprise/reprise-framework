
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

package reprise.ui
{
	import reprise.controls.Scrollbar;
	import reprise.core.UIRendererFactory;
	import reprise.core.reprise;
	import reprise.css.CSSDeclaration;
	import reprise.css.CSSParsingHelper;
	import reprise.css.CSSProperty;
	import reprise.css.ComputedStyles;
	import reprise.css.math.ICSSCalculationContext;
	import reprise.css.propertyparsers.Filters;
	import reprise.css.transitions.CSSTransitionsManager;
	import reprise.ui.layoutmanagers.CSSBoxModelLayoutManager;
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
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
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
		
		protected static const DEFAULT_SCROLLBAR_WIDTH : int = 16;
		
		protected static const IDENTITY_MATRIX : Matrix = new Matrix();
		protected static const TRANSFORM_MATRIX : Matrix = new Matrix();
		
		
		//attribute properties
		protected var m_xmlDefinition : XML;
		protected var m_xmlURL : String = '';
		protected var m_nodeAttributes : Object;
		protected var m_cssClasses : String = "";
		protected var m_cssPseudoClasses : String = "";
		protected var m_cssId : String = "";
		protected var m_selectorPath : String;
		
		//style properties
		protected var m_currentStyles : ComputedStyles;
		protected var m_complexStyles : CSSDeclaration;
		protected var m_instanceStyles : CSSDeclaration;
		protected var m_weakStyles : CSSDeclaration;
		protected var m_elementDefaultStyles : CSSDeclaration;
		
		protected var m_autoFlags : Object = {};
		protected var m_positionInFlow : int = 1;
		protected var m_positioningType : String;
		protected var m_freezeDisplay : Boolean;
		protected var m_isFrozen : Boolean;
		
		//validation properties
		protected var m_stylesInvalidated : Boolean;
		protected var m_dimensionsChanged : Boolean;
		protected var m_specifiedDimensionsChanged : Boolean;
		protected var m_selectorPathChanged : Boolean;
		protected var m_oldContentBoxWidth : int;
		protected var m_oldContentBoxHeight : int;
		
		//dimensions and position
		protected var m_contentBoxWidth : int = 0;
		protected var m_contentBoxHeight : int = 0;
		protected var m_borderBoxHeight : int = 0;
		protected var m_borderBoxWidth : int = 0;
		protected var m_paddingBoxHeight : int = 0;
		protected var m_paddingBoxWidth : int = 0;

		protected var m_intrinsicWidth : int = -1;
		protected var m_intrinsicHeight : int = -1;

		protected var m_positionOffset : Point;
		
		//managers and renderers
		protected var m_layoutManager : CSSBoxModelLayoutManager;
		protected var m_borderRenderer : ICSSRenderer;
		protected var m_backgroundRenderer : ICSSRenderer;
		
		//displays
		protected var m_containingBlock : UIComponent;
		
		protected var m_upperContentDisplay : Sprite;
		protected var m_lowerContentDisplay : Sprite;
		protected var m_backgroundDisplay : Sprite;
		protected var m_bordersDisplay : Sprite;
		protected var m_upperContentMask : Sprite;
		protected var m_lowerContentMask : Sprite;
		protected var m_frozenContent : BitmapData;
		protected var m_frozenContentDisplay : Bitmap;
		
		protected var m_vScrollbar : Scrollbar;
		public var m_hScrollbar : Scrollbar;
		
		protected var m_dropShadowFilter : DropShadowFilter;
		
		
		/***************************************************************************
		*							private properties							   *
		***************************************************************************/
		private var m_explicitContainingBlock : UIComponent;
		private var m_specifiedStyles : CSSDeclaration;
		private var m_transitionsManager : CSSTransitionsManager;
		private var m_scrollbarsDisplay : Sprite;
		private var m_oldInFlowStatus : int = -1;
		private var m_oldOuterBoxDimension : Point;
		private var m_invalidateStylesAfterValidation : Boolean;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/ 
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
		 * @param classes The css classes the component should have.
		 * @param id The css id the component should have.
		 * @param componentClass The ActionScript class to instantiate. If this is 
		 * omitted, an instance of UIComponent will be created.
		 * @param index The index at which the element should be added. If this is 
		 * omitted, the element will be created at the next available index.
		 * 
		 * @return The newly created element
		 */
		public function addComponent(classes : String = null, id : String = null, 
			componentClass : Class = null, index : int = -1) : UIComponent
		{
			if (!componentClass)
			{
				componentClass = UIComponent;
			}
			var component : UIComponent;
			if (index == -1)
			{
				component = UIComponent(addChild(new componentClass()));
			}
			else
			{
				component = UIComponent(addChildAt(new componentClass(), index));
			}
			if (id)
			{
				component.cssID = id;
			}
			if (classes)
			{
				component.cssClasses = classes;
			}
			return component;
		}
		
		/**
		 * initializes the UIComponent structure from the given xml structure, 
		 * creating child views as needed.
		 * 
		 * Using setInnerXML, entire structures of child elements can be created based on the 
		 * supplied XML structure. For a description of how the XML is interpreted, see the 
		 * documentation for UIRendererFactory.
		 * 
		 * @param	xml	the XML structure to parse
		 * @return		The instance that setInnerXML is invoked on, so that calls can be chained
		 * @see 		UIRendererFactory
		 * 
		 * TODO: check if this method should call parseXMLDefinition to fully initialize 
		 * using the xml data (including attributes)
		 */
		public function setInnerXML(xml:XML) : UIComponent
		{
			m_xmlDefinition.setChildren(xml.children());
			parseXMLContent(xml);
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
			return m_containingBlock;
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
			return m_contentBoxWidth;
		}
		/**
		 * Returns the elements width including padding and borders.
		 * 
		 * Note that this value is only guaranteed to be available for valid elements.
		 */
		public function get outerWidth() : int
		{
			return m_borderBoxWidth;
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
			return m_intrinsicWidth;
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
			return m_contentBoxHeight;
		}
		/**
		 * Returns the elements height including padding and borders.
		 * 
		 * Note that this value is only guaranteed to be available for valid elements.
		 */
		public function get outerHeight() : int
		{
			return m_borderBoxHeight;
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
			return m_intrinsicHeight;
		}
		
		/**
		 * Returns the elements top position.
		 * 
		 * The returned value is the value currently specified and is to be interpreted differently 
		 * depending on the value of the CSS property 'position'.
		 * <p>
		 * Note that this value is only guaranteed to be available for valid elements.
		 * 
		 * @see http://www.reprise-framework.org/doc/css/positioning.html#top 
		 * 		CSS documentation for top
		 * @return The elements current top position
		 */
		public function get top() : Number
		{
			if (!isNaN(m_currentStyles.top))
			{
				return m_currentStyles.top;
			}
			if (!isNaN(m_currentStyles.bottom))
			{
				return m_containingBlock.calculateContentHeight() - 
					m_currentStyles.bottom - m_borderBoxHeight;
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
		 * @see http://www.reprise-framework.org/doc/css/positioning.html#top 
		 * 		CSS documentation for top
		 * @return The elements current top position
		 */
		public function set top(value : Number) : void
		{
			if (isNaN(value))
			{
				value = 0;
			}
			m_currentStyles.top = value;
			m_instanceStyles.setStyle('top', value + "px");
			m_autoFlags.top = false;
			if (!m_positionInFlow)
			{
				var absolutePosition : Point = 
					getPositionRelativeToContext(m_containingBlock);
				absolutePosition.y -= y;
				y = value + m_currentStyles.marginTop - absolutePosition.y;
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
		 * @see http://www.reprise-framework.org/doc/css/positioning.html#left 
		 * 		CSS documentation for left
		 * @return The elements current left position
		 */
		public function get left() : Number
		{
			if (!isNaN(m_currentStyles.left))
			{
				return m_currentStyles.left;
			}
			if (!isNaN(m_currentStyles.right))
			{
				return m_containingBlock.calculateContentWidth() - 
					m_currentStyles.right - m_borderBoxWidth;
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
		 * @see http://www.reprise-framework.org/doc/css/positioning.html#left 
		 * 		CSS documentation for left
		 * @return The elements current left position
		 */
		public function set left(value : Number) : void
		{
			if (isNaN(value))
			{
				value = 0;
			}
			m_currentStyles.left = value;
			m_instanceStyles.setStyle('left', value + "px");
			m_autoFlags.left = false;
			if (!m_positionInFlow)
			{
				var absolutePosition : Point = 
					getPositionRelativeToContext(m_containingBlock);
				absolutePosition.x -= x;
				x = value + m_currentStyles.marginLeft - absolutePosition.x;
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
		 * @see http://www.reprise-framework.org/doc/css/positioning.html#right 
		 * 		CSS documentation for right
		 * @return The elements current right position
		 */
		public function get right() : Number
		{
			if (!isNaN(m_currentStyles.left))
			{
				return m_currentStyles.left + m_borderBoxWidth;
			}
			if (!isNaN(m_currentStyles.right))
			{
				return m_currentStyles.right;
			}
			return 0 + m_borderBoxWidth;
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
		 * @see http://www.reprise-framework.org/doc/css/positioning.html#right 
		 * 		CSS documentation for right
		 * @return The elements current right position
		 */
		public function set right(value : Number) : void
		{
			if (isNaN(value))
			{
				value = 0;
			}
			m_currentStyles.right = value;
			m_instanceStyles.setStyle('right', value + "px");
			m_autoFlags.right = false;
			if (!m_positionInFlow)
			{
				var absolutePosition : Point = 
					getPositionRelativeToContext(m_containingBlock);
				absolutePosition.x -= x;
				x = m_containingBlock.calculateContentWidth() - m_borderBoxWidth - 
					m_currentStyles.right - m_currentStyles.marginRight - absolutePosition.x;
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
		 * @see http://www.reprise-framework.org/doc/css/positioning.html#bottom 
		 * 		CSS documentation for bottom
		 * @return The elements current bottom position
		 */
		public function get bottom() : Number
		{
			if (!isNaN(m_currentStyles.top))
			{
				return m_currentStyles.top + m_borderBoxHeight;
			}
			if (!isNaN(m_currentStyles.bottom))
			{
				return m_currentStyles.bottom;
			}
			return 0 + m_borderBoxHeight;
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
		 * @see http://www.reprise-framework.org/doc/css/positioning.html#bottom 
		 * 		CSS documentation for bottom
		 * @return The elements current bottom position
		 */
		public function set bottom(value : Number) : void
		{
			if (isNaN(value))
			{
				value = 0;
			}
			m_currentStyles.bottom = value;
			m_instanceStyles.setStyle('bottom', value + "px");
			m_autoFlags.bottom = false;
			if (!m_positionInFlow)
			{
				var absolutePosition : Point = 
					getPositionRelativeToContext(m_containingBlock);
				absolutePosition.y -= y;
				y = m_containingBlock.calculateContentHeight() - m_borderBoxHeight - 
					m_currentStyles.bottom - m_currentStyles.marginBottom - absolutePosition.y;
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
			return m_nodeAttributes;
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
			return new Rectangle(x, y, m_borderBoxWidth, m_borderBoxHeight);
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
			return m_contentBoxWidth;
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
			return m_contentBoxHeight;
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
			return m_paddingBoxWidth;
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
			return m_paddingBoxHeight;
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
			return m_borderBoxWidth;
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
			return m_borderBoxHeight;
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
			return m_currentStyles;
		}
		
		/**
		 * Returns the CSS tag name of this element
		 * 
		 * @return The elements CSS tag name
		 */
		public function get cssTag() : String
		{
			return m_elementType;
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
			if (m_cssId)
			{
				m_rootElement.removeElementID(m_cssId);
			}
			m_rootElement && m_rootElement.registerElementID(id, this);
			m_cssId = id;
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
			return m_cssId;
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
			m_cssClasses = classes;
			invalidateStyles();
		}
		/**
		 * Returns the CSS classes of this element
		 * 
		 * @return A space separated list of CSS classes specified for the element
		 */
		public function get cssClasses() : String
		{
			return m_cssClasses;
		}
		
		/**
		 * adds a CSS class if it's not already in the list of CSS classes and invalidates the 
		 * element.
		 * 
		 * @param name The CSS class to add to the element
		 */
		public function addCSSClass(name : String) : void
		{
			if (StringUtil.delimitedStringContainsSubstring(m_cssClasses, name, ' '))
			{
				return;
			}
			m_cssClasses += ' ' + name;
			if (m_cssClasses.charAt(0) == ' ')
			{
				m_cssClasses = m_cssClasses.substr(1);
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
			if (!StringUtil.delimitedStringContainsSubstring(m_cssClasses, name, ' '))
			{
				return;
			}
			m_cssClasses = StringUtil.
				removeSubstringFromDelimitedString(m_cssClasses, name, ' ');
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
			return StringUtil.delimitedStringContainsSubstring(m_cssClasses, className, ' ');
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
			m_cssPseudoClasses = classes;
			invalidateStyles();
		}
		/**
		 * Returns the CSS pseudo classes of this element
		 * 
		 * @return A space separated list of CSS pseudo classes specified for the element
		 */
		public function get cssPseudoClasses() : String
		{
			return m_cssPseudoClasses;
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
				m_cssPseudoClasses, ':' + name, ' '))
			{
				return;
			}
			m_cssPseudoClasses += " :" + name;
			if (m_cssPseudoClasses.charAt(0) == ' ')
			{
				m_cssPseudoClasses = m_cssPseudoClasses.substr(1);
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
				m_cssPseudoClasses, ':' + name, ' '))
			{
				return;
			}
			m_cssPseudoClasses = StringUtil.removeSubstringFromDelimitedString(
				m_cssPseudoClasses, ':' + name, ' ');
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
			m_instanceStyles.setStyle(name, value);
			invalidateStyles();
		}
		
		/**
		 * @inheritDoc
		 */
		public override function tooltipDelay() : int
		{
			return m_currentStyles.tooltipDelay || 0;
		}
		/**
		 * @inheritDoc
		 */
		public override function setTooltipDelay(delay : int) : void
		{
			// we don't need no invalidation
			m_instanceStyles.setStyle('tooltipDelay', delay.toString());
			m_currentStyles.tooltipDelay = delay;
		}
		/**
		 * @inheritDoc
		 */
		public override function tooltipRenderer() : String
		{
			return m_tooltipRenderer;
		}
		/**
		 * @inheritDoc
		 */
		public override function setTooltipRenderer(renderer : String) : void
		{
			// we don't need no invalidation
			m_instanceStyles.setStyle('tooltipRenderer', renderer);
			m_currentStyles.tooltipRenderer = renderer;
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
			m_instanceStyles.setStyle('visibility', visibilityProperty);
			m_currentStyles.visibility = visibilityProperty;
			super.setVisibility(visible);
		}
		
		/**
		 * Freezes the components' display by making a bitmap copy of its current state and showing 
		 * that instead of the actual content.
		 * 
		 * As long as the component is frozen using this method, it is not validated at all, not 
		 * even to check for style changes - it simply can't have any other state than being frozen.
		 */
		public function freezeDisplay() : void
		{
			m_instanceStyles.setStyle('freezeDisplay', 'freeze !important');
			applyDisplayFreezing();
		}

		/**
		 * Unfreezes the component, reactivating its interactive display.
		 * 
		 * Note that this method only reverts the effects of #freezeDisplay. It doesn't actually 
		 * set any styles but only removes the one set by #freezeDisplay.
		 */
		public function unfreezeDisplay() : void
		{
			if (!m_instanceStyles.hasStyle('freezeDisplay') || 
				m_instanceStyles.getStyle('freezeDisplay').specifiedValue() != true ||
				!m_instanceStyles.getStyle('freezeDisplay').important())
			{
				return;
			}
			m_instanceStyles.setStyle('freezeDisplay', null);
			removeDisplayFreezing();
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
			m_currentStyles.opacity = value;
			m_instanceStyles.setStyle('opacity', value.toString());
		}

		/**
		 * Returns the elements opacity as a fraction between 0 and 1
		 * 
		 * @return The value to set opacity to as a fraction between 0 and 1
		 */
		public function get opacity() : Number
		{
			if (m_currentStyles.opacity != null)
			{
				return m_currentStyles.opacity;
			}
			return 1;
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
			m_currentStyles.rotation = value;
			m_instanceStyles.setStyle('rotation', value.toString());
		}
		/**
		 * Returns the elements rotation as a value between 0 and 360
		 * 
		 * @return The elements rotation as a value between 0 and 360
		 */
		public override function get rotation() : Number
		{
			return m_currentStyles.rotation || 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function remove(...args) : void
		{
			if (m_cssId)
			{
				m_rootElement.removeElementID(m_cssId);
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
			
			var len : int = m_children.length;
			for (var i : int = 0; i < len; i++)
			{
				var child : DisplayObject = m_children[i];
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
				element = m_rootElement.getElementById(id);
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
				if (target.m_currentStyles[property])
				{
					return target.m_currentStyles[property];
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
			m_instanceStyles = CSSParsingHelper.parseDeclarationString(value, applicationURL());
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
			if (!m_tooltipData)
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
			return m_transitionsManager.isActive();
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
			return m_transitionsManager.hasActiveTransitionForStyle(style);
		}
		
		
		public function get hScroll():Number
		{
			if (!m_hScrollbar) return 0;
			return m_hScrollbar.scrollPosition;
		}
		
		public function set hScroll(val:Number):void
		{
			if (!m_hScrollbar) return;
			m_hScrollbar.scrollPosition = val;
			m_upperContentDisplay.x = m_lowerContentDisplay.x = -m_hScrollbar.scrollPosition;
		}
		
		public function get vScroll():Number
		{
			if (!m_vScrollbar) return 0;
			return m_vScrollbar.scrollPosition;
		}
		
		public function set vScroll(val:Number):void
		{
			if (!m_vScrollbar) return;
			m_vScrollbar.scrollPosition = val;
			m_upperContentDisplay.y = m_lowerContentDisplay.y = -m_vScrollbar.scrollPosition;
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
			m_explicitContainingBlock = containingBlock;
		}

		/**
		 * Returns the width that is available to child elements.
		 */
		reprise function innerWidth() : int
		{
			if (m_vScrollbar && m_vScrollbar.visibility())
			{
				return m_currentStyles.width - m_vScrollbar.outerWidth;
			}
			return m_currentStyles.width;
		}
		
		/**
		 * Returns the height that is available to child elements.
		 */
		reprise function innerHeight() : int
		{
			if (m_hScrollbar && m_hScrollbar.visibility())
			{
				return m_currentStyles.height - m_hScrollbar.outerWidth;
			}
			return m_currentStyles.height;
		}
		reprise function get autoFlags() : Object
		{
			return m_autoFlags;
		}
		reprise function get positionInFlow() : int
		{
			return m_positionInFlow;
		}
		reprise function get selectorPath() : String
		{
			return m_selectorPath;
		}
		

		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		override protected function preinitialize() : void
		{
			super.preinitialize();
			m_instanceStyles = new CSSDeclaration();
		}
		
		protected override function initialize() : void
		{
			if (!m_class.basicStyles)
			{
				m_class.basicStyles = new CSSDeclaration();
				m_elementDefaultStyles = m_class.basicStyles;
				initDefaultStyles();
			}
			else
			{
				m_elementDefaultStyles = m_class.basicStyles;
			}
			m_transitionsManager = new CSSTransitionsManager(this);
			m_layoutManager = new CSSBoxModelLayoutManager();
			m_currentStyles = new ComputedStyles();
			m_weakStyles = new CSSDeclaration();
			m_stylesInvalidated = true;
			if (m_cssId)
			{
				m_rootElement.registerElementID(m_cssId, this);
			}
			super.initialize();
		}
		
		/**
		 * creates all clips needed to display the UIObjects' content
		 */
		protected override function createDisplayClips() : void
		{
			super.createDisplayClips();
			
			// create container for elements with z-index < 0
			m_lowerContentDisplay = new Sprite();
			m_contentDisplay.addChild(m_lowerContentDisplay);
			m_lowerContentDisplay.name = 'lower_content_display';
			
			// create container for elements with z-index >= 0
			m_upperContentDisplay = new Sprite();
			m_contentDisplay.addChild(m_upperContentDisplay);
			m_upperContentDisplay.name = 'upper_content_display';
		}
		
		/**
		 * Resets the elements styles.
		 * 
		 * Mostly used in debugging to enable style reloading.
		 */
		protected function resetStyles() : void
		{
			m_complexStyles = null;
			m_specifiedStyles = null;
			for each (var child : UIComponent in m_children)
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
			if (m_instanceStyles.hasStyle('freezeDisplay') && 
				m_instanceStyles.getStyle('freezeDisplay').specifiedValue() == true &&
				m_instanceStyles.getStyle('freezeDisplay').important())
			{
				//completely ignore element validation if it is frozen. The element is left marked 
				//as invalid to allow for immediate validation after un-freezing.
				return;
			}
			m_rootElement.increaseValidatedElementsCount();
			if (validateStyles)
			{
				m_stylesInvalidated = true;
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
			m_contentDisplay.transform.matrix = IDENTITY_MATRIX;
			if (m_scrollbarsDisplay)
			{
				m_scrollbarsDisplay.transform.matrix = m_contentDisplay.transform.matrix;
			}
			m_oldInFlowStatus = m_positionInFlow;
			
			m_oldContentBoxWidth = m_contentBoxWidth;
			m_oldContentBoxHeight = m_contentBoxHeight;
			var oldSpecifiedWidth : int = m_currentStyles.width;
			var oldSpecifiedHeight : int = m_currentStyles.height;
			
			if (m_stylesInvalidated)
			{
				var isCurrentlyRendered : Boolean = m_isRendered;
				calculateStyles();
				
				if (!m_isRendered)
				{
					visible = false;
					if (m_parentElement && 
						isCurrentlyRendered && !UIComponent(m_parentElement).m_isValidating)
					{
						UIComponent(m_parentElement).validateAfterChildren();
					}
					return;
				}
				if (m_isFrozen)
				{
					return;
				}
				
				visible = m_visible;
				if (m_stylesInvalidated)
				{
					if (m_currentStyles.overflowY == 'scroll')
					{
						if (!m_vScrollbar)
						{
							m_vScrollbar = createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
						}
						else
						{
							m_vScrollbar.setVisibility(true);
						}
					}
					
					if (m_currentStyles.overflowX == 'scroll')
					{
						if (!m_hScrollbar)
						{
							m_hScrollbar = createScrollbar(Scrollbar.ORIENTATION_HORIZONTAL);
						}
						else
						{
							m_hScrollbar.setVisibility(true);
						}
					}
					applyStyles();
					if (m_currentStyles.width != oldSpecifiedWidth || 
						m_currentStyles.height != oldSpecifiedHeight)
					{
						m_specifiedDimensionsChanged = true;
					}
				}
			}
		}
		/**
		 * Hook method, executed after the UIObjects' children get validated
		 */
		protected override function validateAfterChildren() : void
		{
			if (!m_isRendered || m_isFrozen)
			{
				return;
			}
			
			var oldIntrinsicWidth : int = m_intrinsicWidth;
			var oldIntrinsicHeight : int = m_intrinsicHeight;
			applyInFlowChildPositions();
			
			measure();
			
			if (m_autoFlags.width && (m_currentStyles.display == 'inline' ||
				(!m_positionInFlow && (m_autoFlags.left || m_autoFlags.right))))
			{
				if (m_transitionsManager.hasTransitionForStyle('width'))
				{
					if (m_weakStyles.hasStyle('width') && 
						m_weakStyles.getStyle('width').specifiedValue() == m_intrinsicWidth)
					{
						m_contentBoxWidth = m_currentStyles.width;
					}
					else
					{
						//TODO: deal with inline elements adapting to the intermittend sizes, 
						//changing the intrinsic width
						m_weakStyles.setStyle('width', m_intrinsicWidth + 'px', true);
						m_specifiedStyles.setStyle('width', m_oldContentBoxWidth + 'px');
						m_transitionsManager.registerAdjustedStartTimeForProperty(
							m_rootElement.frameTime(), 'width');
						m_contentBoxWidth = m_oldContentBoxWidth;
						m_invalidateStylesAfterValidation = true;
						m_stylesInvalidated = true;
						invalidate();
					}
				}
				else
				{
					m_contentBoxWidth = m_intrinsicWidth;
				}
			}
			if (m_autoFlags.height && m_intrinsicHeight != -1)
			{
				if (m_transitionsManager.hasTransitionForStyle('height'))
				{
					if (m_weakStyles.hasStyle('height') && 
						m_weakStyles.getStyle('height').specifiedValue() == m_intrinsicHeight)
					{
						m_contentBoxHeight = m_currentStyles.height;
					}
					else
					{
						m_weakStyles.setStyle('height', m_intrinsicHeight + 'px', true);
						m_specifiedStyles.setStyle('height', m_oldContentBoxHeight + 'px');
						m_transitionsManager.registerAdjustedStartTimeForProperty(
							m_rootElement.frameTime(), 'height');
						m_contentBoxHeight = m_oldContentBoxHeight;
						m_invalidateStylesAfterValidation = true;
						m_stylesInvalidated = true;
						invalidate();
					}
				}
				else
				{
					m_contentBoxHeight = m_intrinsicHeight;
				}
			}
			
			m_paddingBoxHeight = m_contentBoxHeight + 
				m_currentStyles.paddingTop + m_currentStyles.paddingBottom;
			m_borderBoxHeight = m_paddingBoxHeight + 
				m_currentStyles.borderTopWidth + m_currentStyles.borderBottomWidth;
			m_paddingBoxWidth = m_contentBoxWidth + 
				m_currentStyles.paddingLeft + m_currentStyles.paddingRight;
			m_borderBoxWidth = m_paddingBoxWidth + 
				m_currentStyles.borderLeftWidth + m_currentStyles.borderRightWidth;
			
			var outerBoxDimensions : Point = new Point(
				m_borderBoxWidth + m_currentStyles.marginLeft + m_currentStyles.marginRight, 
				m_borderBoxHeight + 
				m_currentStyles.collapsedMarginTop + m_currentStyles.collapsedMarginBottom);
			m_dimensionsChanged = 
				!(m_oldOuterBoxDimension  && m_oldOuterBoxDimension.equals(outerBoxDimensions));
			m_oldOuterBoxDimension = outerBoxDimensions;
			
			var parentReflowNeeded : Boolean = false;
			
			//apply final relative position/borderWidths to content
			m_contentDisplay.y = m_positionOffset.y + m_currentStyles.borderTopWidth;
			m_contentDisplay.x = m_positionOffset.x + m_currentStyles.borderLeftWidth;
			
			if (m_dimensionsChanged || m_stylesInvalidated)
			{
				applyBackgroundAndBorders();
				applyOverflowProperty();
				if ((m_currentStyles.float || m_positionInFlow) && m_dimensionsChanged)
				{
					parentReflowNeeded = true;
	//				log("f reason for parentReflow: dims of in-flow changed");
				}
			}
			else if (m_contentBoxHeight != m_oldContentBoxHeight || 
				m_contentBoxWidth != m_oldContentBoxWidth || 
				m_intrinsicHeight != oldIntrinsicHeight || 
				m_intrinsicWidth != oldIntrinsicWidth)
			{
				applyOverflowProperty();
			}
			
			if (!(m_parentElement is UIComponent && m_parentElement != this && 
				UIComponent(m_parentElement).m_isValidating))
			{
				if ((m_oldInFlowStatus == -1 || m_dimensionsChanged) && !m_positionInFlow)
				{
					//The element is positioned absolutely or fixed.
					//check if at least one of the vertical and one of the 
					//horizontal dimensions is specified. If not, we need to 
					//let the parent do the positioning
					if ((m_autoFlags.top && m_autoFlags.bottom) || 
						(m_autoFlags.left && m_autoFlags.right))
					{
						parentReflowNeeded = true;
	//					log("f reason for reflow: All positions in " +
	//						"absolute positioned element are auto");
					}
				}
				else if (m_oldInFlowStatus != m_positionInFlow)
				{
					parentReflowNeeded = true;
	//				log("f reason for parentReflow: flowPos changed");
				}
				if (m_parentElement && m_parentElement != this)
				{
					if (parentReflowNeeded && !UIComponent(m_parentElement).m_isValidating)
					{
//						log("w parentreflow needed in " + 
//							m_elementType + "#"+m_cssId + "."+m_cssClasses);
						UIComponent(m_parentElement).validateAfterChildren();
						return;
					}
					else if (!UIComponent(m_parentElement).m_isValidating)
					{
//						log("w no parentreflow needed in " + 
//							m_elementType + "#"+m_cssId + "."+m_cssClasses);
						UIComponent(m_parentElement).applyOutOfFlowChildPositions();
					}
				}
				else
				{
					applyOutOfFlowChildPositions();
				}
			}
			m_layoutManager.applyDepthSorting(
				m_lowerContentDisplay, m_upperContentDisplay);
			
			applyTransform();
		}
		protected override function finishValidation() : void
		{
			super.finishValidation();
			
			m_dimensionsChanged = false;
			m_specifiedDimensionsChanged = false;
			
			if (m_invalidateStylesAfterValidation)
			{
				m_invalidateStylesAfterValidation = false;
				invalidateStyles();
			}
			else
			{
				m_stylesInvalidated = false;
			}
		}

		protected override function validateChildren() : void
		{
			if (!m_isRendered || m_isFrozen)
			{
				return;
			}
			super.validateChildren();
		}
		protected override function validateChild(child:UIObject) : void
		{
			if (child is UIComponent)
			{
				UIComponent(child).validateElement(
					true, m_stylesInvalidated || m_selectorPathChanged);
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
			var oldPath : String = m_selectorPath;
			var path : String;
			if (m_parentElement)
			{
				path = (m_parentElement as UIComponent).selectorPath + " ";
			}
			else 
			{
				path = "";
			}
			path += "@" + m_elementType.toLowerCase() + "@";
			if (m_cssId)
			{
				path += "@#" + m_cssId + "@";
			}
			if (m_cssClasses)
			{
				path += "@." + m_cssClasses.split(' ').join('@.') + "@";
			}
			if (m_cssPseudoClasses.length)
			{
				path += m_cssPseudoClasses.split(" :").join("@:") + "@";
			}
			if (m_isFirstChild)
			{
				path += "@:first-child@";
			}
			if (m_isLastChild)
			{
				path += "@:last-child@";
			}
			if (path != oldPath)
			{
				m_selectorPath = path;
				m_selectorPathChanged = true;
				return;
			}
			m_selectorPathChanged = false;
		}
		
		/**
		 * parses all styles associated with this element and its classes and creates a 
		 * combined style object.
		 * CalculateStyles also invokes processing of transitions and resolution of 
		 * relative values.
		 */
		protected function calculateStyles() : void
		{
			refreshSelectorPath();
			
			var styles : CSSDeclaration = new CSSDeclaration();
			var oldStyles : CSSDeclaration = m_specifiedStyles;
			
			styles.mergeCSSDeclaration(m_instanceStyles);
			if (m_rootElement.styleSheet)
			{
				styles.mergeCSSDeclaration(m_rootElement.styleSheet.
					getStyleForEscapedSelectorPath(m_selectorPath), false, true);
			}
			if (m_parentElement != this && m_parentElement is UIComponent)
			{
				styles.mergeCSSDeclaration(
					UIComponent(m_parentElement).m_complexStyles, true, true);
			}
			
			styles.mergeCSSDeclaration(m_elementDefaultStyles, false, true);
			
			styles.mergeCSSDeclaration(m_weakStyles, false, true);
			
			m_freezeDisplay = (styles.hasStyle('freezeDisplay') && 
				styles.getStyle('freezeDisplay').specifiedValue() == true);
			if (m_isFrozen && !m_freezeDisplay)
			{
				removeDisplayFreezing();
			}
			
			//check if styles or other relevant factors have changed and stop validation 
			//if not.
			if (!(m_containingBlock && m_containingBlock.m_specifiedDimensionsChanged) && 
				styles.compare(oldStyles) && !m_transitionsManager.isActive() && 
				!(this == m_rootElement && DocumentView(this).stageDimensionsChanged))
			{
				m_stylesInvalidated = false;
				return;
			}
			
			m_specifiedStyles = styles;
			styles = m_transitionsManager.processTransitions(
				oldStyles, styles, stage.frameRate, m_rootElement.frameTime());
			m_complexStyles = styles;
			
			//this element might have been removed in a transitions event handler. Return if so.
			m_isRendered = !(styles.hasStyle('display') && 
				styles.getStyle('display').specifiedValue() == 'none') && m_rootElement;
			if (!m_isRendered)
			{
				return;
			}
			
			m_currentStyles = styles.toComputedStyles();
			
			if (m_transitionsManager.isActive())
			{
				invalidateStyles();
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
			m_positionOffset = new Point(0, 0);
			if (m_positioningType == 'relative')
			{
				m_positionOffset.x = m_currentStyles.left;
				m_positionOffset.y = m_currentStyles.top;
			}
			
			
			if (m_currentStyles.tabIndex != null)
			{
				m_tabIndex = m_currentStyles.tabIndex;
			}
			
			m_tooltipRenderer = m_currentStyles.tooltipRenderer;
			m_tooltipDelay = m_currentStyles.tooltipDelay;
			
			m_contentDisplay.blendMode = m_currentStyles.blendMode || 'normal';
			
			if (m_dropShadowFilter != null)
			{
				removeFilter(m_dropShadowFilter);
			}
			if (m_currentStyles.textShadowColor != null)
			{
				m_dropShadowFilter = Filters.dropShadowFilterFromStyleObjectForName(
					m_currentStyles, 'text');
				addFilter(m_dropShadowFilter);
			}
			
			if (m_currentStyles.visibility == 'hidden' && m_visible)
			{
				m_visible = visible = false;
			}
			else if (m_currentStyles.visibility != 'hidden' && !m_visible)
			{
				m_visible = visible = true;
			}
			
			if (m_currentStyles.cursor == 'pointer')
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
			
			super.rotation = m_currentStyles.rotation || 0;
			if (m_currentStyles.opacity == null)
			{
				super.alpha = 1;
			}
			else
			{
				super.alpha = m_currentStyles.opacity;
			}
		}
		
		protected function resolvePositioningProperties() : void
		{
			if (!m_currentStyles.float || m_currentStyles.float == 'none')
			{
				m_currentStyles.float = null;
			}
			
			var positioning : String = m_positioningType = 
				m_currentStyles.position ||  'static';
			
			if (!m_currentStyles.float && 
				(positioning == 'static' || positioning == 'relative'))
			{
				m_positionInFlow = 1;
			}
			else
			{
				m_positionInFlow = 0;
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
			if (m_explicitContainingBlock)
			{
				m_containingBlock = m_explicitContainingBlock;
			}
			else
			{
				var parentComponent : UIComponent = UIComponent(m_parentElement);
				if (m_positioningType == 'fixed')
				{
					m_containingBlock = m_rootElement;
				}
				else if (m_positioningType == 'absolute')
				{
					var inspectedBlock : UIComponent = parentComponent;
					while (inspectedBlock && 
						inspectedBlock.m_positioningType == 'static')
					{
						inspectedBlock = inspectedBlock.m_containingBlock;
					}
					m_containingBlock = inspectedBlock;
				}
				else
				{
					m_containingBlock = parentComponent;
				}
			}
		}
		
		protected function resolveRelativeStyles(styles : CSSDeclaration, 
			parentW : int = -1, parentH : int = -1) : void
		{
			var borderBoxSizing : Boolean = 
				m_currentStyles.boxSizing && m_currentStyles.boxSizing == 'border-box';
			
			if (parentW == -1)
			{
				parentW = m_containingBlock.innerWidth();
			}
			if (parentH == -1)
			{
				parentH = m_containingBlock.innerHeight();
			}
			
			resolvePropsToValue(styles, WIDTH_RELATIVE_PROPERTIES, parentW);
			
			//calculate border widths. width resolution relies on correct border widths, 
			//so we have to do this here.
			for each (var borderName : String in EDGE_NAMES)
			{
				var style : String = 
					m_currentStyles['border' + borderName + 'Style'] ||  'none';
				if (style == 'none')
				{
					m_currentStyles['border' + borderName + 'Width'] = 0;
				}
				else
				{
					m_currentStyles['border' + borderName + 'Width'] ||=  0;
				}
			}
			
			
			var wProp : CSSProperty = styles.getStyle('width');
			if (!wProp || wProp.specifiedValue() == 'auto')
			{
				m_autoFlags.width = true;
				if (!m_positionInFlow)
				{
					m_contentBoxWidth = m_currentStyles.width = parentW - 
						m_currentStyles.left - m_currentStyles.right - 
						m_currentStyles.marginLeft - m_currentStyles.marginRight - 
						m_currentStyles.paddingLeft - m_currentStyles.paddingRight - 
						m_currentStyles.borderLeftWidth - m_currentStyles.borderRightWidth;
				}
				else
				{
					m_contentBoxWidth = m_currentStyles.width = parentW - 
						m_currentStyles.marginLeft - m_currentStyles.marginRight - 
						m_currentStyles.paddingLeft - m_currentStyles.paddingRight - 
						m_currentStyles.borderLeftWidth - m_currentStyles.borderRightWidth;
				}
			}
			else if (wProp.isWeak())
			{
				m_autoFlags.width = true;
			}
			else
			{
				m_autoFlags.width = false;
				if (wProp.isRelativeValue())
				{
					var relevantWidth : int = parentW;
					if (m_positioningType == 'absolute')
					{
						relevantWidth += 
							m_containingBlock.m_currentStyles.paddingLeft + 
							m_containingBlock.m_currentStyles.paddingRight;
					}
					m_currentStyles.width = 
						wProp.resolveRelativeValueTo(relevantWidth, this);
				}
				if (borderBoxSizing)
				{
					m_currentStyles.width -= 
						m_currentStyles.borderLeftWidth + m_currentStyles.paddingLeft + 
						m_currentStyles.borderRightWidth + m_currentStyles.paddingRight;
					if (m_currentStyles.width < 0)
					{
						m_currentStyles.width = 0;
					}
				}
				m_contentBoxWidth = m_currentStyles.width || 0;
			}
			
			resolvePropsToValue(styles, HEIGHT_RELATIVE_PROPERTIES, parentH);
			m_contentBoxHeight = m_currentStyles.height;
			
			if (borderBoxSizing && !m_autoFlags.height)
			{
				m_contentBoxHeight -= 
					m_currentStyles.borderTopWidth + m_currentStyles.paddingTop + 
					m_currentStyles.borderBottomWidth + m_currentStyles.paddingBottom;
				if (m_contentBoxHeight < 0)
				{
					m_contentBoxHeight = 0;
				}
				m_currentStyles.height = m_contentBoxHeight;
			}
			//TODO: verify that we should really resolve the border-radii this way
			resolvePropsToValue(styles, OWN_WIDTH_RELATIVE_PROPERTIES, 
				m_contentBoxWidth + m_currentStyles.borderTopWidth);
			
			//reset collapsed margins to be identical with initial margins
			m_currentStyles.collapsedMarginTop = m_currentStyles.marginTop;
			m_currentStyles.collapsedMarginBottom =  m_currentStyles.marginBottom;
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
						m_currentStyles[propName] = Math.round(
							cssProperty.resolveRelativeValueTo(baseValue, this));
					}
					m_autoFlags[propName] = cssProperty.isAuto() || cssProperty.isWeak();
				}
				else 
				{
					m_autoFlags[propName] = props[i][1];
					m_currentStyles[propName] = 0;
				}
			}
		}
		
		/**
		 * calculates the vertical space taken by this elements' content
		 */
		protected function calculateContentHeight() : int
		{
			return m_contentBoxHeight;
		}
		
		/**
		 * calculates the horizontal space taken by this elements' content
		 */
		protected function calculateContentWidth() : int
		{
			return m_contentBoxWidth;
		}

		protected function applyInFlowChildPositions() : void
		{
			m_layoutManager.applyFlowPositions(this, m_children);
			m_intrinsicWidth = m_currentStyles.intrinsicWidth;
			m_intrinsicHeight = m_currentStyles.intrinsicHeight;
		}
		
		protected function applyOutOfFlowChildPositions() : void
		{
			if (!m_isRendered || m_isFrozen)
			{
				return;
			}
			m_layoutManager.applyAbsolutePositions(this, m_children);
			for each (var child : UIObject in m_children)
			{
				//only deal with rendered children that derive from UIComponent
				if (!(child is UIComponent) || !UIComponent(child).isRendered())
				{
					continue;
				}
				UIComponent(child).applyOutOfFlowChildPositions();
			}
			super.calculateKeyLoop();
			
			if (m_freezeDisplay)
			{
				applyDisplayFreezing();
			}
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
		protected function parseXMLDefinition(xmlDefinition : XML, url : String) : void
		{
			m_xmlDefinition = xmlDefinition;
			m_xmlURL = url;
			parseXMLAttributes(xmlDefinition);
			parseXMLContent(xmlDefinition);
			
			invalidateStyles();
		}
		
		protected function invalidateStyles() : void
		{
			if (m_isValidating)
			{
				m_invalidateStylesAfterValidation = true;
			}
			else
			{
				m_stylesInvalidated = true;
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
				//m_domPath = m_parentElement.domPath;
				m_elementType = "p";
			}
			else 
			{
				var attributes : Object = {};
				for each (var attribute : XML in node.@*)
				{
					if (attribute.nodeKind() != 'text')
					{
						var attributeName : String = attribute.localName();
						var attributeValue : String = attribute.toString();
						attributes[attributeName] = attributeValue;
						assignValueFromAttribute(attributeName, attributeValue);
					}
				}
				m_nodeAttributes = attributes;
				m_elementType = node.localName();
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
		protected function parseXMLContent(node : XML) : void
		{
			XML.prettyPrinting = false;
			var childNode : XML = node.children()[0];
			while (childNode)
			{
				childNode = preprocessTextNode(childNode);
				var child : UIComponent = 
					m_rootElement.uiRendererFactory().rendererByNode(childNode);
				if (child)
				{
					addChild(child);
					child.parseXMLDefinition(childNode, m_xmlURL);
				}
				else
				{
					log("f No handler found for node: " + childNode.toXMLString());
				}
				childNode = childNode.parent().children()[childNode.childIndex() + 1];
			}
		}
		
		protected function preprocessTextNode(node : XML) : XML
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
			return xmlParser;
		}
		
		
		/**
		 * draws the background rect and borders according to the styles 
		 * specified for this element.
		 */
		protected function applyBackgroundAndBorders() : void
		{
			if (m_currentStyles.backgroundColor || m_currentStyles.backgroundImage || 
				(m_currentStyles.backgroundGradientColors && 
				m_currentStyles.backgroundGradientType))
			{
				var backgroundRendererId : String = 
					m_currentStyles.backgroundRenderer || "";
				if (!m_backgroundRenderer || 
					m_backgroundRenderer.id() != backgroundRendererId)
				{
					if (m_backgroundDisplay)
					{
						m_backgroundRenderer.destroy();
						removeChild(m_backgroundDisplay);
					}
					m_backgroundDisplay = new Sprite();
					m_backgroundDisplay.name = "background_" + backgroundRendererId;
					m_contentDisplay.addChildAt(m_backgroundDisplay, 0);
					m_backgroundRenderer = m_rootElement.uiRendererFactory().
						backgroundRendererById(backgroundRendererId);
					m_backgroundRenderer.setDisplay(m_backgroundDisplay);
				}
				m_backgroundDisplay.visible = true;
				
				m_backgroundDisplay.x = 0 - m_currentStyles.borderLeftWidth;
				m_backgroundDisplay.y = 0 - m_currentStyles.borderTopWidth;
				m_backgroundRenderer.setSize(m_borderBoxWidth, m_borderBoxHeight);
				m_backgroundRenderer.setStyles(m_currentStyles);
				m_backgroundRenderer.setComplexStyles(m_complexStyles);
				m_backgroundRenderer.draw();
				//TODO: move into renderer
				m_backgroundDisplay.blendMode = 
					m_currentStyles.backgroundBlendMode || 'normal';
			}
			else
			{
				if (m_backgroundDisplay)
				{
					m_backgroundDisplay.visible = false;
				}
			}
			
			if (m_currentStyles.borderTopStyle || m_currentStyles.borderRightStyle || 
				m_currentStyles.borderBottomStyle || m_currentStyles.borderLeftStyle)
			{
				var borderRendererId : String = m_currentStyles.borderRenderer || "";
				if (!m_borderRenderer || m_borderRenderer.id() != borderRendererId)
				{
					if (m_bordersDisplay)
					{
						m_borderRenderer.destroy();
						removeChild(m_bordersDisplay);
					}
					m_bordersDisplay = new Sprite();
					m_bordersDisplay.name = "border_" + borderRendererId;
					m_contentDisplay.addChildAt(m_bordersDisplay, 
						m_contentDisplay.getChildIndex(m_upperContentDisplay));
					m_borderRenderer = m_rootElement.uiRendererFactory().
						borderRendererById(borderRendererId);
					m_borderRenderer.setDisplay(m_bordersDisplay);
				}
				m_bordersDisplay.visible = true;
				
				m_bordersDisplay.x = 0 - m_currentStyles.borderLeftWidth;
				m_bordersDisplay.y = 0 - m_currentStyles.borderTopWidth;
				
				m_borderRenderer.setSize(m_borderBoxWidth, m_borderBoxHeight);
				m_borderRenderer.setStyles(m_currentStyles);
				m_borderRenderer.setComplexStyles(m_complexStyles);
				m_borderRenderer.draw();
			}
			else
			{
				if (m_bordersDisplay)
				{
					m_bordersDisplay.visible = false;
				}
			}
		}
		protected function applyOverflowProperty() : void
		{
			var maskNeeded : Boolean = false;
			var scrollersNeeded : Boolean = false;
			
			var ofx : * = m_currentStyles.overflowX;
			var ofy : * = m_currentStyles.overflowY;
			
			if (ofx == 'visible' || ofx == null || ofx == 'hidden')
			{
				if (m_hScrollbar) m_hScrollbar.setVisibility(false);
				if (ofx == 'hidden') maskNeeded = true;
			}
			else
			{
				maskNeeded = scrollersNeeded = true;
			}
			
			if (ofy == 'visible' || ofy == null || ofy == 'hidden')
			{
				if (m_vScrollbar) m_vScrollbar.setVisibility(false);
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
				m_upperContentDisplay.mask = null;
				m_lowerContentDisplay.mask = null;
			}
		}

		protected function applyMask() : void
		{
			var maskW : int = 
				(m_currentStyles.overflowX == 'visible' || m_currentStyles.overflowX == null) 
					? m_borderBoxWidth 
					: innerWidth() + m_currentStyles.paddingLeft + m_currentStyles.paddingRight;
			var maskH : int = 
				(m_currentStyles.overflowY == 'visible' || m_currentStyles.overflowY == null) 
					? m_borderBoxHeight 
					: innerHeight() + m_currentStyles.paddingTop + m_currentStyles.paddingBottom;
			
			if (!m_lowerContentMask)
			{
				m_upperContentMask = new Sprite();
				m_lowerContentMask = new Sprite();
				m_upperContentMask.name = 'upperMask';
				m_lowerContentMask.name = 'lowerMask';
				addChild(m_upperContentMask);
				addChild(m_lowerContentMask);
				m_upperContentMask.visible = false;
				m_lowerContentMask.visible = false;
			}
			
			m_upperContentMask.x = m_lowerContentMask.x = m_currentStyles.borderLeftWidth;
			m_upperContentMask.y = m_lowerContentMask.y = m_currentStyles.borderTopWidth;
			var radii : Array = [];
			var order : Array = 
				['borderTopLeftRadius', 'borderTopRightRadius', 
				'borderBottomRightRadius', 'borderBottomLeftRadius'];
			
			var i : int;
			for (i = 0;i < order.length; i++)
			{
				radii.push(m_currentStyles[order[i]] || 0);
			}
			m_upperContentMask.graphics.clear();
			m_lowerContentMask.graphics.clear();
			m_upperContentMask.graphics.beginFill(0x00ff00, 50);
			m_lowerContentMask.graphics.beginFill(0x00ff00, 50);
			GfxUtil.drawRoundRect(m_upperContentMask, 0, 0, maskW, maskH, radii);
			GfxUtil.drawRoundRect(m_lowerContentMask, 0, 0, maskW, maskH, radii);
			m_upperContentDisplay.mask = m_upperContentMask;
			m_lowerContentDisplay.mask = m_lowerContentMask;
		}
		
		protected function applyScrollbars() : void
		{
			function childWidth() : int
			{
				var widestChildWidth : int = 0;
				var childCount : int = m_children.length;
				while (childCount--)
				{
					var child : UIComponent = m_children[childCount] as UIComponent;
					var childX : int = 
						child.m_currentStyles.position == 'absolute' ? child.x : 0;
					widestChildWidth = Math.max(
						childX + child.m_borderBoxWidth + child.m_currentStyles.marginRight - 
						m_currentStyles.paddingLeft, widestChildWidth);
				}
				return widestChildWidth;
			}
			
			var vScrollerNeeded : Boolean;
			var hScrollerNeeded : Boolean;
			
			if (m_currentStyles.overflowY == 0 && m_intrinsicHeight > m_currentStyles.height)
			{
				if (!m_vScrollbar)
				{
					m_vScrollbar = createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
					addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel_turn);
				}
				m_vScrollbar.setVisibility(true);
				if (m_currentStyles.overflowX == 'scroll' || m_currentStyles.overflowX == 0)
				{
					validateChildren();
					applyInFlowChildPositions();
					m_intrinsicWidth = childWidth();
				}
				vScrollerNeeded = true;
			}
			
			if (m_currentStyles.overflowY == 'scroll')
			{
				vScrollerNeeded = true;
			}
			
			if (m_currentStyles.overflowX == 0 && m_intrinsicWidth > m_currentStyles.width)
			{
				if (!m_hScrollbar)
				{
					m_hScrollbar = createScrollbar(Scrollbar.ORIENTATION_HORIZONTAL);
				}
				m_hScrollbar.setVisibility(true);
				if (vScrollerNeeded)
				{
					var oldIntrinsicWidth : int = m_intrinsicWidth;
					validateChildren();
					applyInFlowChildPositions();
					applyOutOfFlowChildPositions();
					m_intrinsicWidth = oldIntrinsicWidth;
				}
				hScrollerNeeded = true;
			}

			if (m_currentStyles.overflowX == 'scroll')
			{
				hScrollerNeeded = true;
			}

			if (vScrollerNeeded)
			{
				m_vScrollbar.setScrollProperties(innerHeight(), 0, 
					m_intrinsicHeight - innerHeight());
				m_vScrollbar.top = 0;
				m_vScrollbar.height = 
					innerHeight() + m_currentStyles.paddingTop + m_currentStyles.paddingBottom;
				m_vScrollbar.left = m_currentStyles.width - m_vScrollbar.outerWidth + 
					m_currentStyles.paddingLeft + m_currentStyles.paddingRight;
				m_vScrollbar.validateElement(true, true);
				verticalScrollbar_change();
			}
			else
			{
				if (m_vScrollbar)
				{
					m_vScrollbar.setVisibility(false);
				}
			}
			
			if (hScrollerNeeded)
			{
				m_hScrollbar.setScrollProperties(
					innerWidth(), 0, m_intrinsicWidth - innerWidth());
				m_hScrollbar.top = m_currentStyles.height + 
					m_currentStyles.paddingTop + m_currentStyles.paddingRight;
				m_hScrollbar.height = 
					innerWidth() + m_currentStyles.paddingLeft + m_currentStyles.paddingRight;
				m_hScrollbar.validateElement(true, true);
				horizontalScrollbar_change();
			}
			else
			{
				if (m_hScrollbar)
				{
					m_hScrollbar.setVisibility(false);
				}
			}
		}

		protected function applyDisplayFreezing() : void
		{
			var bounds : Rectangle;
			if (!m_currentStyles.overflow || m_currentStyles.overflow == 'visible')
			{
				bounds = this.getBounds(this);
			}
			if (!bounds || bounds.width < 0 || bounds.width > 2880 || 
				bounds.height < 0 || bounds.height > 2880)
			{
				bounds = new Rectangle(m_positionOffset.x, m_positionOffset.y, 
					m_borderBoxWidth, m_borderBoxHeight);
				if (!m_currentStyles.overflow || m_currentStyles.overflow == 'visible')
				{
					log('f invalid DisplayObject bounds for element ' + this + 
						', selectorPath: ' + m_selectorPath.split('@').join(''));
					log('please send a reproducible test case to till@fork.de, if at all possible');
				}
			}
			m_frozenContent = new BitmapData(bounds.width, bounds.height, true, 0x0);
			
			m_contentDisplay.x -= bounds.left;
			m_contentDisplay.y -= bounds.top;
			m_frozenContent.draw(this, null, null, null, 
				new Rectangle(0, 0, bounds.width, bounds.height), true);
			m_contentDisplay.visible = false;
			m_frozenContentDisplay = new Bitmap(m_frozenContent, 'auto', true);
			m_frozenContentDisplay.x = bounds.left;
			m_frozenContentDisplay.y = bounds.top;
			m_contentDisplay.x += bounds.left;
			m_contentDisplay.y += bounds.top;
			addChild(m_frozenContentDisplay);
			m_isFrozen = true;
		}
		
		protected function removeDisplayFreezing() : void
		{
			if (m_isInvalidated)
			{
				//force revalidation of this component. It might have been ignored during the last 
				//validation cycle due to freezing.
				m_isInvalidated = false;
				invalidate();
				return;
			}
			m_frozenContent.dispose();
			m_frozenContent = null;
			removeChild(m_frozenContentDisplay);
			m_frozenContentDisplay = null;
			m_contentDisplay.visible = true;
			m_isFrozen = false;
		}
		
		protected function createScrollbar(
			orientation : String, skipListenerRegistration : Boolean = false) : Scrollbar
		{
			if (!m_scrollbarsDisplay)
			{
				m_scrollbarsDisplay = new Sprite();
				m_scrollbarsDisplay.name = 'scrollbars_display';
				addChild(m_scrollbarsDisplay);
			}
			var scrollbar : Scrollbar = new Scrollbar();
			scrollbar.setParent(this);
			scrollbar.overrideContainingBlock(this);
			m_scrollbarsDisplay.addChild(scrollbar);
			scrollbar.cssClasses = orientation + "Scrollbar";
			scrollbar.setStyle('position', 'absolute');
			scrollbar.setStyle('autoHide', 'false');
			//TODO: remove scrollbarWidth property
			scrollbar.setStyle(
				'width', (m_currentStyles.scrollbarWidth || DEFAULT_SCROLLBAR_WIDTH) + 'px');
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
			scrollbar.validateElement(true, true);
			return scrollbar;
		}
		
		protected function scrollbar_click(event : Event) : void
		{
			event.stopImmediatePropagation();
			event.stopPropagation();
		}
		
		protected function verticalScrollbar_change(event : Event = null) : void
		{
			m_upperContentDisplay.y = m_lowerContentDisplay.y = -m_vScrollbar.scrollPosition;
		}
		
		protected function horizontalScrollbar_change(event : Event = null) : void
		{
			m_upperContentDisplay.x = m_lowerContentDisplay.x = -m_hScrollbar.scrollPosition;
		}
		
		protected function mouseWheel_turn(event : MouseEvent) : void
		{
			if (event.shiftKey && m_hScrollbar)
			{
				m_hScrollbar.scrollPosition -= m_hScrollbar.lineScrollSize * event.delta;
				m_upperContentDisplay.x = m_lowerContentDisplay.x = -m_hScrollbar.scrollPosition;
			}
			else if ((!event.shiftKey && m_vScrollbar) || 
				(event.shiftKey && (!m_hScrollbar || !m_hScrollbar.visibility())))
			{
				m_vScrollbar.scrollPosition -= m_vScrollbar.lineScrollSize * event.delta;
				m_upperContentDisplay.y = m_lowerContentDisplay.y = -m_vScrollbar.scrollPosition;
			}
		}
		
		protected function i18n(key : String, defaultReturnValue : * = null) : *
		{
			return m_rootElement.applicationContext().i18n(key, defaultReturnValue);
		}

		protected function track(trackingId : String) : void
		{
			m_rootElement.applicationContext().track(trackingId);
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
			if (m_currentStyles.transform)
			{
				var originX : Number = m_borderBoxWidth / 2;
				var originY : Number = m_borderBoxHeight / 2;
				if (m_complexStyles.hasStyle('transformOriginX'))
				{
					originX = m_complexStyles.getStyle('transformOriginX').
						resolveRelativeValueTo(m_borderBoxWidth);
				}
				else
				{
					originX = m_borderBoxWidth / 2;
				}
				if (m_complexStyles.hasStyle('transformOriginY'))
				{
					originY = m_complexStyles.getStyle('transformOriginY').
						resolveRelativeValueTo(m_borderBoxHeight);
				}
				else
				{
					originY = m_borderBoxHeight / 2;
				}
				
				var transformations : Array = m_currentStyles.transform;
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
								resolveRelativeValueTo(m_borderBoxWidth),
								CSSProperty(parameters[1]).
								resolveRelativeValueTo(m_borderBoxHeight));
							break;
						}
						case 'translateX' : 
						{
							matrix.translate(
								CSSProperty(parameters[0]).
								resolveRelativeValueTo(m_borderBoxWidth), 0);
							break;
						}
						case 'translateY' : 
						{
							matrix.translate(0,
								CSSProperty(parameters[1]).
								resolveRelativeValueTo(m_borderBoxHeight));
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
				if (m_positioningType == 'relative')
				{
					matrix.translate(m_currentStyles.left, m_currentStyles.top);
				}
				m_contentDisplay.transform.matrix = matrix;
				if (m_scrollbarsDisplay)
				{
					m_scrollbarsDisplay.transform.matrix = matrix;
				}
			}
		}
	}
}