/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.core
{

	import reprise.core.ApplicationContext;
	import reprise.css.CSSParsingHelper;
	import reprise.external.IResource;
	import reprise.external.ResourceLoader;
	
	public class CoreResourceLoader extends ResourceLoader
	{
	
		//----------------------       Private / Protected Properties       ----------------------//
		protected var m_appContext:ApplicationContext;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function CoreResourceLoader(appContext:ApplicationContext)
		{
			super();
			m_appContext = appContext;
		}
		
		
		override public function addResource(cmd:IResource):void
		{
			rewriteURLOfResource(cmd);
			super.addResource(cmd);
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected function rewriteURLOfResource(res:IResource):void
		{
			res.setURL(CSSParsingHelper.resolvePathAgainstPath(res.url(), 
				m_appContext.applicationURL));
		}
	}
}