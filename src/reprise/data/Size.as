//
//  Size.as
//
//  Created by Marc Bauer on 2009-02-12.
//  Copyright (c) 2009 Fork Unstable Media GmbH. All rights reserved.
//

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