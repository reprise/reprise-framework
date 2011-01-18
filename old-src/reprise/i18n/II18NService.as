/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.i18n
{
	/**
	 * @author till
	 */
	public interface II18NService
	{
		function contentByKey(key : String) : *;
		function keyExists(key : String) : Boolean;
	}
}