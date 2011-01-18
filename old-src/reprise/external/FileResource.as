/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.external
{
	public class FileResource extends URLLoaderResource
	{
		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function FileResource()
		{
			log('w FileResource is deprecated. Use URLLoaderResource instead.');
		}
	}
}