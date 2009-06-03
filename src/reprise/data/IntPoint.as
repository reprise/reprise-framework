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

package reprise.data
{
	
	public class IntPoint
	{

		//*****************************************************************************************
		//*                                   Public Properties                                   *
		//*****************************************************************************************
		public var x : int;
		public var y : int;
		
		
		
		//*****************************************************************************************
		//*                                     Public Methods                                    *
		//*****************************************************************************************
		public function IntPoint(x : int = 0, y : int = 0) 
		{
			this.x = x;
			this.y = y;
		}
		
		
		public function toString() : String
		{
			return '[IntPoint] x: ' + x + ', y: ' + y;
		}
	}
}