/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.core
{ 
	public class ApplicationRegistry
	{//----------------------       Private / Protected Properties       ----------------------//
		protected static var g_instance : ApplicationRegistry;
		
		protected var _applications : Object;
		protected var _defaultApplication : Application;

		
		//----------------------               Public Methods               ----------------------//
		public static function instance() : ApplicationRegistry
		{
			if (!g_instance)
			{
				g_instance = new ApplicationRegistry();
			}
			return g_instance;
		}
		
		public function registerApplication(app:Application) : void
		{
			_applications[app.applicationURL()] = app;
			if (!_defaultApplication)
			{
				_defaultApplication = app;
			}
		}
		
		/**
		 * returns the application for the given url.
		 * Returns the default application (ie, the first one to be registered), 
		 * if no url is provided.
		 */
		public function applicationForURL(appURL : String = null) : Application
		{
			if (!appURL)
			{
				return _defaultApplication;
			}
			return Application(_applications[appURL]);
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		public function ApplicationRegistry() 
		{
			_applications = {};
		}	
	}
}