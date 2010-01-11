/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.data
{
	public class Size
	{
		//*****************************************************************************************
		//*                                   Public Properties                                   *
		//*****************************************************************************************
		public var width:Number;
		public var height:Number;
		
		
		
		//*****************************************************************************************
		//*                                     Public Methods                                    *
		//*****************************************************************************************
		public function Size(w:Number, h:Number) 
		{
			width = w;
			height = h;
		}
		
		
		public function toString() : String
		{
			return '[Size] width: ' + width + ', height: ' + height;
		}
	}
}