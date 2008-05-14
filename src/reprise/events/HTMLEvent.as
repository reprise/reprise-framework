package reprise.events
{
	
	import flash.events.Event;
	
	
	public class HTMLEvent extends Event
	{
	
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var ANCHOR_CLICK : String = 'htmlAnchorClick';
		
	
		public function HTMLEvent(type:String)
		{
			super(type);
		}	
	}
}