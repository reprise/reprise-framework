/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.external
{ 
	
	
	public class ResourceProxy
	{
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_instance : ResourceProxy;
		protected var m_delegate : IResourceProxyDelegate;
		
		
			
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static function instance() : ResourceProxy
		{
			if (g_instance == null)
			{
				g_instance = new ResourceProxy();
			}
			return g_instance;
		}
		
		public function delegate() : IResourceProxyDelegate
		{
			return m_delegate;
		}
	
		public function setDelegate(val:IResourceProxyDelegate) : void
		{
			m_delegate = val;
		}
		
		public function modifiedURLStringForString(url:String) : String
		{
			if (m_delegate == null)
			{
				return url;
			}
			return m_delegate.modifiedURLStringForString(url);
		}
		
			
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function ResourceProxy() {}
	}
}