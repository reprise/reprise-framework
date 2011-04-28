/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.core
{
	import reprise.core.ApplicationContext;
	import reprise.css.CSS;
	import reprise.events.DisplayEvent;
	import reprise.external.IResource;
	import reprise.ui.DocumentView;
	import reprise.ui.UIObject;
	import reprise.utils.PathUtil;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.utils.getQualifiedClassName;

	public class Application extends Sprite
	{
		//----------------------             Public Properties              ----------------------//
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected static const CSS_URL : String = 'flash.css';		
		protected var _rootElement : DocumentView;
		protected var _currentView : UIObject;
		protected var _lastView : UIObject;
		
		protected var _appContext:ApplicationContext;
		
		protected var _css : CSS;

		
		//----------------------               Public Methods               ----------------------//
		public function Application()
		{
			if (stage)
			{
				initialize();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, self_addedToStage, false, 0, true);
			}
		}
		
		/**
		 * Returns the URL of the SWF file this application is associated with
		 * 
		 * @return The URL of the SWF file this application is associated with
		 */
		public function applicationURL() : String
		{
			return loaderInfo.url.split('\\').join('/');
		}
		
		/**
		 * Returns the base path part of the URL of the SWF file this application is associated with
		 * 
		 * @return The base path part of the URL of the SWF file this application is associated with
		 */
		public function basePath() : String
		{
			return PathUtil.stringByDeletingLastPathComponent(stage.loaderInfo.url);
		}
		
		/**
		 * Returns the complete current location String of the browser content the application is 
		 * embedded in
		 * 
		 * @return The current location String of the browser or an empty String
		 * @see https://developer.mozilla.org/en/DOM/window.location
		 */
		public function browserLocation() : String
		{
			if (ExternalInterface.available)
			{
				ExternalInterface.marshallExceptions = true;
				try
				{
					return ExternalInterface.call(
						'function getLocation(){return window.location.href}');
				}
				catch(error: Error)
				{
					log(error);
				}
			}
			return '';
		}
		
		/**
		 * Returns the DocumentView acting as the root element of the Applications view structure
		 * 
		 * @return The DocumentView acting as the root element of the Applications view structure
		 */
		public function rootElement() : DocumentView
		{
			return _rootElement;
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected function self_addedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, self_addedToStage);
			initialize();
		}
		
		protected function initialize() : void
		{
			var className : String = getQualifiedClassName(this).split('::').pop();
			zz_init(stage, className);
			
			_appContext = new ApplicationContext(this, this.loaderInfo);
			ApplicationRegistry.instance().registerApplication(this);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			initResourceLoading();
		}
		
		protected function initResourceLoading() : void
		{
			_appContext.coreResourceLoader.addEventListener(Event.COMPLETE, resource_complete);
			loadDefaultResources();
			loadResources();
			if (_appContext.coreResourceLoader.length())
			{
				_appContext.coreResourceLoader.execute();
			}
			else
			{
				initApplication();
			}
		}
		protected function loadDefaultResources() : void
		{
			//don't load default stylesheet if the actual application class has a CSS_URL property
			//that's set to null or an empty string
			if (Object(this).constructor.hasOwnProperty('CSS_URL') && 
				!Object(this).constructor['CSS_URL'])
			{
				return;
			}
			var cssURL:String = _appContext.applicationParameters.css_url ||
				Object(this).constructor['CSS_URL'] || CSS_URL;
			_css = new CSS(cssURL);
			_css.setBaseURL(applicationURL());
			addResource(_css);
		}
		
		protected function loadResources() : void
		{
		}
		
		protected function addResource(resource : IResource) : IResource
		{
			_appContext.coreResourceLoader.addResource(resource);
			return resource;
		}
		protected function resource_complete(event : Event) : void
		{
			_appContext.coreResourceLoader.removeEventListener(Event.COMPLETE, resource_complete);
			initApplication();
		}
		
		protected function initApplication() : void
		{
			createRootElement();
			_rootElement.styleSheet = _css;
			startApplication();
		}
		protected function createRootElement() : void
		{
			_rootElement = new DocumentView();
			_rootElement.setApplicationContext(_appContext);
			addChild(_rootElement);
			_rootElement.setParent(_rootElement);
		}

		protected function startApplication() : void
		{
		}
		
		/**
		 * creates a new UIComponent, replacing the current one.
		 * The class <strong>has</strong> to extend {@link reprise.ui.UIComponent}.
		 * (Unfortunately, there's no way to enforce any of this in AS.)
		 */
		protected function showView(viewClass:Class, delayShow:Boolean) : UIObject
		{
			if (_currentView)
			{
				_lastView = _currentView;
				_currentView = null;
				_lastView.addEventListener(DisplayEvent.HIDE_COMPLETE,
				 lastView_hide);
				_lastView.hide();
			}
			_currentView = UIObject(_rootElement.addChild(UIObject(new viewClass())));
			if (!_lastView && !delayShow)
			{
				_currentView.show();
			}
			else {
				_currentView.setVisibility(false);
			}
			return _currentView;
		}
	
		protected function lastView_hide() : void
		{
			_lastView.remove();
			_lastView = null;
			if (_currentView)
			{
				_currentView.show();
			}
		}
	}
}