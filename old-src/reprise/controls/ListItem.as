//
//  ListItem.as
//
//  Created by Marc Bauer on 2008-06-20.
//  Copyright (c) 2008 Fork Unstable Media GmbH. All rights reserved.
//

package reprise.controls
{

	import reprise.controls.LabelButton;

	
	public class ListItem extends LabelButton implements IListItem
	{
		
		//----------------------               Public Methods               ----------------------//
		override public function setData(data : *) : void
		{
			super.setData(data);
			setLabel(data.label);
			setValue(data.value);
		}
	}
}