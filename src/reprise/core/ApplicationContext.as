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
	import reprise.core.Application;
	import reprise.core.CoreResourceLoader;
	import reprise.i18n.II18NService;
	import reprise.services.tracking.ITrackingService;
	
	import flash.display.LoaderInfo;
	import flash.utils.ByteArray;	

	public class ApplicationContext
	{
		/***************************************************************************
		*                             Public properties                            *
		***************************************************************************/
		public var coreResourceLoader:CoreResourceLoader;
		public var applicationURL:String;
		public var applicationParameters:Object;
		
		
		/***************************************************************************
		*                           Protected properties                           *
		***************************************************************************/
		protected static var g_mainContext:ApplicationContext;
		protected var m_application:Application;
		
		protected var m_i18nService : II18NService;
		protected var m_trackingService : ITrackingService;
		
		
		/***************************************************************************
		*                              Public methods                              *
		***************************************************************************/
		public function ApplicationContext(application:Application, loaderInfo:LoaderInfo)
		{
			if (!g_mainContext)
			{
				g_mainContext = this;
				coreResourceLoader = new CoreResourceLoader(this);
			}
			else
			{
				coreResourceLoader = g_mainContext.coreResourceLoader;
			}
			
			var objCopy:ByteArray = new ByteArray();
			objCopy.writeObject(loaderInfo.parameters);
			objCopy.position = 0;
			applicationURL = application.applicationURL();
			applicationParameters = objCopy.readObject();
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
				return key;
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
				return defaultReturnValue;
			}
			return result;
		}
		
		public function track(trackingId : String) : void
		{
			m_trackingService.track(trackingId);
		}
	}
}