/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.core
{
	import reprise.core.Application;
	import reprise.core.CoreResourceLoader;
	import reprise.i18n.II18NService;
	import reprise.services.tracking.ITrackingService;
	
	import flash.display.LoaderInfo;
	import flash.utils.ByteArray;	

	public class ApplicationContext
	{
		//----------------------             Public Properties              ----------------------//
		public var coreResourceLoader:CoreResourceLoader;
		public var applicationURL:String;
		public var applicationParameters:Object;
		
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected static var g_mainContext:ApplicationContext;
		protected var m_application:Application;
		
		protected var m_i18nService : II18NService;
		protected var m_trackingService : ITrackingService;
		
		
		//----------------------               Public Methods               ----------------------//
		public function ApplicationContext(application:Application, loaderInfo:LoaderInfo)
		{
//			if (!g_mainContext)
//			{
//				g_mainContext = this;
//				coreResourceLoader = new CoreResourceLoader(this);
//			}
//			else
//			{
//				coreResourceLoader = g_mainContext.coreResourceLoader;
//			}
			/*
			 * TODO: find a way to use a global loader for all applications while correctly 
			 * resolving relative URLs
			 */
			coreResourceLoader = new CoreResourceLoader(this);
			
			//copy parameters of stage loader
			var objCopy:ByteArray = new ByteArray();
			objCopy.writeObject(application.stage.loaderInfo.parameters);
			objCopy.position = 0;
			applicationURL = application.applicationURL();
			applicationParameters = objCopy.readObject();
			//merge parameters of application loader if it's not the same as the stage loader
			if (loaderInfo.url != application.stage.loaderInfo.url)
			{
				for (var i : String in loaderInfo.parameters)
				{
					applicationParameters[i] = loaderInfo.parameters[i];
				}
			}
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
		
		public function i18n(key : String, defaultReturnValue : * = null) : *
		{
			if (!m_i18nService)
			{
				log('w No i18n service set, can\'t resolve key "' + key + '"');
				return defaultReturnValue == null ? key : defaultReturnValue;
			}
			var result : *;
			if (m_i18nService.keyExists(key))
			{
				result = m_i18nService.contentByKey(key);
				if (typeof result == "string")
				{
					result = (result as String).split('\r\n').join('\n').split('\r').join('\n');
				}
			}
			if (result == null)
			{
				log('w No i18n result found for key "' + key + '"');
				return defaultReturnValue == null ? key : defaultReturnValue;
			}
			return result;
		}
		
		public function track(trackingId : String) : void
		{
			m_trackingService.track(trackingId);
		}
	}
}