package itrain.co.uk.components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.engine.Kerning;
	import flash.ui.ContextMenu;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.formats.TextLayoutFormat;
	
	import itrain.co.uk.events.FloatingToolbarEvent;
	import itrain.co.uk.events.InPlaceTextEditorEvent;
	
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.RichEditableText;
	import spark.components.TextSelectionHighlighting;
	import spark.events.TextOperationEvent;
	
	[Event(name="textChanges", type="itrain.co.uk.events.InPlaceTextEditorEvent")]
	public class InPlaceTextEditor extends RichEditableText
	{
		public var toolBar:ToolbarBase;
		
		private var _lockedMenu:Boolean = false;
		private var _floating:Boolean = false;
		
		private var _lastActivePosition:int;
		private var _lastAnchorPosition:int;
		private var _movableParent:DisplayObject;
		private var _isFocused:Boolean = false;
		
		public function InPlaceTextEditor(floating:Boolean = false, movableParent:DisplayObject = null)
		{
			super();
			
			_floating = floating;
			if (_floating) {
				this.addEventListener(FocusEvent.FOCUS_IN, onFocusIn, false, 0, true);
				this.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut, false, 0, true);
				this.addEventListener(Event.REMOVED, onRemoved, false, 0, true);
				this.addEventListener(MouseEvent.CLICK, onFocusIn, false, 0, true);
				_movableParent = movableParent;
			}
			
			this.addEventListener(FlexEvent.SELECTION_CHANGE, onSelectionChange, false, 0, true);
			this.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			this.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			this.addEventListener(TextOperationEvent.CHANGE, onUserTextChange, false, 0, true);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			
			_lastActivePosition = selectionActivePosition;
			_lastAnchorPosition = selectionAnchorPosition;
			
			selectionHighlighting = TextSelectionHighlighting.ALWAYS;
			
			this.setStyle("	focusSkin", null);
			this.setStyle("focusThickness", 0);
		}
		
		public function isFocused():Boolean {
			return _isFocused;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			if (!toolBar) {
				if(_floating) {
					toolBar = new FloatingToolbar();
					(toolBar as FloatingToolbar).movableParent = _movableParent;
					toolBar.addEventListener(FloatingToolbarEvent.LOCK_MENU, onLockMenu, false, 0, true);
					toolBar.addEventListener(FloatingToolbarEvent.UNLOCK_MENU, onUnlockMenu, false, 0, true);
					toolBar.addEventListener(FloatingToolbarEvent.REMOVE_ITEM, onRemoveItem, false, 0, true);
					toolBar.addEventListener(FloatingToolbarEvent.FOCUS_PARENT, revertFocus, false, 0, true);
				} else
					toolBar = new StaticToolbar();
				toolBar.initialize();
				
				toolBar.addEventListener(FloatingToolbarEvent.FONT_FAMILY_CHANGE, onFloatingToolbarChange, false, 0, true);
				toolBar.addEventListener(FloatingToolbarEvent.FONT_SIZE_CHANGE, onFloatingToolbarChange, false, 0, true);
				toolBar.addEventListener(FloatingToolbarEvent.TEXT_DECORATION_CHANGE, onFloatingToolbarChange, false, 0, true);
				toolBar.addEventListener(FloatingToolbarEvent.FONT_STYLE_CHANGE, onFloatingToolbarChange, false, 0, true);
				toolBar.addEventListener(FloatingToolbarEvent.FONT_WEIGHT_CHANGE, onFloatingToolbarChange, false, 0, true);
				toolBar.addEventListener(FloatingToolbarEvent.FONT_COLOR_CHANGE, onFloatingToolbarChange, false, 0, true);
				toolBar.addEventListener(FloatingToolbarEvent.TEXT_ALIGNMENT_CHANGE, onFloatingToolbarChange, false, 0, true);
				toolBar.addEventListener(FloatingToolbarEvent.BULLETS_CHANGE, onBulletChange, false, 0, true);
			}
		}
		
		private function onRemovedFromStage(e:Event):void {
			this.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			this.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			this.removeEventListener(Event.REMOVED, onRemoved);
			this.removeEventListener(MouseEvent.CLICK, onFocusIn);
			this.removeEventListener(FlexEvent.SELECTION_CHANGE, onSelectionChange);
			this.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			this.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			this.removeEventListener(TextOperationEvent.CHANGE, onUserTextChange);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			toolBar.removeEventListener(FloatingToolbarEvent.LOCK_MENU, onLockMenu);
			toolBar.removeEventListener(FloatingToolbarEvent.UNLOCK_MENU, onUnlockMenu);
			toolBar.removeEventListener(FloatingToolbarEvent.REMOVE_ITEM, onRemoveItem);
			toolBar.removeEventListener(FloatingToolbarEvent.FOCUS_PARENT, revertFocus);
			toolBar.removeEventListener(FloatingToolbarEvent.FONT_FAMILY_CHANGE, onFloatingToolbarChange);
			toolBar.removeEventListener(FloatingToolbarEvent.FONT_SIZE_CHANGE, onFloatingToolbarChange);
			toolBar.removeEventListener(FloatingToolbarEvent.TEXT_DECORATION_CHANGE, onFloatingToolbarChange);
			toolBar.removeEventListener(FloatingToolbarEvent.FONT_STYLE_CHANGE, onFloatingToolbarChange);
			toolBar.removeEventListener(FloatingToolbarEvent.FONT_WEIGHT_CHANGE, onFloatingToolbarChange);
			toolBar.removeEventListener(FloatingToolbarEvent.FONT_COLOR_CHANGE, onFloatingToolbarChange);
			toolBar.removeEventListener(FloatingToolbarEvent.TEXT_ALIGNMENT_CHANGE, onFloatingToolbarChange);
			toolBar.removeEventListener(FloatingToolbarEvent.BULLETS_CHANGE, onBulletChange);
		}
		
		private function revertFocus(e:Event):void {
			this.setFocus();
			selectRange(_lastAnchorPosition, _lastActivePosition);
		}
		
		private function onLockMenu(e:FloatingToolbarEvent):void {
			_lockedMenu = true;
		}
		
		private function onUnlockMenu(e:FloatingToolbarEvent):void {
			_lockedMenu = false;
		}
		
		private function onSelectionChange(e:FlexEvent):void {
			var tlf:TextLayoutFormat = getFormatOfRange();
			
			toolBar.font = tlf.fontFamily;
			toolBar.fontSize = tlf.fontSize;
			toolBar.textDecoration = tlf.textDecoration;
			toolBar.fontStyle = tlf.fontStyle;
			toolBar.fontWeight = tlf.fontWeight;
			toolBar.fontColor = tlf.color;
			toolBar.textAlignment = tlf.textAlign;
			
			toolBar.btnBullets.selected = TLFBulletListUtils.containsLists(textFlow);
			
			_lastActivePosition = selectionActivePosition;
			_lastAnchorPosition = selectionAnchorPosition;
		}
		
		private function onFocusIn(e:Event):void {
			_isFocused=true;
			(toolBar as FloatingToolbar).show(this);
		}
		
		private function onFocusOut(e:FocusEvent):void {
			_isFocused=false;
			if (!_lockedMenu)
				(toolBar as FloatingToolbar).hide();
		}
		
		private function onFloatingToolbarChange(e:FloatingToolbarEvent):void {
			var tlf:TextLayoutFormat;
			var anchorPos:int = -1;
			var activePos:int = -1;
			if (textFlow.interactionManager.activePosition == textFlow.interactionManager.anchorPosition) {
				anchorPos = 0;
				activePos = textFlow.getText().length;
			}
			tlf = getFormatOfRange(null, anchorPos, activePos);
			tlf[e.propertyName] = e.newValue;
			setFormatOfRange(tlf,anchorPos, activePos);
			textChanges();
		}
		
		private function onBulletChange(e:FloatingToolbarEvent):void {
			TLFBulletListUtils.handleListToggle(textFlow);
			textChanges();
		}
		
		private function onUserTextChange(e:Event):void {
			textChanges();
		}
		
		private function onRemoved(e:Event):void {
			if (e.target == this)
				(toolBar as FloatingToolbar).hide();
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			if ([Keyboard.UP, Keyboard.DOWN, Keyboard.LEFT, Keyboard.RIGHT].indexOf(e.keyCode) > -1) {
				e.stopPropagation();
			} else if (e.keyCode == Keyboard.C && e.ctrlKey) {
				if (textFlow.interactionManager.activePosition == textFlow.interactionManager.anchorPosition) {
					e.stopImmediatePropagation();
					e.preventDefault();
					var newKE:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true);
					newKE.keyCode = Keyboard.C;
					newKE.ctrlKey = true;
					parent.dispatchEvent(newKE);
				}
			}
		}
		
		private function onKeyUp(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.DELETE)
				e.stopImmediatePropagation();
		}
		
		private function onRemoveItem(e:FloatingToolbarEvent):void {
			(toolBar as FloatingToolbar).hide();
		
			
			var de:InPlaceTextEditorEvent = new InPlaceTextEditorEvent(InPlaceTextEditorEvent.DELETE_CLICKED);
			this.dispatchEvent(de);
		}
		
		private function textChanges():void {
			dispatchEvent(new InPlaceTextEditorEvent(InPlaceTextEditorEvent.TEXT_CHANGES));
		}
	}
}