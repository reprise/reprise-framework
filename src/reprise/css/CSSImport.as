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

package reprise.css
{ 
	import reprise.external.FileResource;
	
	public class CSSImport extends FileResource
	{
		
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		protected	var m_owner : CSS;
		
		
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