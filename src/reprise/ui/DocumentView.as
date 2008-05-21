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
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import reprise.core.UIRendererFactory;
	import reprise.css.CSS;
	import reprise.css.CSSDeclaration;
	import reprise.css.CSSProperty;
	import reprise.data.collection.HashMap;
	import reprise.i18n.II18NService;
	import reprise.services.tracking.ITrackingService;
	
	public class DocumentView extends UIComponent
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
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
//			initialize();
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
			stage.addEventListener(Event.RENDER, stage_render);
		}
		
		protected override function initDefaultStyles() : void
		{
			m_elementDefaultStyles.setStyle('frameRate', '24');
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
		}
		protected override function resolveRelativeStyles(styles:CSSDeclaration) : void
		{
			var widthStyle : CSSProperty = m_complexStyles.getStyle('width');
			var heightStyle : CSSProperty = m_complexStyles.getStyle('height');
			if (widthStyle.isRelativeValue())
			{
				m_widthIsRelative = true;
				m_width = m_currentStyles.width = 
					Math.round(widthStyle.resolveRelativeValueTo(stage.stageWidth));
			}
			else
			{
				m_widthIsRelative = false;
				m_width = Number(widthStyle.valueOf());
			}
			if (heightStyle.isRelativeValue())
			{
				m_heightIsRelative = true;
				m_height = m_currentStyles.height = 
					Math.round(heightStyle.resolveRelativeValueTo(stage.stageHeight));
			}
			else
			{
				m_heightIsRelative = false;
				m_height = Number(heightStyle.valueOf());
			}
		}
		
		protected override function applyOutOfFlowChildPositions() : void
		{
			super.applyOutOfFlowChildPositions();
			y = m_marginTop;
			x = m_marginLeft;
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
//			trace('validation took ' + (getTimer() - t1) + 'ms');
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
		
		protected function stage_resize(event : Event) : void
		{
			if ((m_widthIsRelative && m_width != stage.stageWidth) || 
				(m_heightIsRelative && m_height != stage.stageHeight))
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
	}
}