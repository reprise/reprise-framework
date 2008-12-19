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
	import reprise.css.ComputedStyles;	
	
	import flash.geom.Rectangle;	
	
	import reprise.core.ApplicationContext;
	import reprise.core.UIRendererFactory;
	import reprise.core.reprise;
	import reprise.css.CSS;
	import reprise.css.CSSDeclaration;
	import reprise.data.collection.HashMap;
	import reprise.events.DebugEvent;
	import reprise.events.DisplayEvent;
	
	import com.nesium.events.FileMonitorEvent;
	import com.nesium.logging.FileMonitor;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	use namespace reprise;

	public class DocumentView extends UIComponent
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const FOCUS_METHOD_KEYBOARD : String = 'keyboard';
		public static const FOCUS_METHOD_MOUSE : String = 'mouse';
		
		public static var className : String = "body";
		
		public var stageDimensionsChanged : Boolean;
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_defaultStyleSheet : CSS = new CSS();
		protected var m_styleSheet : CSS;
		protected var m_rendererFactory : UIRendererFactory;
	
		protected var m_elementsById : HashMap;
		protected var m_elementsByTagName : HashMap;
		
		protected var m_appContext : ApplicationContext;
		
		protected var m_invalidChildren : Array;
		
		protected var m_widthIsRelative : Boolean;
		protected var m_heightIsRelative : Boolean;
		
		protected var m_stageInvalidationTimeout : int;
		
		protected var m_focus:UIObject;
		protected var m_lastTabPress : int;
		
		protected var m_debuggingMode : Boolean;
		protected var m_currentDebugElement : UIComponent;
		protected var m_debugInterface : Sprite;
		protected var m_validatedElementsCount : int;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function DocumentView()
		{
			m_rendererFactory = new UIRendererFactory();
			m_elementsById = new HashMap();
		}
		
		/**
		 * Sets the ApplicationContext for the document structure.
		 * <p>
		 * The ApplicationContext has to be set for the document structure to work because it 
		 * provides essential functionality such as the central resource loading queue.
		 * 
		 * @param appContext The AppicationContext to set
		 * @see ApplicationContext
		 */
		public function setApplicationContext(appContext : ApplicationContext) : void
		{
			m_appContext = appContext;
		}
		
		/**
		 * Returns the document structures ApplicationContext
		 * 
		 * @return The document structures ApplicationContext
		 * @see ApplicationContext
		 */
		public function applicationContext() : ApplicationContext
		{
			return m_appContext;
		}
		
		/**
		 * TODO: remove this override or turn it into a no-op. This should really be handled in a 
		 * cleaner way.
		 */
		public override function setParent(parent:UIObject) : UIObject
		{
			super.setParent(parent);
			//TODO: remove these after making sure that that's ok (it really should be)
			m_rootElement = this;
			m_containingBlock = this;
			return this;
		}
		
		/**
		 * sets the UIRendererFactory to use for this UIComponent structure.
		 */
		public function setUIRendererFactory(
			rendererFactory:UIRendererFactory) : UIComponent
		{
			m_rendererFactory = rendererFactory;
			return this;
		}
		/**
		 * returns the UIRendererFactory for this UIComponent structure
		 */
		public function uiRendererFactory() : UIRendererFactory
		{
			return m_rendererFactory;
		}
		
		/**
		 * initializes the UIComponent structure from the given xml structure, 
		 * creating child views as needed
		 */
		public function initFromXML(xml : XML) : DocumentView
		{
			parseXMLDefinition(xml);
			return this;
		}
		
		/**
		 * sets the styleSheet to use vor this UIComponent and its' children
		 */
		public function set styleSheet(stylesheet : CSS) : void
		{
			m_styleSheet = stylesheet;
			invalidateStyles();
			startWatchingStylesheets();
		}
		/**
		 * returns the stylesheet for this element structure
		 */
		public function get styleSheet() : CSS
		{
			if (m_styleSheet)
			{
				return m_styleSheet;
			}
			return g_defaultStyleSheet;
		}
		
		/**
		 * Returns the element matching the given CSS ID.
		 * 
		 * @param className The CSS ID to match descendant elements against
		 * @return The element matching the given CSS ID or null
		 */
		public function getElementById(id:String) : UIComponent
		{
			return UIComponent(m_elementsById.objectForKey(id));
		}
		
		/**
		 * @inheritDoc
		 */
		public override function hasHiddenAncestors() : Boolean
		{
			return false;
		}
		
		
		/***************************************************************************
		*							reprise methods								   *
		***************************************************************************/
		reprise function registerElementID(id:String, element:UIComponent) : void
		{
			m_elementsById.setObjectForKey(element, id);
		}
		reprise function removeElementID(id:String) : void
		{
			m_elementsById.removeObjectForKey(id);
		}
		
		reprise function markChildAsInvalid(child : UIObject) : void
		{
			//TODO: check if child.toString() is ok to use
			m_invalidChildren.push({element : child, path : child.toString()});
			stage.invalidate();
		}
		
		reprise function markChildAsValid(child : UIObject) : void
		{
			var path : String = child.toString();
			var i : int = m_invalidChildren.length;
			while (i--)
			{
				if (m_invalidChildren[i].path.indexOf(path) == 0)
				{
					m_invalidChildren.splice(i, 1);
				}
			}
		}
		
		reprise function setFocusedElement(element : UIObject, method : String) : Boolean
		{
			if (m_focus && m_focus == element)
			{
				return false;
			}
			if (m_focus)
			{
				m_focus.setFocus(false, method);
			}
			m_focus = element;
			stage.focus = element;
			if (element)
			{
				element.setFocus(true, method);
			}
			return true;
		}
		
		
		/***************************************************************************
		*							internal methods							   *
		***************************************************************************/
		internal function increaseValidatedElementsCount() : void
		{
			m_validatedElementsCount++;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function initialize() : void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			m_rootElement = this;
			m_containingBlock = this;
			m_invalidChildren = [];
			stage.addEventListener(Event.RESIZE, stage_resize);
			super.initialize();
			stage.stageFocusRect = false;
			stage.addEventListener(Event.RENDER, stage_render);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, key_down);
			stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, stage_keyFocusChange);
			stage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, stage_mouseFocusChange);
			stage.focus = this;
		}
		
		protected override function initDefaultStyles() : void
		{
			m_elementDefaultStyles.setStyle('width', '100%');
			m_elementDefaultStyles.setStyle('height', '100%');
			m_elementDefaultStyles.setStyle('padding', '0');
			m_elementDefaultStyles.setStyle('margin', '0');
			m_elementDefaultStyles.setStyle('position', 'absolute');
			m_elementDefaultStyles.setStyle('fontFamily', '_sans');
			m_elementDefaultStyles.setStyle('fontSize', '12px');
			m_elementDefaultStyles.setStyle('frameRate', stage.frameRate.toString());
		}
		protected override function validateElement(
			forceValidation:Boolean = false, validateStyles:Boolean = false) : void
		{
			super.validateElement(forceValidation, validateStyles);
			stageDimensionsChanged = false;
		}

		protected override function applyStyles() : void
		{
			super.applyStyles();
			if (m_currentStyles.frameRate)
			{
				stage.frameRate = m_currentStyles.frameRate;
			}
			m_heightIsRelative = m_complexStyles.getStyle('height').isRelativeValue();
			m_widthIsRelative = m_complexStyles.getStyle('width').isRelativeValue();
		}
		protected override function resolveRelativeStyles(styles:CSSDeclaration, 
			parentW:Number = -1, parentH:Number = -1) : void
		{
			super.resolveRelativeStyles(styles, stage.stageWidth, stage.stageHeight);
		}
		
		protected override function applyOutOfFlowChildPositions() : void
		{
			super.applyOutOfFlowChildPositions();
			y = m_currentStyles.marginTop;
			x = m_currentStyles.marginLeft;
		}
		
		protected override function refreshSelectorPath() : void
		{
			var oldPath : String = m_selectorPath;
			m_selectorPath = '';
			super.refreshSelectorPath();
			if (m_selectorPath == oldPath)
			{
				m_selectorPathChanged = false;
			}
		}
		
		protected function validateElements() : void
		{
			//TODO: verify this validation scheme
			var t1 : int = getTimer();
			m_validatedElementsCount = 0;
			if (m_invalidChildren.length == 0)
			{
				return;
			}
			var lastValidatedPath : String;
			var sortedElements : Array = m_invalidChildren.sortOn(
				'path', Array.DESCENDING);
			m_invalidChildren = [];
			for(var i : Number = sortedElements.length; i--;)
			{
				var path : String = sortedElements[i].path;
				if (path.indexOf(lastValidatedPath) == 0)
				{
//					log("d skip validation of: " + path);
					continue;
				}
//				log("d validate " + path);
				lastValidatedPath = path + '.';
				var element : UIObject = UIObject(sortedElements[i].element);
				element.validation_execute();
			}
			log('d validation of ' + m_validatedElementsCount + 
				' elements took ' + (getTimer() - t1) + 'ms');
			dispatchEvent(new DisplayEvent(DisplayEvent.DOCUMENT_VALIDATION_COMPLETE));
			//validate elements that have been marked as invalid during validation
			if (m_invalidChildren.length)
			{
				m_stageInvalidationTimeout = setTimeout(invalidateStage, 5);
			}
		}
		protected function invalidateStage() : void
		{
			clearTimeout(m_stageInvalidationTimeout);
			stage.invalidate();
		}
		protected function toggleDebuggingMode() : void
		{
			if (m_debuggingMode)
			{
				deactivateDebuggingMode();
			}
			else
			{
				activateDebuggingMode();
			}
		}
		protected function activateDebuggingMode() : void
		{
			if (m_debuggingMode)
			{
				return;
			}
			m_debuggingMode = true;
			
			m_debugInterface = new Sprite();
			m_debugInterface.mouseEnabled = false;
			addChild(m_debugInterface);
			
			stage.addEventListener(MouseEvent.MOUSE_OVER, debugging_mouseOver, true, 100);
		}
		protected function deactivateDebuggingMode() : void
		{
			if (!m_debuggingMode)
			{
				return;
			}
			m_debuggingMode = false;
			
			removeChild(m_debugInterface);
			m_debugInterface = null;
			m_currentDebugElement = null;
			
			stage.removeEventListener(MouseEvent.MOUSE_OVER, debugging_mouseOver, true);
		}
		protected function debugMarkElement(element : UIComponent) : void
		{
			m_currentDebugElement = element;
			var style : ComputedStyles = element.style;
			var output : String = '\nElement: ' + element + 
				'\nSelectorpath: ' + element.selectorPath.split('@').join('') + '\n' + 
				'position: ' + (style.position || 'static') + ', ';
			output += 'top: ' + style.top + 'px, right: ' + style.right + 
				'px, bottom: ' + style.bottom + 'px, left: ' + style.left + 'px\n';
			output += 'margin: ' + style.marginTop + 'px ' + style.marginRight + 'px ' + 
				style.marginBottom + 'px ' + style.marginLeft + 'px\n';
			
			var position : Point = element.getPositionRelativeToDisplayObject(this);
			m_debugInterface.x = position.x;
			m_debugInterface.y = position.y;
			
			m_debugInterface.graphics.clear();
			m_debugInterface.graphics.lineStyle(1, 0xffff);
			
			var boxWidth : Number = element.borderBoxWidth;
			var boxHeight : Number = element.borderBoxHeight;
			output += 'Border Box: width ' + boxWidth + ', height ' + boxHeight + '\n';
			m_debugInterface.graphics.drawRect(-style.borderLeftWidth, 
				-style.borderTopWidth, boxWidth, boxHeight);
			
			boxWidth -= style.borderLeftWidth;
			boxWidth -= style.borderRightWidth;
			boxHeight -= style.borderTopWidth;
			boxHeight -= style.borderBottomWidth;
			output += 'Padding Box: width ' + boxWidth + ', height ' + boxHeight + '\n';
			m_debugInterface.graphics.endFill();
			m_debugInterface.graphics.drawRect(0, 0, boxWidth, boxHeight);
			
			boxWidth -= style.paddingLeft;
			boxWidth -= style.paddingRight;
			boxHeight -= style.paddingTop;
			boxHeight -= style.paddingBottom;
			output += 'Content Box: width ' + boxWidth + ', height ' + boxHeight + '\n';
			m_debugInterface.graphics.endFill();
			m_debugInterface.graphics.drawRect(style.paddingLeft, 
				style.paddingTop, boxWidth, boxHeight);
			
			log(output);
		}
		
		protected function stage_resize(event : Event) : void
		{
			if ((m_widthIsRelative && m_contentBoxWidth != stage.stageWidth) || 
				(m_heightIsRelative && m_contentBoxHeight != stage.stageHeight))
			{
				stageDimensionsChanged = true;
				invalidateStyles();
			}
		}
		
		protected function stage_render(event : Event) : void
		{
			validateElements();
		}
		
		protected function stage_keyFocusChange(e:FocusEvent):void
		{
			if (e.keyCode == Keyboard.TAB && !e.isDefaultPrevented())
			{
				if (getTimer() - m_lastTabPress < 15)
				{
					e.preventDefault();
					return;
				}
				m_lastTabPress = getTimer();
				var focusView:UIObject;
				if (e.shiftKey)
				{
					focusView = m_focus != null 
						? m_focus.previousValidKeyView() 
						: previousValidKeyView();
				}
				else
				{
					focusView = m_focus != null 
						? m_focus.nextValidKeyView() 
						: nextValidKeyView();
				}
				if (setFocusedElement(focusView, FOCUS_METHOD_KEYBOARD))
				{
		            e.preventDefault();
				}
	        }
		}
		protected function stage_mouseFocusChange(event : FocusEvent) : void
		{
			var element : DisplayObject = DisplayObject(event.relatedObject);
			while (element && !(element is UIObject))
			{
				element = element.parent;
			}
			if (setFocusedElement(element as UIObject, FOCUS_METHOD_MOUSE))
			{
				event.preventDefault();
			}
		}
		
		protected function key_down(event : KeyboardEvent) : void
		{
			if (event.shiftKey && event.ctrlKey)
			{
				if (event.keyCode == 4) //'d'
				{
					toggleDebuggingMode();
					return;
				}
				if (event.keyCode == 19 && m_currentDebugElement) //'s'
				{
					log('Complex styles:\n' + m_currentDebugElement.valueForKey('m_complexStyles'));
					return;
				}
				if (event.keyCode == 18) //'r'
				{
					reloadStyles();
					return;
				}
				if (event.keyCode == 23) //'w'
				{
					startWatchingStylesheets();
					return;
				}
			}
		}

		protected function startWatchingStylesheets() : void
		{
			FileMonitor.instance().removeEventListener(
				FileMonitorEvent.FILE_CHANGED, file_changed);
			var stylesheets : Array = m_styleSheet.stylesheetURLs();
			var containsLocalFiles : Boolean;
			for each (var url : String in stylesheets)
			{
				if (url.indexOf('file://') == 0)
				{
					FileMonitor.instance().startMonitoringFile(url.substr(7));
					containsLocalFiles = true;
				}
			}
			if (containsLocalFiles)
			{
				log('d start watching stylesheets');
				FileMonitor.instance().addEventListener(
					FileMonitorEvent.FILE_CHANGED, file_changed);
			}
		}

		protected function file_changed(event : FileMonitorEvent):void
		{
			reloadStyles();
		}
		
		protected function reloadStyles() : void
		{
			//TODO: make sure that CSS variables are treated correctly when reloading
			m_styleSheet.addEventListener(Event.COMPLETE, styleSheet_complete);
			m_styleSheet.reset();
			m_styleSheet.execute();
		}
		
		protected function styleSheet_complete(event : Event) : void
		{
			m_styleSheet.removeEventListener(Event.COMPLETE, styleSheet_complete);
			dispatchEvent(new DebugEvent(DebugEvent.WILL_RESET_STYLES));
			resetStyles();
			dispatchEvent(new DebugEvent(DebugEvent.DID_RESET_STYLES));
		}

		protected function debugging_mouseOver(event : MouseEvent) : void
		{
			var parent : DisplayObject = DisplayObject(event.target);
			var element : UIComponent;
			while (parent)
			{
				if (parent is UIComponent)
				{
					element = UIComponent(parent);
					break;
				}
				parent = parent.parent;
			}
			if (!element)
			{
				removeChild(m_debugInterface);
				m_debugInterface = null;
				m_currentDebugElement = null;
				return;
			}
			debugMarkElement(element);
		}
	}
}