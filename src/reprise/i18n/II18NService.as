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

package reprise.i18n
{
	/**
	 * @author till
	 */
	public interface II18NService
	{
		function getStringByKey(key : String) : String;
		function getBoolByKey(key : String) : Boolean;
		function getGenericContentByKey(key : String) : Object;
		function keyExists(key : String) : Boolean;
	}
}