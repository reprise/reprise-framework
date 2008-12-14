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
	import reprise.core.reprise;
	import reprise.events.DisplayEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;	
	
	use namespace reprise;
	
	public class UIObject extends Sprite
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var className : String = "UIObject";
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_elementIDCounter : int = 0;
		
		protected var m_class : Class;
		protected var m_elementType : String;	
		
		protected var m_parentElement : UIObject;
		protected var m_children : Array = [];
		protected var m_rootElement : DocumentView;
		
		protected var m_isFirstChild : Boolean;
		protected var m_isLastChild : Boolean;
		
		protected var m_initialized : Boolean;
		protected var m_firstDraw : Boolean;
		protected var m_visible : Boolean = true;
		protected var m_isRendered : Boolean;
		protected var m_isInvalidated : Boolean;
		protected var m_isValidating : Boolean;
	
		protected var m_tabIndex : Number;
	
		protected var m_contentDisplay : DisplayObjectContainer;
		protected var m_filters : Array;
		
		protected var m_canBecomeKeyView : Boolean;
		protected var m_nextKeyView : UIObject;
		protected var m_previousKeyView : UIObject;
		protected var m_firstKeyChild : UIObject;
		protected var m_lastKeyChild : UIObject;
		protected var m_keyOrder : Array;
		
		protected var m_tooltipData : Object = null;
		protected var m_tooltipRenderer : String = null;
		protected var m_tooltipDelay : Number = 0;
		
		protected var m_delayedMethods : Array;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function UIObject()
		{
			m_class = Class(Object(this).constructor);
			if (m_class['className'])
			{
				m_elementType = m_class['className'];
			}
			else
			{
				var className : String = getQualifiedClassName(this);
				m_elementType =  className.substr(className.indexOf('::') + 2);
			}
		}
		
		/**
		 * getter for the <code>DocumentView</code> that is the root of the view 
		 * structure this <code>UIObject</code> is contained in.
		 */
		public function get document() : DocumentView
		{
			return m_rootElement;
		}
		
		/**
		 * Returns the url of the swf in whose display list this element is in.
		 */
		public function applicationURL() : String
		{
			return loaderInfo.url;
		}
		
		/**
		 * Sets the parent <code>UIObject</code> for the object.
		 * 
		 * In most cases, this method doesn't need to be called and, in fact, 
		 * shouldn't be called as it gets called internally when adding the object
		 * to another objects displayList by using <code>UIObject::addchild</code>
		 * or one of its variants.
		 */
		public function setParent(parent:UIObject) : UIObject
		{
			m_parentElement = parent;
			m_rootElement = parent.m_rootElement;
			
			if (!m_initialized)
			{
				initialize();
			}
			invalidate();
			
			dispatchEvent(new DisplayEvent(DisplayEvent.ADDED_TO_DOCUMENT, true));
			
			return this;
		}
		
		public override function addChild(child : DisplayObject) : DisplayObject
		{
			if (child is UIObject)
			{
				return addChildAt(child, m_children.length);
			}
			else
			{
				return super.addChild(child);
			}
		}
		
		public override function addChildAt(
			child : DisplayObject, index : int) : DisplayObject
		{
			if (child is UIObject)
			{
				var element : UIObject = UIObject(child);
				if (element.m_parentElement == this)
				{
					return element;
				}
				if (element.m_parentElement)
				{
					element.m_parentElement.unregisterChildView(element);
				}
				m_contentDisplay.addChildAt(
					child, Math.min(m_contentDisplay.numChildren, index));
				element.setParent(this);
				
				
				if (index == 0)
				{
					element.m_isFirstChild = true;
					if (m_children.length)
					{
						UIObject(m_children[0]).m_isFirstChild = false;
					}
				}
				//if the child is reparented, the value needs to be reset
				else
				{
					element.m_isFirstChild = false;
				}
				if (index == m_children.length)
				{
					element.m_isLastChild = true;
					if (m_children.length)
					{
						UIObject(m_children[m_children.length-1]).m_isLastChild = false;
					}
				}
				//if the child is reparented, the value needs to be reset
				else
				{
					element.m_isLastChild = false;
				}
				
				m_children.splice(index, 0, child);
				invalidate();
			}
			else
			{
				super.addChildAt(child, index);
			}
			return child;
		}
		
		/**
		 * TODO: write a description of this method
		 */
		public function nextKeyView() : UIObject
		{
			if (m_children.length)
			{
				return m_firstKeyChild;
			}
			return m_nextKeyView;
		}
		/**
		 * TODO: write a description of this method
		 */
		public function setNextKeyView(nextKeyView : UIObject) : void
		{		
			m_nextKeyView = nextKeyView;
			var prevKeyView : UIObject = this;
			
			if (m_children.length)
			{
				m_lastKeyChild && m_lastKeyChild.setNextKeyView(nextKeyView);
				prevKeyView = m_lastKeyChild;
			}
			
			if (nextKeyView)
			{
				nextKeyView.setPreviousKeyView(prevKeyView);
			}
		}	
		/**
		 * TODO: write a description of this method
		 */
		public function nextValidKeyView() : UIObject
		{
			var nextValidKey : UIObject;
			if (visibility())
			{
				nextValidKey = nextKeyView();
			}
			else
			{
				nextValidKey = m_nextKeyView;
			}
			while (true)
			{
				if (nextValidKey == null || nextValidKey == this || 
					nextValidKey.canBecomeKeyView())
				{
					return nextValidKey;
				}
				nextValidKey = nextValidKey.nextKeyView();
			}
			return null;
		}
		
		/**
		 * TODO: write a description of this method
		 */
		public function previousKeyView() : UIObject
		{
			return m_previousKeyView;
		}
		/**
		 * TODO: write a description of this method
		 */
		public function setPreviousKeyView(previousKeyView : UIObject) : void
		{
			m_previousKeyView = previousKeyView;
		}
		/**
		 * TODO: write a description of this method
		 */
		public function previousValidKeyView() : UIObject
		{
			var previousValidKey : UIObject = previousKeyView();
			while (true)
			{
				if (previousValidKey == null || previousValidKey == this || 
					previousValidKey.canBecomeKeyView())
				{
					return previousValidKey;
				}
				previousValidKey = previousValidKey.previousKeyView();
			}
			return null;
		}
		
		/**
		 * TODO: write a description of this method
		 */
		public function canBecomeKeyView() : Boolean
		{
			return m_canBecomeKeyView && !isOffScreen();
		}
		
		/**
		 * Informs the element about its focus state.
		 * 
		 * Note that this method doesn't really set the focus as that's implemented by other means. 
		 * Instead, it serves only to inform the element about whether it is focused or not.
		 * 
		 * @param value A boolean specifying if the element has focus
		 * @param method The means by which the focus was applied, i.e. whether the element was 
		 * focused by mouse or by keyboard
		 */
		public function setFocus(value : Boolean, method : String) : void
		{
		}
		
		/**
		 * Returns the tooltip data associated with this element.
		 * 
		 * This method is mostly used internally by the built in tooltip rendering 
		 * facilities.
		 * 
		 * @see AbstractTooltip
		 * @see DefaultTooltipRenderer
		 */
		public function tooltipData() : Object
		{
			return m_tooltipData;
		}
		/**
		 * Takes an object to be used as the tooltip data associated with this 
		 * element.
		 * 
		 * This method is mostly used internally by the built in tooltip rendering 
		 * facilities.
		 * 
		 * @param data The data object to be used as tooltip data for this element
		 * 
		 * @see AbstractTooltip
		 * @see DefaultTooltipRenderer
		 */
		public function setTooltipData(data:Object) : void
		{
			m_tooltipData = data;
			dispatchEvent(new DisplayEvent(DisplayEvent.TOOLTIPDATA_CHANGED));
		}
		/**
		 * Returns the delay after which a tooltip is shown for this element if the 
		 * user hovers over it.
		 * 
		 * This method is mostly used internally by the built in tooltip rendering 
		 * facilities.
		 * 
		 * @return The delay after which a tooltip is shown for this element
		 * 
		 * @see AbstractTooltip
		 * @see DefaultTooltipRenderer
		 */
		public function tooltipDelay() : Number
		{
			return m_tooltipDelay;
		}
		/**
		 * Takes a delay in milliseconds after which a tooltip is shown for this 
		 * element if the user hovers over it.
		 * 
		 * @param delay The delay after which a tooltip is shown for this element
		 * 
		 * @see AbstractTooltip
		 * @see DefaultTooltipRenderer
		 */
		public function setTooltipDelay(delay:Number) : void
		{
			m_tooltipDelay = delay;
		}
		/**
		 * Returns the id of the tooltip renderer used to render the tooltip for 
		 * this element.
		 * 
		 * This method is mostly used internally by the built in tooltip rendering 
		 * facilities.
		 * 
		 * @return The string id of the tooltip renderer associated with this 
		 * element
		 * 
		 * @see AbstractTooltip
		 * @see DefaultTooltipRenderer
		 * @see UIRendererFactory
		 */
		public function tooltipRenderer() : String
		{
			return m_tooltipRenderer;
		}
		/**
		 * Takes an id that identifies the tooltip renderer to be used to render 
		 * the tooltip for this element.
		 * 
		 * @param renderer The string id of the tooltip renderer associated with 
		 * this element
		 * 
		 * @see AbstractTooltip
		 * @see DefaultTooltipRenderer
		 * @see UIRendererFactory
		 */
		public function setTooltipRenderer(renderer:String) : void
		{
			m_tooltipRenderer = renderer;
		}
		
		/**
		 * Forces the UIObject to be redrawn immediately after validating all of 
		 * its invalid properties.
		 * 
		 * Use this method if you need valid values for the elements properties to 
		 * calculate some other values without waiting a frame for the properties 
		 * to be calculated.
		 * 
		 * <b>Note:</b> Use this method carefully as using it might severely impede 
		 * your applications performance.
		 */
		public function forceRedraw() : void
		{
			//TODO: turn into an exception for as3. Alternatively, consider this
			//code:
			/*
			var validatableElement : UIObject = this;
			while(validatableElement.m_parentElement && 
				validatableElement.m_parentElement.m_isInvalidated)
			{
				validatableElement = validatableElement.m_parentElement;
			}
			validatableElement.validateElement(true);
			*/
			var validatableElement : UIObject = this;
			while(validatableElement.m_parentElement && 
				validatableElement.m_parentElement != validatableElement)
			{
				validatableElement = validatableElement.m_parentElement;
				if (validatableElement.m_isInvalidated)
				{
					log('w Be ye warned: The element you are calling ' + 
					'forceRedraw on has invalid ascendants. This might cause ' + 
					'styling and all sorts of other things not to work as ' + 
					'expected. Consider calling m_rootElement.forceRedraw ' + 
					'instead.\nAfflicted element: ' + this + 
					'\ninvalid parent: ' + validatableElement);
					break;
				}
			}
			m_rootElement.markChildAsValid(this);
			validateElement(true);
		}	
		/**
		 * shows the UIObject.
		 * 
		 * This method is mainly here to enable derived classes to implement more 
		 * complex transitions that can be called using a uniform interface.
		 */
		public function show(...args) : void
		{
			setVisibility(true);
			show_complete();
		}
		/**
		 * hides the UIObject.
		 * 
		 * This method is mainly here to enable views to implement more complex 
		 * transitions that can be called using a uniform interface.
		 */
		public function hide(...args) : void
		{
			hide_complete();
		}
		/**
		 * Removes the element from its parents displayList.
		 * <p>
		 * Override this method or subscribe to the event <code>DisplayEvent.REMOVE
		 * </code> if you need to do cleanup once the element gets removed.
		 * This is advisable if you use intervals or external resources that should 
		 * be released once the element gets removed.
		 */
		public function remove(...args) : void
		{
			m_parentElement.unregisterChildView(this);
		}
		
		/**
		 * returns a point for this views position relative to the given context.
		 * 
		 * @param context The UIObject to resolve the elements position in relation 
		 * to.
		 * 
		 * @return The elements position relative to the given context.
		 */
		public function getPositionRelativeToContext(context:UIObject) : Point
		{
			return getPositionRelativeToDisplayObject(context.m_contentDisplay);
		}
		/**
		 * returns a point for this views position relative to the given context.
		 * 
		 * @param context The MovieClip to resolve the elements position in 
		 * relation to.
		 * 
		 * @return The elements position relative to the given context.
		 */
		public function getPositionRelativeToDisplayObject(
			displayObject : DisplayObject) : Point
		{
			var pos:Point = new Point(x, y);
			pos = parent.localToGlobal(pos);
			pos = displayObject.globalToLocal(pos);
			return pos;
		}
		
		/**
		 * sets the elements visibility without executing any transitions that 
		 * might be defined in the elements <code>hide</code> and <code>show</code> 
		 * methods.
		 * 
		 * @param visibility Boolean specifying if the element should be visible or not
		 */
		public function setVisibility(visibility : Boolean) : void
		{
			m_visible = visibility;
			if (!m_firstDraw)
			{
				visible = visibility;
			}
			dispatchEvent(new DisplayEvent(DisplayEvent.VISIBLE_CHANGED));
		}
		/**
		 * Returns the elements visibility
		 * 
		 * @return Boolean specifying if the element is visible or not
		 */
		public function visibility() : Boolean
		{
			return m_visible;
		}
		
		/**
		 * Returns the inversion of the elements visibility
		 * 
		 * @return Boolean specifying if the element is hidden or not
		 */
		public function isHidden() : Boolean
		{
			return !visibility();
		}
		
		/**
		 * Returns true if the element is rendered.
		 * <p>
		 * Right now, the only circumstance under which this method returns false is if the element 
		 * has the CSS property display: none applied to it, causing all validation of the element 
		 * itself and its children to be stopped right after style calculation.
		 * <p>
		 * If this value is false, all other values that depend on the element being valid might be 
		 * outdated or not even set at all.
		 * 
		 * @return A boolean indicating if the element is rendered to the screen or not
		 */
		public function isRendered() : Boolean
		{
			return m_isRendered;
		}
		
		/**
		 * Returns the actual display state of the element taking the visibility of its ancestors 
		 * in the display list into account.
		 * 
		 * @return Boolean specifying if the element is visible on the screen
		 */
		public function hasHiddenAncestors() : Boolean
		{
			if (!stage)
			{
				return true;
			}
			var ancestor : UIObject = this;
			while (ancestor.m_parentElement != ancestor)
			{
				ancestor = ancestor.m_parentElement;
				if (!ancestor.visibility())
				{
					return true;
				}
			}
			return false;
		}
		
		public function isOffScreen() : Boolean
		{
			if (!stage)
			{
				return true;
			}
			var isVisible : Boolean = visibility() && !hasHiddenAncestors();
			if (!isVisible)
			{
				return true;
			}
			
			var bounds : Rectangle = getBounds(stage);
			return !(bounds.right > 0 || bounds.left < stage.stageWidth || 
				bounds.bottom > 0 || bounds.top < stage.stageHeight);
		}
		
		/**
		 * Marks the element as invalid so that it gets validated during the next validation cycle.
		 */
		public function invalidate() : void
		{
			//TODO: check if we need this:
			if (!stage)
			{
				//we don't validate without a display
				m_isInvalidated = true;
				return;
			}
			if ((!m_parentElement || !m_parentElement.m_isInvalidated) && 
				!m_isInvalidated)
			{
				m_rootElement.markChildAsInvalid(this);
			}
			m_isInvalidated = true;
		}
		
		/**
		 * Returns all descentant elements that have the supplied tag name
		 * 
		 * @param tagName The CSS tag name to match descendant elements against
		 * @return An Array conaining all matching elements
		 */
		public function getElementsByTagName(tagName:String) : Array
		{	
			tagName = tagName.toLowerCase();
			
			var len:int = m_children.length;
			var elements:Array = [];
			var subElements:Array;
			
			for (var i : int = 0; i < len; i++)
			{
				var childView : UIObject = m_children[i] as UIObject;
				if (childView.m_elementType.toLowerCase() == tagName)
				{
					elements.push(childView);
				}
				subElements = childView.getElementsByTagName(tagName);
				if (subElements.length)
				{
					elements = elements.concat(subElements);
				}
			}		
			return elements;
		}
		
		/**
		 * Adds a display object Filter to the element
		 * <p>
		 * UIObject keeps an internal copy of the filters Array, allowing for duplicate checking.
		 * <p>
		 * This means that you can't add the same Filter multiple times.
		 * 
		 * @param filter The Filter to add to the element
		 * @see #removeFilter()
		 */
		public function addFilter(filter : Object) : void
		{
			if (!m_filters)
			{
				m_filters = [];
			}
			if (m_filters.indexOf(filter) != -1)
			{
				return;
			}
			m_filters.push(filter);
			m_contentDisplay.filters = m_filters;
		}
		
		/**
		 * Removes a display object Filter from the element
		 * <p>
		 * UIObject keeps an internal copy of the filters Array, allowing for identity comparison 
		 * of Filters, as opposed to the internal Filter handling of DisplayObject.
		 * <p>
		 * This means that it's possible to remove a Filter by supplying the original instance that 
		 * was added with addFilter().
		 * 
		 * @param filter The Filter to add to the element
		 * @see #addFilter()
		 */
		public function removeFilter(filter : Object) : void
		{
			if (!m_filters)
			{
				return;
			}
			var filterIndex : int = m_filters.indexOf(filter);
			if (filterIndex != -1)
			{
				m_filters.splice(filterIndex, 1);
				m_contentDisplay.filters = m_filters;
			}
		}
		
		/**
		 * Removes all currently applyed Filters from the element
		 */
		public function clearFilters() : void
		{
			m_contentDisplay.filters = null;
		}
		
		/**
		 * Returns the elements path from the root element in a similar fashion to how 
		 * MovieClip::toString worked in AS2.
		 */
		public override function toString() : String
		{
			if (!root || this == m_rootElement)
			{
				return name;
			}
			return m_parentElement.toString() + '.' + name;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function initialize() : void
		{
			m_initialized = true;
			name = m_elementType + '_' + g_elementIDCounter++;
			m_delayedMethods = [];
			createDisplayClips();
			m_firstDraw = true;
			m_tabIndex = 0;
			visible = false;
			m_keyOrder = [];
			createChildren();
		}
		
		/**
		 * creates all clips needed to display the UIObjects' content
		 */
		protected function createDisplayClips() : void
		{
			m_contentDisplay = new Sprite();
			m_contentDisplay.name = 'content';
			super.addChild(m_contentDisplay);
		}
		
		protected function validateElement(
			forceValidation:Boolean = false, validateStyles:Boolean = false) : void
		{
			if (((m_parentElement && m_parentElement != this && 
				m_parentElement.m_isInvalidated) || 
				!m_isInvalidated) && !forceValidation /*|| !m_display._url*/)
			{
				//TODO: restore ability to ignore validation after the event has 
				//been removed, or make sure that validation doesn't occur in that case
				return;
			}
			
			m_isInvalidated = false;
			m_isValidating = true;
			
			validateBeforeChildren();
			if (!m_isRendered)
			{
				visible = false;
				return;
			}
			validateChildren();
			validateAfterChildren();
			
			calculateKeyLoop();
			
			if (m_firstDraw)
			{
				visible = m_visible;
				m_firstDraw = false;
				//call hook method:
				beforeFirstDraw();
			}
			draw();
			
			finishValidation();
			
			dispatchEvent(new DisplayEvent(DisplayEvent.VALIDATION_COMPLETE));
		}
		protected function validateChildren() : void
		{
			var childCount : int = m_children.length;
			for (var i : int = 0; i < childCount; i++)
			{
				validateChild(UIObject(m_children[i]));
			}
		}
		protected function validateChild(child:UIObject) : void
		{
			child.validateElement(true);
		}
		
		protected function unregisterChildView(child:UIObject) : void
		{
			if (child.parent == this)
			{
				m_children.splice(m_children.indexOf(child), 1);
				removeChild(child);
				child.dispatchEvent(
					new DisplayEvent(DisplayEvent.REMOVED_FROM_DOCUMENT, true));
				invalidate();
			}
		}
		
		protected function show_complete(event : Event = null) : void
		{
			dispatchEvent(new DisplayEvent(DisplayEvent.SHOW_COMPLETE));
		}
		protected function hide_complete(event : Event = null) : void
		{
			setVisibility(false);
			dispatchEvent(new DisplayEvent(DisplayEvent.HIDE_COMPLETE));
		}
		
		
		protected function calculateKeyLoop() : void
		{
			if (m_children.length == 0)
			{
				return;
			}
			var len : int = m_children.length;
			var i : int;
			var keyOrder : Array = m_children.concat();
			keyOrder.sortOn(["tabIndex", "y", "x"], Array.NUMERIC);
			
			var currKey : UIObject;
			var nextKey : UIObject;
			
			for (i = 0; i < len; i++)
			{
				currKey = UIObject(keyOrder[i]);
				
				if (i < len - 1)
				{
					nextKey = UIObject(keyOrder[i + 1]);
				}
				else
				{
					nextKey = m_parentElement == this ? this : m_nextKeyView;
				}
				currKey.setNextKeyView(nextKey);
			}
			
			m_firstKeyChild = keyOrder[0];
			m_lastKeyChild = keyOrder[len - 1];
			m_firstKeyChild.setPreviousKeyView(this);
			m_keyOrder = keyOrder;
		}
		
		internal function validation_execute() : void
		{
			validateElement();
			for each (var method : Function in m_delayedMethods)
			{
				method();
			}
			m_delayedMethods = [];
		}
		
		
		/***************************************************************************
		*							empty hook methods							   *
		***************************************************************************/
		/**
		 * Hook method executed during initialization of the element.
		 * 
		 * Override this method in derived classes to create all the elements 
		 * child elements.
		 */
		protected function createChildren() : void
		{
		}
		
		/**
		 * Hook method, executed before the UIObjects children get validated and 
		 * drawn.
		 */
		protected function validateBeforeChildren() : void
		{
		}
		/**
		 * Hook method, executed after the UIObjects children have been validated 
		 * and drawn.
		 */
		protected function validateAfterChildren() : void
		{
		}
		
		/**
		 * Hook method that gets called after all parents have been intialized and
		 * the UIObject is ready to be drawn for the first.
		 * Should be overridden by implementing classes wanting to do intialization 
		 * that depends on the initialization of parents to be complete. 
		 */
		protected function beforeFirstDraw() : void
		{
		}
		
		/**
		 * Hook method that gets called after all validation has completed and 
		 * the element is ready to be drawn.
		 * 
		 * Override this method if you want to customize the elements visual 
		 * appearance.
		 */
		protected function draw() : void
		{
		}
		
		/**
		 * Hook method that gets called after all validation has completed and 
		 * the element has been drawn.
		 * 
		 * Override this method if you need to execute cleanup or reset invalidation 
		 * markers after validation has completed.
		 */
		protected function finishValidation() : void
		{
			m_isValidating = false;
		}
	}
}