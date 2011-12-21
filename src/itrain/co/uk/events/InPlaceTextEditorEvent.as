package itrain.co.uk.events
{
	import flash.events.Event;
	
	public class InPlaceTextEditorEvent extends Event
	{
		public static const DELETE_CLICKED:String = "InPlaceTextEditorEventDeleteClicked";
		public static const TEXT_CHANGES:String = "textChanges";
		
		public function InPlaceTextEditorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}