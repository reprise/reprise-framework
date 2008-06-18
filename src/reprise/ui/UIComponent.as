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
	import com.robertpenner.easing.Linear;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import reprise.controls.Scrollbar;
	import reprise.core.UIRendererFactory;
	import reprise.css.CSSDeclaration;
	import reprise.css.CSSProperty;
	import reprise.css.CSSPropertyCache;
	import reprise.css.math.ICSSCalculationContext;
	import reprise.css.propertyparsers.Filters;
	import reprise.css.transitions.CSSPropertyTransition;
	import reprise.ui.renderers.ICSSRenderer;
	import reprise.utils.GfxUtil;
	import reprise.utils.StringUtil;
	
	public class UIComponent extends UIObject implements ICSSCalculationContext
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var className : String = "UIComponent";
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var DEFAULT_SCROLLBAR_WIDTH : int = 16;
		
		
		protected var m_containingBlock : UIComponent;
		protected var m_explicitContainingBlock : UIComponent;
		
		protected var m_xmlDefinition : XML;
		protected var m_cssClasses : String = "";
		protected var m_cssPseudoClasses : String = "";
		protected var m_pseudoClassesBackup : String;
		protected var m_cssId : String = "";
		protected var m_selectorPath : String;
		protected var m_currentStyles : Object;
		protected var m_complexStyles : CSSDeclaration;
		protected var m_specifiedStyles : CSSDeclaration;
		protected var m_elementDefaultStyles : CSSDeclaration;
		protected var m_instanceStyles : CSSDeclaration;
		protected var m_activeTransitions : Object;
	
		protected var m_left : Number = 0;
		protected var m_top : Number = 0;
		protected var m_right : Number = 0;
		protected var m_bottom : Number = 0;
		
		protected var m_width : Number = 0;
		protected var m_height : Number = 0;
		
		protected var m_positionOffset : Point;
		
		protected var m_leftIsAuto : Boolean;
		protected var m_rightIsAuto : Boolean;
		protected var m_topIsAuto : Boolean;
		protected var m_bottomIsAuto : Boolean;
		
		protected var m_paddingTop : Number = 0;
		protected var m_paddingLeft : Number = 0;
		protected var m_paddingBottom : Number = 0;
		protected var m_paddingRight : Number = 0;
		protected var m_marginTop : Number = 0;
		protected var m_marginLeft : Number = 0;
		protected var m_marginBottom : Number = 0;
		protected var m_marginRight : Number = 0;
		protected var m_borderTopWidth : Number = 0;
		protected var m_borderLeftWidth : Number = 0;
		protected var m_borderBottomWidth : Number = 0;
		protected var m_borderRightWidth : Number = 0;
		protected var m_borderBottomRightRadius : Number = 0;
		protected var m_borderBottomLeftRadius : Number = 0;
		protected var m_borderTopRightRadius : Number = 0;
		protected var m_borderTopLeftRadius : Number = 0;
		
		protected var m_stylesInvalidated : Boolean;
		protected var m_skipNextValidation : Boolean;
		
		protected var m_borderBoxHeight : Number = 0;
		protected var m_borderBoxWidth : Number = 0;
		protected var m_paddingBoxHeight : Number = 0;
		protected var m_paddingBoxWidth : Number = 0;
		
		protected var m_borderRenderer : ICSSRenderer;
		protected var m_backgroundRenderer : ICSSRenderer;
		
		protected var m_backgroundDisplay : Sprite;
		protected var m_bordersDisplay : Sprite;
		protected var m_contentMask : Sprite;
		protected var m_scrollbarsDisplay : Sprite;
		
		protected var m_vScrollbar : Scrollbar;
		protected var m_hScrollbar : Scrollbar;
		
		protected var m_dropShadowFilter : DropShadowFilter;
		
		protected var m_nodeAttributes : Object;
		
		protected var m_positionInFlow : int = 1;
		protected var m_oldInFlowStatus : int = -1;
		protected var m_oldOuterBoxDimension : Point;
		
		protected var m_intrinsicWidth : Number = -1;
		protected var m_intrinsicHeight : Number = -1;
		
		protected var m_verticalFlowPosition : Number = 0;
		
		protected var m_selectorPathChanged : Boolean;
		
		protected var m_positioningType : String;
		protected var m_float : String;
		protected var m_displayStack : Array;
		
		protected var m_dimensionsChanged : Boolean;
		protected var m_specifiedDimensionsChanged : Boolean;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function UIComponent()
		{
		}
		
		/**
		 * Convenience method that eases the process to add a child element.
		 * 
		 * @param classes The css classes the component should have.
		 * @param id The css id the component should have.
		 * @param componentClass The ActionScript class to instantiate. If this is 
		 * omitted, an instance of UIComponent will be created.
		 * @param index The index at which the element should be added. If this is 
		 * omitted, the element will be created at the next available index.
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
				component.cssId = id;
			}
			if (classes)
			{
				component.cssClasses = classes;
			}
			return component;
		}
		
		/**
		 * initializes the UIComponent structure from the given xml structure, 
		 * creating child views as needed
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
		 * initializes the UIComponent structure from the given xml structure, 
		 * creating child views as needed
		 */
		public function overrideContainingBlock(
			containingBlock : UIComponent) : void
		{
			m_explicitContainingBlock = containingBlock;
		}
		
		public override function set width(value : Number) : void
		{
			setStyle('width', value + "px");
		}
		public override function get width() : Number
		{
			return m_width;
		}
		
		public function set outerWidth(value : Number) : void
		{
			setStyle('outerWidth', value + 'px');
		}
		public function get outerWidth() : Number
		{
			return m_currentStyles.outerWidth;
		}
		
		public function get intrinsicWidth() : Number
		{
			return m_intrinsicWidth;
		}
		
		public override function set height(value:Number) : void
		{
			setStyle('height', value + "px");
		}
		public override function get height() : Number
		{
			return m_height;
		}
		
		public function get outerHeight() : Number
		{
			return m_currentStyles.outerHeight;
		}
		public function set outerHeight(value : Number) : void
		{
			setStyle('outerHeight', value + 'px');
		}
		
		public function get intrinsicHeight() : Number
		{
			return m_intrinsicHeight;
		}
		
		public override function get top() : Number
		{
			if (m_currentStyles.top == null && m_currentStyles.bottom != null)
			{
				return m_containingBlock.calculateContentHeight() - 
					m_currentStyles.bottom - m_borderBoxHeight;
			}
			return m_currentStyles.top || 0;
		}
		public override function set top(value:Number) : void
		{
			if (isNaN(value))
			{
				value = 0;
			}
			m_currentStyles.top = value;
			m_instanceStyles.setStyle('top', value + "px");
			m_topIsAuto = false;
			if (!m_positionInFlow)
			{
				m_top = value;
				var absolutePosition:Point = 
					getPositionRelativeToContext(m_containingBlock);
				absolutePosition.y -= y;
				y = value + m_marginTop - absolutePosition.y;
			}
		}
		public override function get left() : Number
		{
			if (m_currentStyles.left == null && m_currentStyles.right != null)
			{
				return m_containingBlock.calculateContentWidth() - 
					m_currentStyles.right - m_borderBoxWidth;
			}
			return m_currentStyles.left || 0;
		}
		public override function set left(value:Number) : void
		{
			if (isNaN(value))
			{
				value = 0;
			}
			m_currentStyles.left = value;
			m_instanceStyles.setStyle('left', value + "px");
			m_leftIsAuto = false;
			if (!m_positionInFlow)
			{
				m_left = value;
				var absolutePosition:Point = 
					getPositionRelativeToContext(m_containingBlock);
				absolutePosition.x -= x;
				x = value + m_marginLeft - absolutePosition.x;
			}
		}
		
		public override function get right() : Number
		{
			if (m_currentStyles.left == null && m_currentStyles.right != null)
			{
				return m_currentStyles.right;
			}
			return left + m_borderBoxWidth;
		}
		public function set right(value:Number) : void
		{
			if (isNaN(value))
			{
				value = 0;
			}
			m_currentStyles.right = value;
			m_instanceStyles.setStyle('right', value + "px");
			m_rightIsAuto = false;
			if (!m_positionInFlow)
			{
				m_right = value;
				var absolutePosition : Point = 
					getPositionRelativeToContext(m_containingBlock);
				absolutePosition.x -= x;
				x = m_containingBlock.calculateContentWidth() - m_borderBoxWidth - 
					m_right - m_marginRight - absolutePosition.x;
			}
		}
		
		public override function get bottom() : Number
		{
			if (m_currentStyles.top == null && m_currentStyles.bottom != null)
			{
				return m_currentStyles.bottom;
			}
			return top + m_borderBoxHeight;
		}
		public function set bottom(value:Number) : void
		{
			if (isNaN(value))
			{
				value = 0;
			}
			m_currentStyles.bottom = value;
			m_instanceStyles.setStyle('bottom', value + "px");
			m_bottomIsAuto = false;
			if (!m_positionInFlow)
			{
				m_bottom = value;
				var absolutePosition : Point = 
					getPositionRelativeToContext(m_containingBlock);
				absolutePosition.y -= y;
				y = m_containingBlock.calculateContentHeight() - m_borderBoxHeight - 
					m_bottom - m_marginBottom - absolutePosition.y;
			}
		}
		
		public function get marginTop() : Number
		{
			return m_marginTop;
		}
		public function get marginRight() : Number
		{
			return m_marginRight;
		}
		public function get marginBottom() : Number
		{
			return m_marginBottom;
		}
		public function get marginLeft() : Number
		{
			return m_marginLeft;
		}
		
		public function get attributes() : Object
		{
			return m_nodeAttributes;
		}
		
		/**
		 * returns a Rectangle object that contains the current position and 
		 * dimensions of the UIComponent relative to its parentElement
		 */
		public function actualBox() : Rectangle
		{
			return new Rectangle(
				x, y, m_borderBoxWidth, m_borderBoxHeight);
		}
		
	//	/**
	//	 * Returns the width that is available to child elements.
	//	 */
	//	public function innerWidth() : Number
	//	{
	//		return m_width;
	//		if (/*m_currentStyles.overflow == 'scrollV' || 
	//			m_currentStyles.overflow == 'scrollV-vertical' || */
	//			m_vScrollbar.getVisibility())
	//		{
	//			return m_width - m_vScrollbar.width;
	//		}
	//	}
	//	
	//	/**
	//	 * Returns the height that is available to child elements.
	//	 */
	//	public function innerHeight() : Number
	//	{
	//		return m_height;
	//		if (/*m_currentStyles.overflow == 'scrollV' || 
	//			m_currentStyles.overflow == 'scrollV-horizontal' || */
	//			m_hScrollbar.getVisibility())
	//		{
	//			return m_height - m_hScrollbar.width;
	//		}
	//	}
		
		public function get style() : Object
		{
			return m_currentStyles;
		}
		
		/**
		 * sets the CSS id and invalidates styling
		 */
		public function set cssId(id:String) : void
		{
			if (m_cssId)
			{
				m_rootElement.removeElementID(m_cssId);
			}
			m_rootElement.registerElementID(id, this);
			m_cssId = id;
			m_stylesInvalidated = true;
			invalidate();
		}
		/**
		 * returns the CSS id of this element
		 */
		public function get cssId() : String
		{
			return m_cssId;
		}
		/**
		 * sets the CSS classes and invalidates styling
		 */
		public function set cssClasses(classes:String) : void
		{
			m_cssClasses = classes;
			m_stylesInvalidated = true;
			invalidate();
		}
		/**
		 * returns the CSS classes of this element
		 */
		public function get cssClasses() : String
		{
			return m_cssClasses;
		}
		/**
		 * sets the CSS pseudo classes and invalidates styling
		 */
		public function set cssPseudoClasses(classes:String) : void
		{
			m_cssPseudoClasses = classes;
			m_stylesInvalidated = true;
			invalidate();
		}
		/**
		 * returns the CSS pseudo classes of this element
		 */
		public function get cssPseudoClasses() : String
		{
			return m_cssPseudoClasses;
		}
		
		public function hasClass(className : String) : Boolean
		{
			return StringUtil.delimitedStringContainsSubstring(
				m_cssClasses, className, ' ');
		}
		
		public function setStyle(name : String, value : String = null) : void
		{
			m_instanceStyles.setStyle(name, value);
			invalidate();
			m_stylesInvalidated = true;
		}
		
		public override function tooltipDelay() : Number
		{
			return m_currentStyles.tooltipDelay | 0;
		}
		public override function setTooltipDelay(delay : Number) : void
		{
			// we don't need no invalidation
			m_instanceStyles.setStyle('tooltipDelay', delay.toString());
			m_currentStyles.tooltipDelay = delay;
		}
		public override function tooltipRenderer() : String
		{
			return m_tooltipRenderer;
		}
		public override function setTooltipRenderer(renderer : String) : void
		{
			// we don't need no invalidation
			m_instanceStyles.setStyle('tooltipRenderer', renderer);
			m_currentStyles.tooltipRenderer = renderer;
		}
		
		/**
		 * replaces all CSS pseudo classes with the :error class, but saves the 
		 * other classes for a switch back later on.
		 */
		public function setErrorMark() : void
		{
			if (m_pseudoClassesBackup == null)
			{
				m_pseudoClassesBackup = m_cssPseudoClasses;
				cssPseudoClasses = " :error";
			}
		}
		/**
		 * removes the CSS error marking and reactivates the old pseudo classes.
		 */
		public function removeErrorMark() : void
		{
			if (m_pseudoClassesBackup != null)
			{
				cssPseudoClasses = m_pseudoClassesBackup;
				m_pseudoClassesBackup = null;
			}
		}
		/**
		 * adds a pseudo class if it's not already in the list of pseudo classes.
		 */
		public function addPseudoClass(name:String) : void
		{
			if (m_pseudoClassesBackup)
			{
				if (StringUtil.delimitedStringContainsSubstring(
					m_pseudoClassesBackup, ':' + name, ' '))
				{
					return;
				}
				m_pseudoClassesBackup += " :" + name;
				if (m_pseudoClassesBackup.charAt(0) == ' ')
				{
					m_pseudoClassesBackup = m_pseudoClassesBackup.substr(1);
				}
			}
			else
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
			}
			m_stylesInvalidated = true;
			invalidate();
		}
		/**
		 * removes a pseudo class from the list.
		 */
		public function removePseudoClass(name:String) : void
		{
			if (m_pseudoClassesBackup)
			{
				m_pseudoClassesBackup = 
					StringUtil.removeSubstringFromDelimitedString(
					m_pseudoClassesBackup, ':' + name, ' ');
			}
			else
			{
				m_cssPseudoClasses = StringUtil.removeSubstringFromDelimitedString(
					m_cssPseudoClasses, ':' + name, ' ');
			}
			m_stylesInvalidated = true;
			invalidate();
		}
		
		/**
		 * adds a CSS class if it's not already in the list of CSS classes.
		 */
		public function addCSSClass(name : String) : void
		{
			if (StringUtil.delimitedStringContainsSubstring(
				m_cssClasses, name, ' '))
			{
				return;
			}
			m_cssClasses += ' ' + name;
			if (m_cssClasses.charAt(0) == ' ')
			{
				m_cssClasses = m_cssClasses.substr(1);
			}
			m_stylesInvalidated = true;
			invalidate();
		}
		/**
		 * removes a CSS class from the list.
		 */
		public function removeCSSClass(name : String) : void
		{
			m_cssClasses = StringUtil.
				removeSubstringFromDelimitedString(m_cssClasses, name, ' ');
			m_stylesInvalidated = true;
			invalidate();
		}
		
		/**
		 * sets the views visibility without executing any transitions that might 
		 * be defined in the views' <code>hide</code> and <code>show</code> methods
		 */
		public override function setVisibility(visible : Boolean) : void
		{
			var visibilityProperty:String = (visible ? 'visible' : 'hidden');
			m_instanceStyles.setStyle('visibility', visibilityProperty);
			m_currentStyles.visibility = visibilityProperty;
			super.setVisibility(visible);
		}
		
		/**
		* setter for the alpha property
		*/
		public override function set alpha(value:Number) : void
		{
			opacity = value;
		}
		/**
		* getter for the alpha property
		*/
		public override function get alpha() : Number
		{
			return opacity;
		}
		/**
		* setter for the opacity property
		*/
		public function set opacity(value:Number) : void
		{
			super.alpha = value;
			m_currentStyles.opacity = value;
			m_instanceStyles.setStyle('opacity', value.toString());
		}
		/**
		* getter for the opacity property
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
		* setter for the rotation property
		*/
		public override function set rotation(value : Number) : void
		{
			super.rotation = value;
			m_currentStyles.rotation = value;
			m_instanceStyles.setStyle('rotation', value.toString());
		}
		/**
		* getter for the rotation property
		*/
		public override function get rotation() : Number
		{
			return m_currentStyles.rotation || 0;
		}
		
		/**
		 * removes the UIComponent from its' parents' display list
		 */
		public override function remove(...args) : void
		{
			if (m_cssId)
			{
				m_rootElement.removeElementID(m_cssId);
			}
			super.remove();
		}
		
		
		public function getElementsByClassName(className:String) : Array
		{
			var elements:Array = [];
			
			var len : int = m_children.length;
			for (var i : int = 0; i < len; i++)
			{
				var child : DisplayObject = m_children[i];
				if (!child is UIComponent)
				{
					continue;
				}
				var childView : UIComponent = child as UIComponent;
				var cssClasses : String = childView.cssClasses;
	
				if (cssClasses.indexOf(className) != -1 &&
					(cssClasses == className || 
					cssClasses.indexOf(' ' + className + ' ') != -1 || 
					cssClasses.indexOf(className + ' ') == 0 || 
					cssClasses.indexOf(' ' + className) == 
					(cssClasses.length - className.length - 1)))
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
				id = (id.split('.')[0] as String).split('[')[0] as String;
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
						element = candidates.shift();
						children = element.getElementsByTagName(tag);
						if (children.length)
						{
							candidates.concat(children);
						}
					}
				}
				else
				{
					className = classes.shift();
					while (oldCandidates.length)
					{
						element = candidates.shift();
						children = element.getElementsByClassName(className);
						if (children.length)
						{
							candidates.concat(children);
						}
					}
				}
				
			}
			
			matches = candidates;
			return matches;
		}
		public function getElementBySelector(selector : String) : UIComponent
		{
			return getElementsBySelector(selector)[0];
		}
		
		public function get selectorPath() : String
		{
			return m_selectorPath;
		}
		
		public function get cssTag() : String
		{
			return m_elementType;
		}
		
		public function valueBySelector(selector : String) : Number
		{
			var target : Object;
			var property : String;
			
			//split path and property
			var split : Array = selector.split(':');
			//the property has to be the last element in the selector.
			//Note that if you forget to add a property, the whole selector is treated 
			//as the property, causing an Exception to be thrown below.
			property = split.pop();
			//If there's no path, this element has to be the target
			if (!split.length || !split[0].length)
			{
				target = this;
			}
			else
			{
				var path : String = split.pop();
				target = getElementBySelector(path);
			}
			
			var value : Number = Number(target[property]);
			return value;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function initialize() : void
		{
			if (!m_class.basicStyles)
			{
				m_class.basicStyles = new CSSDeclaration();
				m_class.basicStyles.addDefaultValues();
				m_elementDefaultStyles = m_class.basicStyles;
				initDefaultStyles();
			}
			else
			{
				m_elementDefaultStyles = m_class.basicStyles;
			}
			m_instanceStyles = new CSSDeclaration();
			m_currentStyles = {};
			m_stylesInvalidated = true;
			super.initialize();
		}
		
		/**
		 * creates all clips needed to display the UIObjects' content
		 */
		protected override function createDisplayClips() : void
		{
			super.createDisplayClips();
		}
		
		protected override function validateElement(
			forceValidation:Boolean = false, validateStyles:Boolean = false) : void
		{
			if (m_skipNextValidation)
			{
				m_skipNextValidation = false;
				return;
			}
			if (validateStyles)
			{
				m_stylesInvalidated = true;
			}
			super.validateElement(forceValidation);
		}
		/**
		 * Hook method, executed before the UIObjects' children get validated
		 */
		protected override function validateBeforeChildren() : void
		{
			m_oldOuterBoxDimension = new Point(
				m_borderBoxWidth + m_marginLeft + m_marginRight, 
				m_borderBoxHeight + m_marginTop + m_marginBottom);
			m_oldInFlowStatus = m_positionInFlow;
		
			var oldSpecifiedDimensions : Point = 
				new Point(m_currentStyles.width, m_currentStyles.height);
			
			if (m_activeTransitions)
			{
				m_stylesInvalidated = true;
			}
			if (m_stylesInvalidated)
			{
				calculateStyles();
				if (m_stylesInvalidated)
				{
					applyStyles();
					m_specifiedDimensionsChanged = !oldSpecifiedDimensions.equals(
						new Point(m_currentStyles.width, m_currentStyles.height));
					if (m_specifiedDimensionsChanged)
					{
						resolveSpecifiedDimensions();
					}
				}
				else
				{
					m_stylesInvalidated = false;
				}
			}
		}
		/**
		 * Hook method, executed after the UIObjects' children get validated
		 */
		protected override function validateAfterChildren() : void
		{
			m_displayStack = [];
			
			applyInFlowChildPositions();
			
			var autoFlag:String = CSSProperty.AUTO_FLAG;
			
			var widthProperty:CSSProperty = m_complexStyles.getStyle('width');
			var outerWidthProperty:CSSProperty = 
				m_complexStyles.getStyle('outerWidth');
			var widthIsAuto:Boolean = 
				widthProperty.specifiedValue() == autoFlag && 
				(!outerWidthProperty ||
				outerWidthProperty.specifiedValue() == autoFlag);
			var heightProperty:CSSProperty = m_complexStyles.getStyle('height');
			var outerHeightProperty:CSSProperty = 
				m_complexStyles.getStyle('outerHeight');
			var heightIsAuto:Boolean = 
				(!heightProperty || heightProperty.specifiedValue() == autoFlag) && 
				(!outerHeightProperty || 
				outerHeightProperty.specifiedValue() == autoFlag);
			
			var oldIntrinsicHeight : Number = m_intrinsicHeight;
			var oldIntrinsicWidth : Number = m_intrinsicWidth;
			
			measure();
			
			if (widthIsAuto || heightIsAuto)
			{
				if (widthIsAuto && 
					(m_currentStyles.display == 'inline' ||
					(!m_positionInFlow && (m_leftIsAuto || m_rightIsAuto))))
				{
					m_width = m_intrinsicWidth;
				}
				if (m_intrinsicHeight != -1 && heightIsAuto)
				{
					m_height = m_intrinsicHeight;
				}
			}
			
			m_borderBoxHeight = calculateContentHeight() + 
				m_borderTopWidth + m_borderBottomWidth + 
				m_paddingTop + m_paddingBottom;
			m_borderBoxWidth = calculateContentWidth() + 
				m_borderLeftWidth + m_borderRightWidth + 
				m_paddingLeft + m_paddingRight;
			
			m_dimensionsChanged = 
				!m_oldOuterBoxDimension.equals(new Point(
				m_borderBoxWidth + m_marginLeft + m_marginRight, 
				m_borderBoxHeight + m_marginTop + m_marginBottom));
			
			var parentReflowNeeded:Boolean = false;
			
			if (m_dimensionsChanged || m_stylesInvalidated)
			{
				applyBackgroundAndBorders();
				applyOverflowProperty();
				if ((m_float || m_positionInFlow) && m_dimensionsChanged)
				{
					parentReflowNeeded = true;
	//				trace("f reason for parentReflow: dims of in-flow changed");
				}
			}
			else if (m_intrinsicHeight != oldIntrinsicHeight || 
				m_intrinsicWidth != oldIntrinsicWidth)
			{
				applyOverflowProperty();
			}
			
			if (!(m_parentElement is UIComponent && m_parentElement != this && 
				UIComponent(m_parentElement).m_isValidating))
			{
				if ((m_oldInFlowStatus == -1 || m_dimensionsChanged) && 
					!m_positionInFlow)
				{
					//The element is positioned absolutely or fixed.
					//check if at least one of the vertical and one of the 
					//horizontal dimensions is specified. If not, we need to 
					//let the parent do the positioning
					if ((m_topIsAuto && m_bottomIsAuto) || 
						(m_leftIsAuto && m_rightIsAuto))
					{
						parentReflowNeeded = true;
	//					trace("f reason for reflow: All positions in " +
	//						"absolute positioned element are auto");
					}
				}
				else if (m_oldInFlowStatus != m_positionInFlow)
				{
					parentReflowNeeded = true;
	//				trace("f reason for parentReflow: flowPos changed");
				}
				if (m_parentElement && m_parentElement != this)
				{
					if (parentReflowNeeded)
					{
	//					trace("w parentreflow needed in " + 
	//						m_elementType + "#"+m_cssId + "."+m_cssClasses);
						m_skipNextValidation = true;
						m_parentElement.forceRedraw();
						return;
					}
					else
					{
	//					trace("w no parentreflow needed in " + 
	//						m_elementType + "#"+m_cssId + "."+m_cssClasses);
						UIComponent(m_parentElement).applyOutOfFlowChildPositions();
					}
				}
				else
				{
					applyOutOfFlowChildPositions();
				}
			}
			applyDepthSorting();
		}
		protected override function finishValidation() : void
		{
			super.finishValidation();
			
			m_dimensionsChanged = false;
			m_specifiedDimensionsChanged = false;
			
			m_stylesInvalidated = false;
		}
		
		protected function applyDepthSorting() : void
		{
			//add to displaystack for later sorting
			if (m_backgroundDisplay)
			{
				m_displayStack.push(
				{
					element : m_backgroundDisplay, 
					index : -20, 
					zIndex : 0
				});
			}
			//add to displaystack for later sorting
			if (m_bordersDisplay)
			{
				m_displayStack.push(
				{
					element : m_bordersDisplay, 
					index : -10, 
					zIndex : 1
				});
			}
			//sort children by zIndex and declaration index
			m_displayStack.sortOn(['zIndex', 'index'], Array.NUMERIC);
			for (var i : int = 0; i < m_displayStack.length; i++)
			{
				var element : DisplayObject = m_displayStack[i].element;
				m_contentDisplay.setChildIndex(element, i);
			}
			m_displayStack = null;
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
		
		protected function initDefaultStyles() : void
		{
		}
		
		protected function refreshSelectorPath() : void
		{
			var oldPath:String = m_selectorPath;
			var path : String;
			if (m_parentElement)
			{
				path = (m_parentElement as UIComponent).selectorPath + " ";
			}
			else 
			{
				path = "";
			}
			path += "@" + m_elementType + "@";
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
		 * parses all styles associated with this element and its classes
		 * and creates a combined style object
		 */
		protected function calculateStyles() : void
		{
			refreshSelectorPath();
			
			var styles:CSSDeclaration = m_elementDefaultStyles.clone();
			var oldStyles:CSSDeclaration = m_specifiedStyles;
			
			if (m_parentElement != this && m_parentElement is UIComponent)
			{
				styles.inheritCSSDeclaration(
					UIComponent(m_parentElement).m_complexStyles);
			}
			
			if (m_rootElement.styleSheet)
			{
				styles.mergeCSSDeclaration(m_rootElement.styleSheet.
					getStyleForEscapedSelectorPath(m_selectorPath));
			}
			
			styles.mergeCSSDeclaration(m_instanceStyles);
			
			//check if styles or other relevant factors have changed and stop validation 
			//if not.
			if (!(m_containingBlock && m_containingBlock.m_specifiedDimensionsChanged) && 
				styles.compare(oldStyles) && !m_activeTransitions && 
				!(this == m_rootElement && DocumentView(this).stageDimensionsChanged))
			{
				m_stylesInvalidated = false;
				return;
			}
			
			m_specifiedStyles = styles;
			styles = processTransitions(oldStyles, styles);
			m_complexStyles = styles;
			m_currentStyles = styles.toObject();
			
			
			resolvePositioningProperties(styles);
			resolveContainingBlock();
			resolveRelativeStyles(styles);
		}
			
		protected function applyStyles() : void
		{	
			var autoFlag:String = CSSProperty.AUTO_FLAG;
			var styles : CSSDeclaration = m_complexStyles;
			
			var prop:CSSProperty;
			prop = styles.getStyle('left');
			if (!prop || prop.specifiedValue() == autoFlag)
			{
				m_leftIsAuto = true;
				m_left = 0;
			}
			else
			{
				m_leftIsAuto = false;
				m_left = prop.valueOf() as Number;
			}
			prop = styles.getStyle('right');
			if (!prop || prop.specifiedValue() == autoFlag)
			{
				m_rightIsAuto = true;
				m_right = 0;
			}
			else
			{
				m_rightIsAuto = false;
				m_right = prop.valueOf() as Number;
			}
			prop = styles.getStyle('top');
			if (!prop || prop.specifiedValue() == autoFlag)
			{
				m_topIsAuto = true;
				m_top = 0;
			}
			else
			{
				m_topIsAuto = false;
				m_top = prop.valueOf() as Number;
			}
			prop = styles.getStyle('bottom');
			if (!prop || prop.specifiedValue() == autoFlag)
			{
				m_bottomIsAuto = true;
				m_bottom = 0;
			}
			else
			{
				m_bottomIsAuto = false;
				m_bottom = prop.valueOf() as Number;
			}
			
			m_positionOffset = new Point(0, 0);
			if (m_positioningType == 'relative')
			{
				m_positionOffset.x = m_left;
				m_positionOffset.y = m_top;
			}
			
			
			//calculate border widths
			var borderWidthProp : CSSProperty;
			var borderStyleProp : CSSProperty;
			
			borderWidthProp = styles.getStyle('borderLeftWidth');
			borderStyleProp = styles.getStyle('borderLeftStyle');
			if (borderWidthProp && borderStyleProp && 
				borderStyleProp.valueOf() != 'none')
			{
				m_borderLeftWidth = borderWidthProp.valueOf() as Number;
			}
			else
			{
				m_borderLeftWidth = 0;
			}
			
			borderWidthProp = styles.getStyle('borderTopWidth');
			borderStyleProp = styles.getStyle('borderTopStyle');
			if (borderWidthProp && borderStyleProp && 
				borderStyleProp.valueOf() != 'none')
			{
				m_borderTopWidth = borderWidthProp.valueOf() as Number;
			}
			else
			{
				m_borderTopWidth = 0;
			}
			
			borderWidthProp = styles.getStyle('borderRightWidth');
			borderStyleProp = styles.getStyle('borderRightStyle');
			if (borderWidthProp && borderStyleProp && 
				borderStyleProp.valueOf() != 'none')
			{
				m_borderRightWidth = borderWidthProp.valueOf() as Number;
			}
			else
			{
				m_borderRightWidth = 0;
			}
			
			borderWidthProp = styles.getStyle('borderBottomWidth');
			borderStyleProp = styles.getStyle('borderBottomStyle');
			if (borderWidthProp && borderStyleProp && 
				borderStyleProp.valueOf() != 'none')
			{
				m_borderBottomWidth = borderWidthProp.valueOf() as Number;
			}
			else
			{
				m_borderBottomWidth = 0;
			}
			
			
			if (m_currentStyles.tabIndex != null)
			{
				m_tabIndex = m_currentStyles.tabIndex;
			}
				
			m_tooltipRenderer = m_currentStyles.tooltipRenderer;
			m_tooltipDelay = m_currentStyles.tooltipDelay;
			
			if (m_currentStyles.blendMode != null)
			{
				m_contentDisplay.blendMode = m_currentStyles.blendMode;
			}
			
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
			
			super.rotation = m_currentStyles.rotation || 0;
			if (m_currentStyles.opacity != null)
			{
				super.alpha = m_currentStyles.opacity;
			}
			else
			{
				super.alpha = 1;
			}
			
			if (!m_currentStyles.outerWidth)
			{
				m_currentStyles.outerWidth = m_width + 
					m_borderLeftWidth + m_paddingLeft + 
					m_borderRightWidth + m_paddingRight;
			}
			if (!m_currentStyles.outerHeight)
			{
				m_currentStyles.outerHeight = m_height + 
					m_borderTopWidth + m_paddingTop + 
					m_borderBottomWidth + m_paddingBottom;
			}
			m_paddingBoxWidth = m_paddingLeft + m_width + m_paddingRight;
			m_paddingBoxHeight = m_paddingTop + m_height + m_paddingBottom;
//			trace(m_selectorPath);
//			trace(m_complexStyles);
		}
		
		protected function resolvePositioningProperties(styles : CSSDeclaration) : void
		{
			var floatProperty : CSSProperty = styles.getStyle('float');
			if (floatProperty != null && floatProperty.valueOf() != 'none')
			{
				m_float = floatProperty.valueOf() as String;
			}
			else
			{
				m_float = null;
			}
			
			var positioningProperty:CSSProperty = styles.getStyle('position');
			var positioning:String;
			if (!positioningProperty)
			{
				positioning = m_positioningType = 'static';
			}
			else
			{
				positioning = m_positioningType = 
					String(positioningProperty.valueOf());
			}
			
			if (!m_float && (positioning == 'static' || positioning == 'relative'))
			{
				m_positionInFlow = 1;
			}
			else
			{
				m_positionInFlow = 0;
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
				var parentComponent:UIComponent = UIComponent(m_parentElement);
				if (m_positioningType == 'fixed')
				{
					m_containingBlock = m_rootElement;
				}
				else if (m_positioningType == 'absolute')
				{
					var inspectedBlock:UIComponent = parentComponent;
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
		
		protected function processTransitions(
			oldStyles : CSSDeclaration, newStyles : CSSDeclaration) : CSSDeclaration
		{
			var transitionPropName : String;
			var transition : CSSPropertyTransition;
			var startTime : int = getTimer();
			if (newStyles && newStyles.getStyle('RepriseTransitionProperty'))
			{
				var transitionProperties : Array = 
					newStyles.getStyle('RepriseTransitionProperty').specifiedValue();
				var transitionDurations : Array = 
					newStyles.getStyle('RepriseTransitionDuration').specifiedValue();
				var transitionDelays : Array = 
					newStyles.getStyle('RepriseTransitionDelay').specifiedValue();
				var transitionEasings : Array = newStyles.getStyle(
					'RepriseTransitionTimingFunction').specifiedValue();
				var defaultValues : Array = newStyles.getStyle(
					'RepriseTransitionDefaultValue').specifiedValue();
				
				//remove any transitions that aren't supposed to be active anymore
				if (m_activeTransitions)
				{
					for (transitionPropName in m_activeTransitions)
					{
						if (transitionProperties.indexOf(transitionPropName) == -1)
						{
							delete m_activeTransitions[transitionPropName];
						}
					}
				}
				else
				{
					m_activeTransitions = {};
				}
				
				//add all new properties and update already active ones
				for (var i : int = transitionProperties.length; i--;)
				{
					transitionPropName = transitionProperties[i];
					var oldValue : CSSProperty = (oldStyles && 
						oldStyles.getStyle(transitionPropName)) as CSSProperty;
					var targetValue : CSSProperty = 
						newStyles.getStyle(transitionPropName);
					
					//check for default value if we have a target value but no old value
					if (targetValue && !oldValue && 
						defaultValues[i] && defaultValues[i] != 'none')
					{
						oldValue = CSSProperty(CSSPropertyCache.propertyForKeyValue(
							transitionPropName, defaultValues[i], null));
					}
					
					//exception for intrinsic dimensions
//					if (!targetValue && (transitionPropName == 'intrinsicHeight' || 
//						transitionPropName == 'intrinsicWidth'))
//					{
//						//TODO: cache these properties
//						trace("exception for " + transitionPropName);
//						if (!m_firstDraw)
//						{
//							oldValue = new CSSProperty();
//							oldValue.setSpecifiedValue(0);
//						}
//						targetValue = new CSSProperty();
//						targetValue.setSpecifiedValue(999);
//					}
					
					//ignore properties that don't have previous values or target values
					//TODO: check if we can implement default values for new elements
					if (!oldValue || !targetValue || 
						oldValue.specifiedValue() == targetValue.specifiedValue())
					{
						continue;
					}
					if (transitionEasings[i])
					{ 
						var easing : Function = transitionEasings[i];
					}
					else
					{
						easing = Linear.easeNone;
					}
					transition = m_activeTransitions[transitionPropName];
					if (!transition)
					{
						transition = new CSSPropertyTransition(transitionPropName);
						transition.duration = transitionDurations[i];
						transition.delay = transitionDelays[i];
						transition.easing = easing;
						transition.startTime = startTime;
						transition.startValue = oldValue;
						transition.endValue = targetValue;
						m_activeTransitions[transitionPropName] = transition;
					}
					else if (transition.endValue != targetValue)
					{
						transition.easing = easing;
						transition.updateValues(targetValue, transitionDurations[i], 
							transitionDelays[i], startTime, this);
					}
				}
			}
			
			if (!m_activeTransitions)
			{
				return newStyles;
			}
			
			var styles : CSSDeclaration = newStyles.clone();
			var activeTransitionsCount : int = 0;
			for (transitionPropName in m_activeTransitions)
			{
				transition = m_activeTransitions[transitionPropName];
				transition.setValueForTimeInContext(startTime, this);
				styles.setPropertyForKey(transition.currentValue, transitionPropName);
				if (transition.hasCompleted)
				{
					delete m_activeTransitions[transitionPropName];
				}
				else
				{
					activeTransitionsCount++;
				}
			}
			
			if (!activeTransitionsCount)
			{
				m_activeTransitions = null;
			}
			else
			{
				m_stylesInvalidated = true;
				invalidate();
			}
			return styles;
		}
		
		protected function resolveRelativeStyles(styles:CSSDeclaration) : void
		{
			var parentW:Number = m_containingBlock.m_currentStyles.width;
			var parentH:Number = m_containingBlock.m_currentStyles.height;
			
			var propsResolvableToContainingWidth:Array = 
			[
				'marginTop',
				'marginBottom',
				'marginLeft',
				'marginRight',
				'paddingTop',
				'paddingBottom',
				'paddingLeft',
				'paddingRight'
			];
			resolvePropsToValue(styles, propsResolvableToContainingWidth, parentW);
			
			var wProp : CSSProperty = styles.getStyle('width');
			var hProp : CSSProperty = styles.getStyle('height');
			
			if (wProp.specifiedValue() == 'auto')
			{
				var outerWidthProp : CSSProperty = styles.getStyle('outerWidth');
				if (outerWidthProp != null && 
					outerWidthProp.specifiedValue() != 'auto')
				{
					var specOuterWidth : Number;
					if (outerWidthProp.isRelativeValue())
					{
						specOuterWidth = Math.round(
							outerWidthProp.resolveRelativeValueTo(parentW));
					}
					else
					{
						specOuterWidth = outerWidthProp.valueOf() as Number;
					}
					m_width = m_currentStyles.width = specOuterWidth - 
						m_marginLeft - m_marginRight - 
						m_paddingLeft - m_paddingRight - 
						m_borderLeftWidth - m_borderRightWidth;
				}
				else if (!m_positionInFlow)
				{
					m_width = m_currentStyles.width = parentW - 
						m_left - m_right - 
						m_marginLeft - m_marginRight - 
						m_paddingLeft - m_paddingRight - 
						m_borderLeftWidth - m_borderRightWidth;
				}
				else
				{
					m_width = m_currentStyles.width = parentW - 
						m_marginLeft - m_marginRight - 
						m_paddingLeft - m_paddingRight - 
						m_borderLeftWidth - m_borderRightWidth;
				}
			}
			else if (wProp.isRelativeValue())
			{
				var relevantWidth : Number = parentW;
				if (m_positioningType == 'absolute')
				{
					relevantWidth = m_containingBlock.calculateContentWidth() + 
						m_containingBlock.m_paddingLeft + 
						m_containingBlock.m_paddingRight;
				}
				m_width = m_currentStyles.width = 
					wProp.resolveRelativeValueTo(relevantWidth);
			}
			else
			{
				m_width = m_currentStyles.width || 0;
			}
			
			var propsResolvableToOwnWidth:Array = 
			[
				'borderTopLeftRadius',
				'borderTopRightRadius',
				'borderBottomLeftRadius',
				'borderBottomRightRadius'
			];
			//TODO: verify that we should really resolve the border-radii this way
			resolvePropsToValue(styles, propsResolvableToOwnWidth, 
				m_width + m_borderTopWidth);
			
			if (hProp.specifiedValue() == 'auto')
			{
				var outerHeightProp : CSSProperty = styles.getStyle('outerHeight');
				if (outerHeightProp && 
					outerHeightProp.specifiedValue() != 'auto')
				{
					var specOuterHeight : Number;
					if (outerHeightProp.isRelativeValue())
					{
						specOuterHeight = outerHeightProp.resolveRelativeValueTo(parentH);
					}
					else
					{
						specOuterHeight = outerHeightProp.valueOf() as Number;
					}
					m_height = m_currentStyles.height = specOuterHeight - 
						m_marginTop - m_marginBottom - 
						m_paddingTop - m_paddingBottom - 
						m_borderTopWidth - m_borderBottomWidth;
				}
				else
				{
					m_height = m_currentStyles.height;
				}
			}
			else
			{
				if (hProp.isRelativeValue())
				{
					m_height = hProp.resolveRelativeValueTo(parentH);
				}
				else
				{
					m_height = m_currentStyles.height;
				}
			}
		}
		
		protected function resolvePropsToValue(styles : CSSDeclaration, 
			props : Array, baseValue : Number) : void
		{
			for (var i:Number = props.length; i--;)
			{
				var propName:String = props[i];
				var cssProperty:CSSProperty = styles.getStyle(propName);
				if (cssProperty)
				{
					if (cssProperty.isRelativeValue())
					{
						m_currentStyles[propName] = this["m_"+propName] = 
							Math.round(cssProperty.resolveRelativeValueTo(baseValue));
					}
					this["m_"+propName] = m_currentStyles[propName];
				}
				else 
				{
					m_currentStyles[propName] = this["m_"+propName] = 0;
				}
			}
		}
		
		/**
		 * calculates the vertical space taken by this elements' content
		 */
		protected function calculateContentHeight() : Number
		{
			return m_height;
		}
	
		/**
		 * calculates the horizontal space taken by this elements' content
		 */
		protected function calculateContentWidth() : Number
		{
			return m_width;
		}
		
		/**
		 * applies position and dimensions based on css definitions and other 
		 * relevant factors.
		 */
		protected function resolveSpecifiedDimensions() : void
		{
			//apply final relative position/paddings/borderWidths to displays
			m_contentDisplay.y = m_positionOffset.y + 
				m_borderTopWidth;
			m_contentDisplay.x = m_positionOffset.x + 
				m_borderLeftWidth;
		}
	
		protected function applyInFlowChildPositions() : void
		{
			var childCount : int = m_children.length;
			if (!childCount)
			{
				return;
			}
			
			var autoFlag:String = CSSProperty.AUTO_FLAG;
			
			var widestChildWidth:Number = 0;
			var collapsibleMargin:Number = 0;
			var topMarginCollapsible:Boolean = 
				!m_borderTopWidth && !m_paddingTop && m_positionInFlow;
			if (topMarginCollapsible)
			{
				collapsibleMargin = m_marginTop;
			}
			var totalAvailableWidth:Number = calculateContentWidth();
			var currentLineBoxTop:Number = m_paddingTop;
			var currentLineBoxHeight:Number = 0;
			var currentLineBoxLeftBoundary:Number = 0;
			var currentLineBoxRightBoundary:Number = totalAvailableWidth;
			var currentLineBoxChildren : Array = [];
			
			var i : int;
			for (i = 0; i < childCount; i++)
			{
				var child:UIComponent = m_children[i] as UIComponent;
				//only deal with children that derive from UIComponent
				if (!child)
				{
					continue;
				}
				var childStyles:CSSDeclaration = child.m_complexStyles;
				
				//apply horizontal position
				if (child.m_float)
				{
					var childWidth:Number = child.m_borderBoxWidth + 
						child.m_marginLeft + child.m_marginRight;
					if (childWidth > currentLineBoxRightBoundary - 
						currentLineBoxLeftBoundary)
					{
						if (currentLineBoxChildren.length)
						{
							applyVerticalPositionsInLineBox(
								currentLineBoxTop, currentLineBoxHeight, 
								currentLineBoxChildren);
						}
						currentLineBoxTop += 
							currentLineBoxHeight + collapsibleMargin;
						collapsibleMargin = 0;
						currentLineBoxHeight = 0;
						currentLineBoxLeftBoundary = 0;
						currentLineBoxRightBoundary = totalAvailableWidth;
						currentLineBoxChildren = [];
					}
					if (child.m_float == 'left')
					{
						child.x = 
							currentLineBoxLeftBoundary + child.m_marginLeft;
						currentLineBoxLeftBoundary = child.x + 
							child.m_borderBoxWidth + child.m_marginRight;
					}
					else if (child.m_float == 'right')
					{
						child.x = currentLineBoxRightBoundary - 
							child.m_borderBoxWidth - child.m_marginRight;
						currentLineBoxRightBoundary = 
							child.x - child.m_marginLeft;
					}
					currentLineBoxHeight = Math.max(currentLineBoxHeight, 
						child.m_borderBoxHeight + 
						child.m_marginTop + child.m_marginBottom);
					var childVAlign : String = 
						child.m_currentStyles.verticalAlign || 'top';
					if (childVAlign != 'top')
					{
						currentLineBoxChildren.push(child);
					}
				}
				else if (child.m_positionInFlow || 
					(child.m_leftIsAuto && child.m_rightIsAuto))
				{
					var childMarginLeft : CSSProperty = 
						childStyles.getStyle('marginLeft');
					if (childMarginLeft && 
						childMarginLeft.specifiedValue() == autoFlag)
					{
						var childMarginRight : CSSProperty = 
							childStyles.getStyle('marginRight');
						if (childMarginRight && 
							childMarginRight.specifiedValue() == autoFlag)
						{
							//center horizontally
							child.x = Math.round(totalAvailableWidth / 2 - 
								child.m_borderBoxWidth / 2);
						}
						else
						{
							//align right
							child.x = totalAvailableWidth - child.m_borderBoxWidth - 
								child.m_marginRight - m_paddingRight;
						}
					}
					else
					{
						//align left
						child.x = child.m_marginLeft + m_paddingLeft;
					}
				}
				widestChildWidth = Math.max(child.x + 
					child.m_borderBoxWidth + child.m_marginRight, 
					widestChildWidth);
				
				//apply vertical position including margin collapsing
				if (child.m_positionInFlow)
				{
					var childMarginTop:Number = child.m_marginTop;
					var collapsedMargin:Number;
					if (collapsibleMargin >= 0 && childMarginTop >= 0)
					{
						collapsedMargin = 
							Math.max(collapsibleMargin, childMarginTop);
					}
					else if (collapsibleMargin >= 0 && childMarginTop < 0)
					{
						collapsedMargin = collapsibleMargin + childMarginTop;
					}
					else if (collapsibleMargin < 0 && childMarginTop >= 0)
					{
						collapsedMargin = collapsibleMargin + childMarginTop;
					}
					else
					{
						collapsedMargin = 
							Math.min(collapsibleMargin, childMarginTop);
					}
					
					if (topMarginCollapsible)
					{
						m_marginTop = collapsedMargin;
						collapsedMargin = 0;
						topMarginCollapsible = false;
					}
					child.y = currentLineBoxTop + collapsedMargin;
					
					//collapse margins through empty elements 
					if (!child.m_borderBoxHeight)
					{
						collapsibleMargin = 
							Math.max(collapsedMargin, child.m_marginBottom);
					}
					else
					{
						collapsibleMargin = child.m_marginBottom;
						topMarginCollapsible = false;
					}
					currentLineBoxTop = child.y + child.m_borderBoxHeight;
				}
				else
				{
					if (child.m_float || 
						(child.m_topIsAuto && child.m_bottomIsAuto))
					{
						child.y = currentLineBoxTop + child.m_marginTop;
					}
				}
				//add to displaystack for later sorting
				var depthStackEntry : Object = 
				{
					element : child, 
					index : i, 
					zIndex : child.m_currentStyles.zIndex || 0
				};
				depthStackEntry.zIndex > 0 && depthStackEntry.zIndex++;
				m_displayStack.push(depthStackEntry);
			}
			
			if (currentLineBoxChildren.length)
			{
				applyVerticalPositionsInLineBox(
					currentLineBoxTop, currentLineBoxHeight, currentLineBoxChildren);
			}
			m_intrinsicHeight = 
				currentLineBoxTop + currentLineBoxHeight + collapsibleMargin;
			m_intrinsicWidth = widestChildWidth;
		}
		
		protected function applyVerticalPositionsInLineBox(
			lineBoxTop : Number, lineBoxHeight : Number, lineBoxChildren : Array) : void
		{
			var i : Number = lineBoxChildren.length;
			while (i--)
			{
				var child : UIComponent = lineBoxChildren[i];
				switch (child.m_currentStyles.verticalAlign)
				{
					case 'middle':
					{
						child.y = lineBoxTop + Math.round(
							lineBoxHeight / 2 - (child.m_borderBoxHeight + 
							child.m_marginTop + child.m_marginBottom) / 2);
						break;
					}
					case 'bottom':
					case 'baseline':
					{
						child.y = lineBoxTop + Math.round(
							lineBoxHeight - (child.m_borderBoxHeight + 
							child.m_marginTop + child.m_marginBottom));
						break;
					}
					default:
				}
			}
		}
		
		protected function applyOutOfFlowChildPositions() : void
		{
			var childCount : int = m_children.length;
			for (var i:Number = 0; i < childCount; i++)
			{
				var child:UIComponent = m_children[i] as UIComponent;
				if (!child)
				{
					//only deal with children that derive from UIComponent
					continue;
				}
				if (!child.m_positionInFlow && !child.m_float)
				{
					var absolutePosition:Point = 
						child.getPositionRelativeToContext(child.m_containingBlock);
					absolutePosition.x -= child.x;
					absolutePosition.y -= child.y;
					
					if (!child.m_leftIsAuto)
					{
						var childMarginLeft : CSSProperty = 
							child.m_complexStyles.getStyle('marginLeft');
						var childMarginRight : CSSProperty = 
							child.m_complexStyles.getStyle('marginRight');
						if (!child.m_rightIsAuto && 
							childMarginLeft && childMarginLeft.isAuto() && 
							childMarginRight && childMarginRight.isAuto())
						{
							//center horizontally if margin-left and margin-right 
							//are both auto and left and right have values.
							child.x = child.m_left + Math.round((
								child.m_containingBlock.m_paddingBoxWidth - 
								child.m_right - child.m_left) / 2 - 
								child.m_borderBoxWidth /2);
						}
						else
						{
							child.x = child.m_left + 
								child.m_marginLeft - absolutePosition.x;
						}
					}
					else if (!child.m_rightIsAuto)
					{
						child.x = child.m_containingBlock.m_paddingBoxWidth - 
							child.m_paddingBoxWidth - child.m_borderRightWidth - 
							child.m_right - child.m_marginRight - absolutePosition.x;
					}
					
					if (!child.m_topIsAuto)
					{
						var childMarginTop : CSSProperty = 
							child.m_complexStyles.getStyle('marginTop');
						var childMarginBottom : CSSProperty = 
							child.m_complexStyles.getStyle('marginBottom');
						if (!child.m_bottomIsAuto && 
							childMarginTop && childMarginTop.isAuto() && 
							childMarginBottom && childMarginBottom.isAuto())
						{
							//center vertically if margin-top and margin-bottom 
							//are both auto and top and bottom have values.
							child.y = child.m_top + Math.round((
								child.m_containingBlock.calculateContentHeight() - 
								child.m_bottom - child.m_top) / 2 - 
								child.m_borderBoxHeight /2);
						}
						else
						{
							child.y = child.m_top + 
								child.m_marginTop - absolutePosition.y;
						}
					}
					else if (!child.m_bottomIsAuto)
					{
						child.y = child.m_containingBlock.m_paddingBoxHeight - 
							child.m_paddingBoxHeight - child.m_borderBottomWidth - 
							child.m_bottom - child.m_marginBottom - absolutePosition.y;
					}
				}
				child.applyOutOfFlowChildPositions();
			}
		}
	
	
		/**
		 * parses the elements' xmlDefinition as set through innerHTML
		 */
		protected function parseXMLDefinition(xmlDefinition : XML) : void
		{
			m_xmlDefinition = xmlDefinition;
			parseXMLAttributes(xmlDefinition);
			parseXMLContent(xmlDefinition);
			
			m_stylesInvalidated = true;
			invalidate();
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
						attributes[attribute.localName()] = attribute.toString();
					}
				}
				m_nodeAttributes = attributes;
				m_cssClasses = attributes['class'] || '';
				if (attributes.id)
				{
					cssId = attributes.id;
				}
				m_elementType = node.localName();
				
				setTooltipData(attributes.tooltip || attributes.title);
			}
		}
	
		/**
		 * parses and displays the elements' childNodes
		 */
		protected function parseXMLContent(node : XML) : void
		{
			for each (var childNode:XML in node.children())
			{
				preprocessTextNode(childNode);
				var child:UIComponent = 
					m_rootElement.uiRendererFactory().rendererByNode(childNode);
				if (child)
				{
					addChild(child);
					child.parseXMLDefinition(childNode);
				}
				else
				{
					trace ("f No handler found for node: " + childNode.toXMLString());
				}
			}
		}
		
		protected function preprocessTextNode(node : XML) : void
		{
			var textNodeTags : String = UIRendererFactory.TEXTNODE_TAGS;
			if (textNodeTags.indexOf(node.localName() + ",") != -1)
			{
				var nodesToCombine : XMLList = new XMLList(node);
				var parentNode : XML = node.parent() as XML;
				var siblings : XMLList = parentNode ? parentNode.* : null;
				if (!siblings)
				{
					return;
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
				var xmlParser : XML = <p/>;
				xmlParser.setChildren(nodesToCombine);
				siblings[node.childIndex()] = xmlParser;
			}
		}
	
		
		/**
		 * draws the background rect and borders according to the styles 
		 * specified for this element.
		 */
		protected function applyBackgroundAndBorders() : void
		{
			var backgroundRendererId:String = 
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
				m_contentDisplay.addChild(m_backgroundDisplay);
				m_backgroundRenderer = m_rootElement.uiRendererFactory().
					backgroundRendererById(backgroundRendererId);
				m_backgroundRenderer.setDisplay(m_backgroundDisplay);
			}
			
			var borderRendererId:String = m_currentStyles.borderRenderer || "";
			if (!m_borderRenderer || m_borderRenderer.id() != borderRendererId)
			{
				if (m_bordersDisplay)
				{
					m_borderRenderer.destroy();
					removeChild(m_bordersDisplay);
				}
				m_bordersDisplay = new Sprite();
				m_bordersDisplay.name = "border_" + borderRendererId;
				m_contentDisplay.addChild(m_bordersDisplay);
				m_borderRenderer = m_rootElement.uiRendererFactory().
					borderRendererById(borderRendererId);
				m_borderRenderer.setDisplay(m_bordersDisplay);
			}
			
			m_backgroundDisplay.x = m_bordersDisplay.x = 0 - m_borderLeftWidth;
			m_backgroundDisplay.y = m_bordersDisplay.y = 0 - m_borderTopWidth;
			
			m_backgroundRenderer.setSize(m_borderBoxWidth, m_borderBoxHeight);
			m_backgroundRenderer.setStyles(m_currentStyles);
			m_backgroundRenderer.setComplexStyles(m_complexStyles);
			m_backgroundRenderer.draw();
			
			m_borderRenderer.setSize(m_borderBoxWidth, m_borderBoxHeight);
			m_borderRenderer.setStyles(m_currentStyles);
			m_borderRenderer.setComplexStyles(m_complexStyles);
			m_borderRenderer.draw();
			
			//TODO: move into renderer
			if (m_currentStyles.backgroundBlendMode != null)
			{
				m_backgroundDisplay.blendMode = m_currentStyles.backgroundBlendMode;
			}
		}
		protected function applyOverflowProperty() : void
		{
			switch (m_currentStyles.overflow)
			{
				case 'hidden':
				{
					applyMask();
					break;
				}
				case 'scrollV':
				case 'scrollV-vertical':
				case 'scrollV-horizontal':
				case 0:
				{
					applyScrollbars();
					applyMask();
					break;
				}
				case 'visible':
				case undefined:
				{
					m_contentDisplay.mask = null;
					if (m_vScrollbar)
					{
						m_vScrollbar.setVisibility(false);
					}
					if (m_hScrollbar)
					{
						m_hScrollbar.setVisibility(false);
					}
					break;
				}
				default:
				{
					trace("w style not supported: overflow: " + 
						m_currentStyles.overflow + 
						"in element with selectorPath '" +
						m_selectorPath.split('@').join('') + "'");
					m_contentDisplay.mask = null;
				}
			}
		}
		protected function applyMask() : void
		{
			if (!m_contentMask)
			{
				m_contentMask = new Sprite();
				m_contentMask.name = 'mask';
				addChild(m_contentMask);
				m_contentMask.visible = false;
			}
			var radii : Array = [];
			var order : Array = 
				['borderTopLeftRadius', 'borderTopRightRadius', 
				'borderBottomRightRadius', 'borderBottomLeftRadius'];
			
			var i : Number;
			var radiusItem : Number;
			for (i = 0; i < order.length; i++)
			{
				radii.push(m_currentStyles[order[i]] || 0);
			}
			m_contentMask.graphics.clear();
			m_contentMask.graphics.beginFill(0x00ff00, 50);
			GfxUtil.drawRoundRect(m_contentMask, 0, 0, 
				m_borderBoxWidth, m_borderBoxHeight, radii);
			m_contentDisplay.mask = m_contentMask;
		}
		
		protected function applyScrollbars() : void
		{
			var availableWidth:Number = calculateContentWidth();
			var availableHeight:Number = calculateContentHeight();
			
			if (m_currentStyles.overflow == 'scrollV-vertical')
			{
				if (!m_vScrollbar)
				{
					m_vScrollbar = createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
				}
				availableWidth -= m_vScrollbar.outerWidth;
				m_vScrollbar.setVisibility(true);
				m_hScrollbar.setVisibility(false);
			}
			else if (m_currentStyles.overflow == 'scrollV')
			{
				if (!m_vScrollbar)
				{
					m_vScrollbar = createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
				}
				if (!m_hScrollbar)
				{
					m_hScrollbar = 
						createScrollbar(Scrollbar.ORIENTATION_HORIZONTAL);
				}
				availableWidth -= m_vScrollbar.outerWidth;
				m_vScrollbar.setVisibility(true);
				availableHeight -= m_hScrollbar.outerWidth;
				m_hScrollbar.setVisibility(true);
			}
	//		else if (m_currentStyles.overflow == 0) //'auto' gets resolved to '0'
	//		{
	//			if (m_labelDisplay.textHeight > availableHeight)
	//			{
	//				if (!m_vScrollbar)
	//				{
	//					m_vScrollbar = 
	//						createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
	//				}
	//				availableWidth -= m_vScrollbar.width;
	//				m_labelDisplay.width = availableWidth + 3;
	//				m_vScrollbar.setVisibility(true);
	//			}
	//			else
	//			{
	//				m_vScrollbar.setVisibility(false);
	//			}
	//			
	//			if (m_labelDisplay.textWidth > availableWidth)
	//			{
	//				if (!m_hScrollbar)
	//				{
	//					m_hScrollbar = 
	//						createScrollbar(Scrollbar.ORIENTATION_HORIZONTAL);
	//				}
	//				availableHeight -= m_hScrollbar.width;
	//				m_hScrollbar.setVisibility(true);
	//				
	//				if (!m_vScrollbar.getVisibility() && 
	//					m_labelDisplay.textHeight > availableHeight)
	//				{
	//					if (!m_vScrollbar)
	//					{
	//						m_vScrollbar = 
	//							createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
	//					}
	//					availableWidth -= m_vScrollbar.width;
	//					m_vScrollbar.setVisibility(true);
	//				}
	//			}
	//			else
	//			{
	//				m_hScrollbar.setVisibility(false);
	//			}
	//		}
			else
			{
				return;
			}
			
			if (availableWidth != calculateContentWidth())
			{
				m_stylesInvalidated = true;
				validateElement(true, true);
			}
			
			m_vScrollbar.setScrollProperties(
				availableHeight, 0, m_intrinsicHeight - availableHeight);
			
			availableHeight += m_paddingTop + m_paddingBottom;
			availableWidth += m_paddingLeft + m_paddingRight;
			
			m_vScrollbar.top = m_borderTopWidth;
			m_vScrollbar.outerHeight = availableHeight;
			m_vScrollbar.left = availableWidth + m_borderLeftWidth;
			m_vScrollbar.forceRedraw();
			
			m_hScrollbar.top = availableHeight + m_hScrollbar.outerWidth;
			m_hScrollbar.outerHeight = availableWidth;
		}
	
		protected function createScrollbar(
			orientation:String, skipListenerRegistration : Boolean = false) : Scrollbar
		{
			if (!m_scrollbarsDisplay)
			{
				m_scrollbarsDisplay = new Sprite();
				addChild(m_scrollbarsDisplay);
			}
			var scrollbar:Scrollbar = new Scrollbar();
			scrollbar.setParent(this);
			scrollbar.overrideContainingBlock(this);
			m_scrollbarsDisplay.addChild(scrollbar);
			scrollbar.cssClasses = orientation + "Scrollbar";
			scrollbar.setStyle('position', 'absolute');
			scrollbar.setStyle('autoHide', 'false');
			scrollbar.setStyle('width', 
				(m_currentStyles.scrollbarWidth || DEFAULT_SCROLLBAR_WIDTH) + 'px');
			if (orientation == Scrollbar.ORIENTATION_HORIZONTAL)
			{
				scrollbar.rotation = -90;
			}
			if (!skipListenerRegistration)
			{
				scrollbar.addEventListener(Event.CHANGE, 
					this[orientation + 'Scrollbar_change']);
			}
			scrollbar.addEventListener(MouseEvent.CLICK, scrollbar_event);
			return scrollbar;
		}
		
		protected function scrollbar_event(event : Event) : void
		{
			event.stopImmediatePropagation();
			event.stopPropagation();
		}
		
		protected function verticalScrollbar_change(event : Event) : void
		{
			m_contentDisplay.y = m_positionOffset.y + 
				m_borderTopWidth + m_paddingTop - m_vScrollbar.scrollPosition;
		}
		
		protected function horizontalScrollbar_change(event : Event) : void
		{
			m_contentDisplay.x = m_positionOffset.x + 
				m_borderLeftWidth + m_paddingLeft - m_hScrollbar.scrollPosition;
		}
		
		protected function i18n(key : String) : String
		{
			return m_rootElement.getI18N(key);
		}
		protected function i18nFlag(key : String) : Boolean
		{
			return m_rootElement.getI18NFlag(key);
		}
		protected function i18nObject(key : String) : Object
		{
			return m_rootElement.getI18NObject(key);
		}
		protected function track(trackingId : String) : void
		{
			m_rootElement.getTrack(trackingId);
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
		
		protected override function unregisterChildView(child:UIObject) : void
		{
			if (child is UIComponent)
			{
				if (child.parent == m_contentDisplay)
				{
					m_contentDisplay.removeChild(child);
					m_children.splice(m_children.indexOf(child), 1);
					invalidate();
				}
			}
			else
			{
				super.unregisterChildView(child);
			}
		}
	}
}