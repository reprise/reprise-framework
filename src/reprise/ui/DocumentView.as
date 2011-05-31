/*
* Copyright (c) 2006-2011 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.ui
{
	import reprise.core.ApplicationContext;
	import reprise.core.FocusManager;
	import reprise.core.TooltipManager;
	import reprise.core.UIRendererFactory;
	import reprise.core.reprise;
	import reprise.css.CSS;
	import reprise.css.CSSDeclaration;
	import reprise.css.CSSParsingHelper;
	import reprise.debug.DebugInterface;
	import reprise.events.DisplayEvent;
	import reprise.utils.DisplayListUtil;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.getTimer;
	
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
		protected static var g_totalValidationTime : int = 0;
		
		protected var m_styleSheet : CSS;
		protected var m_rendererFactory : UIRendererFactory;
	
		protected var m_elementsById : Object;
		
		protected var m_appContext : ApplicationContext;
		protected var m_focusManager : FocusManager;
		protected var m_tooltipContainer : Sprite;
		protected var m_tooltipManager : TooltipManager;
		
		protected var m_parentDocument : DocumentView;
		protected var m_baseURL : String = '';
		
		protected var m_validatedElementsCount : int;
		protected var m_currentFrameTime : int;
		protected var m_documentIsInvalidated : Boolean;
		protected var m_documentIsValidating : Boolean;

		protected var m_widthIsRelative : Boolean;
		protected var m_heightIsRelative : Boolean;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function DocumentView()
		{
			m_rendererFactory = new UIRendererFactory();
			m_elementsById = {};
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
		
		public function get parentDocument() : DocumentView
		{
			return m_parentDocument;
		}

		/**
		 * Returns the time that's used as the time for all timed actions executed in the 
		 * current frame.
		 * 
		 * This time is used to synchronize all frame actions.
		 * 
		 * @return The time to use for all times frame actions.
		 */
		public function frameTime() : int
		{
			return m_currentFrameTime;
		}

		override public function get stage() : Stage
		{
			if (realStage())
			{
				return realStage();
			}
			return m_parentDocument ? m_parentDocument.stage : null;
		}

		/**
		 * Returns the documents validation state
		 * 
		 * A return value of <code>true</code> indicates that the document is currently validating, 
		 * <code>false</code> indicates that it is not.
		 * 
		 * @return The documents validation state
		 */
		public function documentIsValidating() : Boolean
		{
			return m_documentIsValidating;
		}

		/**
		 * TODO: remove this override or turn it into a no-op. This should really be handled in a 
		 * cleaner way.
		 */
		public override function setParent(parent:UIObject) : UIObject
		{
			m_rootElement = this;
			
			if (parent == this)
			{
				m_parentDocument = null;
			}
			else
			{
				var container : UIObject = 
					DisplayListUtil.locateElementContainingDisplayObject(parent);
				if (container)
				{
					m_parentDocument = container.document;
				}
			}
			super.setParent(parent);
			//TODO: remove this after making sure that that's ok (it really should be)
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
		public function initFromXML(xml : XML, url : String = '') : DocumentView
		{
			if (url)
			{
				baseURL = url;
			}
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
			if (m_styleSheet)
			{
				DebugInterface.reprise::startWatchingStylesheets(this);
			}
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
		
		public function get baseURL() : String
		{
			return m_baseURL || '';
		}
		
		public function set baseURL(url : String) : void
		{
			m_baseURL = url || '';
		}
		
		public function resolveURL(url : String) : String
		{
			return CSSParsingHelper.resolvePathAgainstPath(url, m_baseURL);
		}
		
		/**
		 * Returns the element matching the given CSS ID.
		 * 
		 * @param className The CSS ID to match descendant elements against
		 * @return The element matching the given CSS ID or null
		 */
		public function getElementById(id:String) : UIComponent
		{
			return UIComponent(m_elementsById[id]);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function hasHiddenAncestors() : Boolean
		{
			return false;
		}

		override public function remove(...args : *) : void
		{
			if (parentDocument)
			{
				parentDocument.removeChild(this);
			}
			else if (m_parentElement && m_parentElement != this)
			{
				m_parentElement.removeChild(this);
			}
			if (parent)
			{
				parent.removeChild(this);
			}
		}

		public function validateDocument() : void
		{
			validateElements();
		}

		override public function toString() : String
		{
			return name;
		}

		
		/***************************************************************************
		*							reprise methods								   *
		***************************************************************************/
		reprise function registerElementID(id:String, element:UIComponent) : void
		{
			m_elementsById[id] = element;
		}
		reprise function removeElementID(id:String) : void
		{
			m_elementsById[id] && delete m_elementsById[id];
		}
		
		reprise function markChildAsInvalid(child : UIObject) : void
		{
			if (!m_documentIsInvalidated && stage != null)
			{
				m_documentIsInvalidated = true;
				addEventListener(Event.ENTER_FRAME, self_enterFrame, false, 0, true);
			}
		}
		
		reprise function setFocusedElement(element : UIObject, method : String) : Boolean
		{
			return m_focusManager.reprise::setFocusedElement(element, method);
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
			if (!m_baseURL)
			{
				var stageURL : String = stage.loaderInfo.url;
				m_baseURL = stageURL.substr(0, stageURL.lastIndexOf('/') + 1);
			}
			stage.addEventListener(Event.RESIZE, stage_resize, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, self_removedFromStage, false, 0, true);
			super.initialize();
			stage.stageFocusRect = false;
			m_focusManager = new FocusManager(this);
			if (!parentDocument)
			{
				m_tooltipManager = new TooltipManager(m_rootElement, m_tooltipContainer);
			}

			reprise::markChildAsInvalid(this);
			
			DebugInterface.addDocument(this);
		}

		override protected function createDisplayClips() : void
		{
			super.createDisplayClips();
			if (parentDocument)
			{
				return;
			}
			m_tooltipContainer = new Sprite();
			addChild(m_tooltipContainer);
		}

		override protected function addComponentToDisplayList(
			component : UIComponent, lower : Boolean) : void
		{
			if (component == this)
			{
				return;
			}
			super.addComponentToDisplayList(component, lower);
		}

		protected override function initDefaultStyles() : void
		{
			m_elementDefaultStyles.setStyle('width', '100%');
			m_elementDefaultStyles.setStyle('height', '100%');
			m_elementDefaultStyles.setStyle('padding', '0');
			m_elementDefaultStyles.setStyle('margin', '0');
			m_elementDefaultStyles.setStyle('boxSizing', 'border-box');
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
			parentW : int = -1, parentH : int = -1) : void
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
			removeEventListener(Event.ENTER_FRAME, self_enterFrame);

			if (!m_documentIsInvalidated)
			{
				return;
			}
			m_documentIsInvalidated = false;
			m_documentIsValidating = true;
			m_currentFrameTime = getTimer();
			m_validatedElementsCount = 0;

			if (m_isInvalidated)
			{
				validateElement();
			}
			else
			{
				validateChildren();
			}

			g_totalValidationTime += getTimer() - m_currentFrameTime;
			log('d validated ' + m_validatedElementsCount + 
				' elements in ' + (getTimer() - m_currentFrameTime) + 'ms. ' + 
				'Total validation time: ' + g_totalValidationTime);
			hasEventListener(DisplayEvent.DOCUMENT_VALIDATION_COMPLETE) &&
					dispatchEvent(new DisplayEvent(DisplayEvent.DOCUMENT_VALIDATION_COMPLETE));
			m_documentIsValidating = false;
			//validate elements that have been marked as invalid during validation
			if (m_documentIsInvalidated)
			{
				addEventListener(Event.ENTER_FRAME, self_enterFrame);
			}
		}
		
		protected function stage_resize(event : Event) : void
		{
			if (stage && ((m_widthIsRelative && m_contentBoxWidth != stage.stageWidth) || 
				(m_heightIsRelative && m_contentBoxHeight != stage.stageHeight)))
			{
				stageDimensionsChanged = true;
				invalidateStyles();
			}
		}
		
		protected function self_enterFrame(event : Event) : void
		{
			validateElements();
		}
		
		protected function self_removedFromStage(event : Event) : void
		{
			m_parentDocument = null;
			removeEventListener(Event.ENTER_FRAME, self_enterFrame);
			stage.removeEventListener(Event.RESIZE, stage_resize);
		}
	}
}