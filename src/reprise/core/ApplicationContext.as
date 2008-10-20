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

	import flash.display.LoaderInfo;
	import flash.utils.ByteArray;
	
	import reprise.core.Application;
	import reprise.core.CoreResourceLoader;
	
	public class ApplicationContext
	{
		
		/***************************************************************************
		*                           Protected properties                           *
		***************************************************************************/
		protected static var g_mainContext:ApplicationContext;
		protected var m_application:Application;
		
		
		
		/***************************************************************************
		*                             Public properties                            *
		***************************************************************************/
		public var coreResourceLoader:CoreResourceLoader;
		public var applicationURL:String;
		public var applicationParameters:Object;
		
		
		
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
			
			var objCopy:ByteArray = new ByteArray()
			objCopy.writeObject(loaderInfo.parameters);
			objCopy.position = 0;
			applicationURL = loaderInfo.loaderURL;
			applicationParameters = objCopy.readObject();
		}
	}
}