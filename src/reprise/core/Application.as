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
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static const CSS_URL : String = 'flash.css';		
		protected var m_rootElement : DocumentView;
		protected var m_currentView : UIObject;
		protected var m_lastView : UIObject;
		
		protected var m_appContext:ApplicationContext;
		
		protected var m_css : CSS;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
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
			return m_rootElement;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function self_addedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, self_addedToStage);
			initialize();
		}
		
		protected function initialize() : void
		{
			CONFIG::debug
			{
				var className : String = getQualifiedClassName(this).split('::').pop();
				zz_init(stage, className);
			}
			m_appContext = new ApplicationContext(this, this.loaderInfo);
			ApplicationRegistry.instance().registerApplication(this);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			initResourceLoading();
		}
		
		protected function initResourceLoading() : void
		{
			m_appContext.coreResourceLoader.addEventListener(Event.COMPLETE, resource_complete);
			loadDefaultResources();
			loadResources();
			if (m_appContext.coreResourceLoader.length())
			{
				m_appContext.coreResourceLoader.execute();
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
			var cssURL:String = m_appContext.applicationParameters.css_url || 
				Object(this).constructor['CSS_URL'] || CSS_URL;
			m_css = new CSS(cssURL);
			m_css.setBaseURL(applicationURL());
			addResource(m_css);
		}
		
		protected function loadResources() : void
		{
		}
		
		protected function addResource(resource : IResource) : IResource
		{
			m_appContext.coreResourceLoader.addResource(resource);
			return resource;
		}
		protected function resource_complete(event : Event) : void
		{
			m_appContext.coreResourceLoader.removeEventListener(Event.COMPLETE, resource_complete);
			initApplication();
		}
		
		protected function initApplication() : void
		{
			createRootElement();
			m_rootElement.styleSheet = m_css;
			startApplication();
		}
		protected function createRootElement() : void
		{
			m_rootElement = new DocumentView();
			m_rootElement.setApplicationContext(m_appContext);
			addChild(m_rootElement);
			m_rootElement.setParent(m_rootElement);
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
			if (m_currentView)
			{
				m_lastView = m_currentView;
				m_currentView = null;
				m_lastView.addEventListener(DisplayEvent.HIDE_COMPLETE, 
				 lastView_hide);
				m_lastView.hide();
			}
			m_currentView = UIObject(m_rootElement.addChild(UIObject(new viewClass())));
			if (!m_lastView && !delayShow)
			{
				m_currentView.show();
			}
			else {
				m_currentView.setVisibility(false);
			}
			return m_currentView;
		}
	
		protected function lastView_hide() : void
		{
			m_lastView.remove();
			m_lastView = null;
			if (m_currentView)
			{
				m_currentView.show();
			}
		}
	}
}