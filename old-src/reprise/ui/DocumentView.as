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
		//----------------------             Public Properties              ----------------------//
		public static var className : String = "body";
		
		public var stageDimensionsChanged : Boolean;
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected static var g_defaultStyleSheet : CSS = new CSS();
		protected static var g_totalValidationTime : int = 0;
		
		protected var _styleSheet : CSS;
		protected var _rendererFactory : UIRendererFactory;
	
		protected var _elementsById : Object;
		
		protected var _appContext : ApplicationContext;
		protected var _focusManager : FocusManager;
		protected var _tooltipContainer : Sprite;
		protected var _tooltipManager : TooltipManager;
		
		protected var _parentDocument : DocumentView;
		protected var _baseURL : String = '';
		
		protected var _validatedElementsCount : int;
		protected var _currentFrameTime : int;
		protected var _documentIsInvalidated : Boolean;
		protected var _documentIsValidating : Boolean;

		protected var _widthIsRelative : Boolean;
		protected var _heightIsRelative : Boolean;

		
		//----------------------               Public Methods               ----------------------//
		public function DocumentView()
		{
			_rendererFactory = new UIRendererFactory();
			_elementsById = {};
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
			_appContext = appContext;
		}
		
		/**
		 * Returns the document structures ApplicationContext
		 * 
		 * @return The document structures ApplicationContext
		 * @see ApplicationContext
		 */
		public function applicationContext() : ApplicationContext
		{
			return _appContext;
		}
		
		public function get parentDocument() : DocumentView
		{
			return _parentDocument;
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
			return _currentFrameTime;
		}

		override public function get stage() : Stage
		{
			if (realStage())
			{
				return realStage();
			}
			return _parentDocument ? _parentDocument.stage : null;
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
			return _documentIsValidating;
		}

		/**
		 * TODO: remove this override or turn it into a no-op. This should really be handled in a 
		 * cleaner way.
		 */
		public override function setParent(parent:UIObject) : UIObject
		{
			_rootElement = this;
			
			if (parent == this)
			{
				_parentDocument = null;
			}
			else
			{
				var container : UIObject = 
					DisplayListUtil.locateElementContainingDisplayObject(parent);
				if (container)
				{
					_parentDocument = container.document;
				}
			}
			super.setParent(parent);
			//TODO: remove this after making sure that that's ok (it really should be)
			_containingBlock = this;
			return this;
		}
		
		/**
		 * sets the UIRendererFactory to use for this UIComponent structure.
		 */
		public function setUIRendererFactory(
			rendererFactory:UIRendererFactory) : UIComponent
		{
			_rendererFactory = rendererFactory;
			return this;
		}
		/**
		 * returns the UIRendererFactory for this UIComponent structure
		 */
		public function uiRendererFactory() : UIRendererFactory
		{
			return _rendererFactory;
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
			_styleSheet = stylesheet;
			invalidateStyles();
			if (_styleSheet)
			{
				DebugInterface.reprise::startWatchingStylesheets(this);
			}
		}
		/**
		 * returns the stylesheet for this element structure
		 */
		public function get styleSheet() : CSS
		{
			if (_styleSheet)
			{
				return _styleSheet;
			}
			return g_defaultStyleSheet;
		}
		
		public function get baseURL() : String
		{
			return _baseURL || '';
		}
		
		public function set baseURL(url : String) : void
		{
			_baseURL = url || '';
		}
		
		public function resolveURL(url : String) : String
		{
			return CSSParsingHelper.resolvePathAgainstPath(url, _baseURL);
		}
		
		/**
		 * Returns the element matching the given CSS ID.
		 * 
		 * @param className The CSS ID to match descendant elements against
		 * @return The element matching the given CSS ID or null
		 */
		public function getElementById(id:String) : UIComponent
		{
			return UIComponent(_elementsById[id]);
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
			else if (_parentElement && _parentElement != this)
			{
				_parentElement.removeChild(this);
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
			_elementsById[id] = element;
		}
		reprise function removeElementID(id:String) : void
		{
			_elementsById[id] && delete _elementsById[id];
		}
		
		reprise function markChildAsInvalid(child : UIObject) : void
		{
			if (!_documentIsInvalidated && stage != null)
			{
				_documentIsInvalidated = true;
				addEventListener(Event.ENTER_FRAME, self_enterFrame, false, 0, true);
			}
		}
		
		reprise function setFocusedElement(element : UIObject, method : String) : Boolean
		{
			return _focusManager.reprise::setFocusedElement(element, method);
		}
		
		
		/***************************************************************************
		*							internal methods							   *
		***************************************************************************/
		internal function increaseValidatedElementsCount() : void
		{
			_validatedElementsCount++;
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function initialize() : void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			_rootElement = this;
			_containingBlock = this;
			if (!_baseURL)
			{
				_baseURL = loaderInfo.url.substr(0, loaderInfo.url.lastIndexOf('/') + 1);
			}
			stage.addEventListener(Event.RESIZE, stage_resize, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, self_removedFromStage, false, 0, true);
			super.initialize();
			stage.stageFocusRect = false;
			_focusManager = new FocusManager(this);
			if (!parentDocument)
			{
				_tooltipManager = new TooltipManager(_rootElement, _tooltipContainer);
			}
			
			DebugInterface.addDocument(this);
		}

		override protected function createDisplayClips() : void
		{
			super.createDisplayClips();
			if (parentDocument)
			{
				return;
			}
			_tooltipContainer = new Sprite();
			addChild(_tooltipContainer);
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
			_elementDefaultStyles.setStyle('width', '100%');
			_elementDefaultStyles.setStyle('height', '100%');
			_elementDefaultStyles.setStyle('padding', '0');
			_elementDefaultStyles.setStyle('margin', '0');
			_elementDefaultStyles.setStyle('boxSizing', 'border-box');
			_elementDefaultStyles.setStyle('position', 'absolute');
			_elementDefaultStyles.setStyle('fontFamily', '_sans');
			_elementDefaultStyles.setStyle('fontSize', '12px');
			_elementDefaultStyles.setStyle('frameRate', stage.frameRate.toString());
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
			if (_currentStyles.frameRate)
			{
				stage.frameRate = _currentStyles.frameRate;
			}
			_heightIsRelative = _complexStyles.getStyle('height').isRelativeValue();
			_widthIsRelative = _complexStyles.getStyle('width').isRelativeValue();
		}
		protected override function resolveRelativeStyles(styles:CSSDeclaration, 
			parentW : int = -1, parentH : int = -1) : void
		{
			super.resolveRelativeStyles(styles, stage.stageWidth, stage.stageHeight);
		}
		
		protected override function applyOutOfFlowChildPositions() : void
		{
			super.applyOutOfFlowChildPositions();
			y = _currentStyles.marginTop;
			x = _currentStyles.marginLeft;
		}
		
		protected override function refreshSelectorPath() : void
		{
			var oldPath : String = _selectorPath;
			_selectorPath = '';
			super.refreshSelectorPath();
			if (_selectorPath == oldPath)
			{
				_selectorPathChanged = false;
			}
		}
		
		protected function validateElements() : void
		{
			removeEventListener(Event.ENTER_FRAME, self_enterFrame);

			if (!_documentIsInvalidated)
			{
				return;
			}
			_documentIsInvalidated = false;
			_documentIsValidating = true;
			_currentFrameTime = getTimer();
			_validatedElementsCount = 0;

			if (_isInvalidated)
			{
				validateElement();
			}
			else
			{
				validateChildren();
			}

			g_totalValidationTime += getTimer() - _currentFrameTime;
			log('d validated ' + _validatedElementsCount +
				' elements in ' + (getTimer() - _currentFrameTime) + 'ms. ' +
				'Total validation time: ' + g_totalValidationTime);
			hasEventListener(DisplayEvent.DOCUMENT_VALIDATION_COMPLETE) &&
					dispatchEvent(new DisplayEvent(DisplayEvent.DOCUMENT_VALIDATION_COMPLETE));
			_documentIsValidating = false;
			//validate elements that have been marked as invalid during validation
			if (_documentIsInvalidated)
			{
				addEventListener(Event.ENTER_FRAME, self_enterFrame);
			}
		}
		
		protected function stage_resize(event : Event) : void
		{
			if (stage && ((_widthIsRelative && _contentBoxWidth != stage.stageWidth) ||
				(_heightIsRelative && _contentBoxHeight != stage.stageHeight)))
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
			_parentDocument = null;
			removeEventListener(Event.ENTER_FRAME, self_enterFrame);
			stage.removeEventListener(Event.RESIZE, stage_resize);
		}
	}
}