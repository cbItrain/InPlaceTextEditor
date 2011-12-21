package itrain.co.uk.events
{
	import flash.events.Event;
	
	public class FloatingToolbarEvent extends Event
	{
		public static const FONT_FAMILY_CHANGE:String = "FloatingToolbarEventFontFamilyChange";
		public static const FONT_SIZE_CHANGE:String = "FloatingToolbarEventFontSizeChange";
		public static const FONT_WEIGHT_CHANGE:String = "FloatingToolbarEventFontWeightChange";
		public static const FONT_STYLE_CHANGE:String = "FloatingToolbarEventFontStyleChange";
		public static const FONT_COLOR_CHANGE:String = "FloatingToolbarEventFontColorChange";
		public static const TEXT_ALIGNMENT_CHANGE:String = "FloatingToolbarEventTextAlignemtChange";
		public static const TEXT_DECORATION_CHANGE:String = "FloatingToolbarEventTextDecorationChange";
		public static const FOCUS_PARENT:String = "FloatingToolbarEventFocusParent";
		public static const LOCK_MENU:String = "FloatingToolbarEventLockMenu";
		public static const UNLOCK_MENU:String = "FloatingToolbarEventUnlockMenu";
		public static const REMOVE_ITEM:String = "FloatingToolbarEventRemoveItem";
		
		public var newValue:Object;
		public var propertyName:String;
		
		public function FloatingToolbarEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}