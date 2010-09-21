/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css
{
	import reprise.external.URLLoaderResource;
	
	internal class CSSImport extends URLLoaderResource
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		protected var m_owner : CSS;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSImport(owner:CSS, url:String = null)
		{
			m_owner = owner;
			setURL(url);
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function notifyComplete(success:Boolean) : void
		{
			if (success)
			{
				m_owner.resolveImport(this);
			}
			super.notifyComplete(success);
		}	
	}
}