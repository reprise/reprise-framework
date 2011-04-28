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
		
		protected var m_applications : Object;
		protected var m_defaultApplication : Application;

		
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
			m_applications[app.applicationURL()] = app;
			if (!m_defaultApplication)
			{
				m_defaultApplication = app;
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
				return m_defaultApplication;
			}
			return Application(m_applications[appURL]);
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		public function ApplicationRegistry() 
		{
			m_applications = {};
		}	
	}
}