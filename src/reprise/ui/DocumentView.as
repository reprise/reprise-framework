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
	import reprise.core.UIRendererFactory;
	import reprise.css.CSS;
	import reprise.css.CSSDeclaration;
	import reprise.data.collection.HashMap;
	import reprise.events.DebugEvent;
	import reprise.i18n.II18NService;
	import reprise.services.tracking.ITrackingService;
	
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
		
		protected var m_i18nService : II18NService;
		protected var m_trackingService : ITrackingService;
		
		protected var m_invalidChildren : Array;
		
		protected var m_widthIsRelative : Boolean;
		protected var m_heightIsRelative : Boolean;
		
		protected var m_stageInvalidationTimeout : int;
		
		protected var m_focus:UIObject;
		
		protected var m_debuggingMode : Boolean;
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
		
		public override function setParent(parent:UIObject) : UIObject
		{
			super.setParent(parent);
			//TODO: remove these after making sure that that's ok (it really should be)
			m_rootElement = this;
			m_containingBlock = this;
			return this;
		}
		
		public function setI18NService(i18nService : II18NService) : void
		{
			m_i18nService = i18nService;
		}
		
		public function setTrackingService(
			trackingService : ITrackingService) : void
		{
			m_trackingService = trackingService;
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
			m_stylesInvalidated = true;
			startWatchingStylesheets();
			invalidate();
		}
		/**
		 * returns the views' styleSheet
		 */
		public function get styleSheet() : CSS
		{
			if (m_styleSheet)
			{
				return m_styleSheet;
			}
			return g_defaultStyleSheet;
		}
		
		public function registerElementID(id:String, element:UIComponent) : void
		{
			m_elementsById.setObjectForKey(element, id);
		}
		public function removeElementID(id:String) : void
		{
			m_elementsById.removeObjectForKey(id);
		}
		
		public function getElementById(id:String) : UIComponent
		{
			return UIComponent(m_elementsById.objectForKey(id));
		}
		
		public function getI18N(key : String) : String
		{
			if (!m_i18nService)
			{
				return key;
			}
			var result : String;
			if (m_i18nService.keyExists(key))
			{
				result = m_i18nService.getStringByKey(key);
				if (typeof result == "string")
				{
					result = result.split('\r\n').join('\n').split('\r').join('\n');
				}
			}
			if (result == null)
			{
				return key;
			}
			return result;
		}
		
		public function getI18NFlag(key : String) : Boolean
		{
			if (!m_i18nService)
			{
				return false;
			}
			if (m_i18nService.keyExists(key))
			{
				return m_i18nService.getBoolByKey(key) || false;
			}
			return false;
		}
		
		public function getI18NObject(key : String) : Object
		{
			if (!m_i18nService)
			{
				return null;
			}
			if (m_i18nService.keyExists(key))
			{
				return m_i18nService.getGenericContentByKey(key);
			}
			return null;
		}
		
		public function getTrack(trackingId : String) : void
		{
			m_trackingService.track(trackingId);
		}
		public override function hasHiddenAncestors() : Boolean
		{
			return false;
		}
		
		public function markChildAsInvalid(child : UIObject) : void
		{
			//TODO: check if child.toString() is ok to use
			m_invalidChildren.push({element : child, path : child.toString()});
			stage.invalidate();
		}
		
		public function markChildAsValid(child : UIObject) : void
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
		
		public function setFocusedElement(element : UIObject, method : String) : Boolean
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
			stage.frameRate = m_currentStyles.frameRate;
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
//					trace("d skip validation of: " + path);
					continue;
				}
//				trace("d validate " + path);
				lastValidatedPath = path;
				var element : UIObject = UIObject(sortedElements[i].element);
				element.validation_execute();
			}
			log('d validation of ' + m_validatedElementsCount + 
				' elements took ' + (getTimer() - t1) + 'ms');
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
			
			stage.removeEventListener(MouseEvent.MOUSE_OVER, debugging_mouseOver, true);
		}
		protected function debugMarkElement(element : UIComponent) : void
		{
			var output : String = 'Element: ' + element + '\n';
			
			var display : Sprite = element.valueForKey('m_contentDisplay');
			var position : Point = new Point(display.x, display.y);
			position = element.localToGlobal(position);
			m_debugInterface.x = position.x;
			m_debugInterface.y = position.y;
			
			m_debugInterface.graphics.clear();
			m_debugInterface.graphics.lineStyle(1, 0xffff);
			
			var boxWidth : Number = element.borderBoxWidth;
			var boxHeight : Number = element.borderBoxHeight;
			output += 'Border Box: width ' + boxWidth + ', height ' + boxHeight + '\n';
			m_debugInterface.graphics.drawRect(-element.style.borderLeftWidth, 
				-element.style.borderTopWidth, boxWidth, boxHeight);
			
			boxWidth -= element.style.borderLeftWidth;
			boxWidth -= element.style.borderRightWidth;
			boxHeight -= element.style.borderTopWidth;
			boxHeight -= element.style.borderBottomWidth;
			output += 'Padding Box: width ' + boxWidth + ', height ' + boxHeight + '\n';
			m_debugInterface.graphics.endFill();
			m_debugInterface.graphics.drawRect(0, 0, boxWidth, boxHeight);
			
			boxWidth -= element.style.paddingLeft;
			boxWidth -= element.style.paddingRight;
			boxHeight -= element.style.paddingTop;
			boxHeight -= element.style.paddingBottom;
			output += 'Content Box: width ' + boxWidth + ', height ' + boxHeight + '\n';
			m_debugInterface.graphics.endFill();
			m_debugInterface.graphics.drawRect(element.style.paddingLeft, 
				element.style.paddingTop, boxWidth, boxHeight);
			
			log(output);
		}
		
		protected function stage_resize(event : Event) : void
		{
			if ((m_widthIsRelative && m_contentBoxWidth != stage.stageWidth) || 
				(m_heightIsRelative && m_contentBoxHeight != stage.stageHeight))
			{
				stageDimensionsChanged = true;
				m_stylesInvalidated = true;
				invalidate();
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
				return;
			}
			debugMarkElement(element);
		}
	}
}