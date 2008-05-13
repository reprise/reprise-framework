package reprise.events 
{
	import flash.events.Event;
	
	public class StateChangeEvent extends Event
	{
		public static const STATE_WILL_CHANGE:String = 'StateWillChangeEvent';
		public static const STATE_DID_CHANGE:String = 'StateDidChangeEvent';
		
		public var oldState:*;
		public var newState:*;
		
		public function StateChangeEvent(type:String, theOldState:*, theNewState:*)
		{
			super(type);
			oldState = theOldState;
			newState = theNewState;
		}
	}
}