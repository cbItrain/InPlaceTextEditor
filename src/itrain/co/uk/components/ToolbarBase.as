package itrain.co.uk.components
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.Font;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.TextDecoration;
	
	import itrain.co.uk.events.FloatingToolbarEvent;
	import itrain.co.uk.renderers.FontLabelItemRenderer;
	import itrain.co.uk.skins.CustomButtonBarSparkSkin;
	import itrain.co.uk.skins.CustomDropDownListSkin;
	import itrain.co.uk.skins.FloatingToolbarSkin;
	
	import mx.collections.ArrayCollection;
	import mx.controls.ColorPicker;
	import mx.core.ClassFactory;
	import mx.events.ColorPickerEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.ButtonBar;
	import spark.components.DropDownList;
	import spark.components.TitleWindow;
	import spark.components.ToggleButton;
	import spark.events.IndexChangeEvent;
	import spark.layouts.VerticalLayout;
	
	public class ToolbarBase extends TitleWindow
	{
		[Embed(source="assets/icons/edit-alignment.png")]
		[Bindable]
		private static var _alignLeftIcon:Class;
		[Embed(source="assets/icons/edit-alignment-right.png")]
		[Bindable]
		private static var _alignRightIcon:Class;
		[Embed(source="assets/icons/edit-alignment-center.png")]
		[Bindable]
		private static var _alignCenterIcon:Class;
		[Embed(source="assets/icons/edit-bold.png")]
		private static var _boldButtonIcon:Class;
		[Embed(source="assets/icons/edit-italic.png")]
		private static var _italicButtonIcon:Class;
		[Embed(source="assets/icons/edit-underline.png")]
		private static var _underlineButtonIcon:Class;
		[Embed(source="assets/icons/edit-list.png")]
		private static var _bulletButtonIcon:Class;
		
		[Bindable]
		protected var _fontSizes:Array=[8, 9, 10, 11, 12, 14, 16, 18, 20, 22, 24, 26, 28, 36, 40, 48, 72];
		
		[Bindable]
		protected var _fontFamilies:Array=Font.enumerateFonts(true);
		
		public var ddFontFamily:DropDownList;
		public var ddFontSize:DropDownList;
		public var btnBold:ToggleButton;
		public var btnItalic:ToggleButton;
		public var btnUnderline:ToggleButton;
		public var cpFontColor:ColorPicker;
		public var bbAlignment:ButtonBar;
		public var btnBullets:ToggleButton;
		
		
		public function ToolbarBase()
		{
			super();
			this.addEventListener(FocusEvent.FOCUS_IN, focusParent, false, 0, true);
			this.addEventListener(FocusEvent.FOCUS_OUT, focusParent, false, 0, true);
			
			this.addEventListener(FlexEvent.INITIALIZE, onInitialize, false, 0, true);
			
			this.focusEnabled = false;
			
			_fontFamilies.sortOn("fontName");
		}
		
		private function onInitialize(fe:FlexEvent):void {
			initializeFontFamily();
			initializeFontSize();
			initializeBtnBold();
			initializeBtnItalic();
			initializeBtnUnderline();
			initializeColorPicker();
			initializeBbAlignment();
			initializeBtnBullets();
		}
		
		//-------------------Initialization-------------------------------
		private function initializeFontFamily():void {
			ddFontFamily.dataProvider = new ArrayCollection(_fontFamilies);
			ddFontFamily.addEventListener(IndexChangeEvent.CHANGE, onFontFamilyChange, false, 0, true);
			ddFontFamily.focusEnabled=false;
			ddFontFamily.labelField="fontName";
			ddFontFamily.width = 150;
			ddFontFamily.itemRenderer = new ClassFactory(FontLabelItemRenderer);
			ddFontFamily.setStyle("skinClass", CustomDropDownListSkin);
			
			ddFontFamily.layout = new VerticalLayout();
			(ddFontFamily.layout as VerticalLayout).requestedRowCount = 15;
		}
		
		private function initializeFontSize():void {
			ddFontSize.addEventListener(IndexChangeEvent.CHANGE, onFontSizeChange, false, 0, true);
			ddFontSize.dataProvider = new ArrayCollection(_fontSizes);
			ddFontSize.focusEnabled = false;
			ddFontSize.width = 60;
		}
		
		private function initializeBtnBold():void {
			btnBold.addEventListener(Event.CHANGE, onWeightChange, false, 0, true);
			btnBold.setStyle("icon", _boldButtonIcon);
			btnBold.width = btnBold.height = 20;
			btnBold.focusEnabled = false;
		}
		
		private function initializeBtnItalic():void {
			btnItalic.addEventListener(Event.CHANGE, onFontStyleChange, false, 0, true);
			btnItalic.setStyle("icon", _italicButtonIcon);
			btnItalic.width = btnItalic.height = 20;
			btnItalic.focusEnabled = false;
		}
		
		private function initializeBtnUnderline():void {
			btnUnderline.addEventListener(Event.CHANGE, onFontDecorationChange, false, 0, true);
			btnUnderline.setStyle("icon", _underlineButtonIcon);
			btnUnderline.width = btnUnderline.height = 20;
			btnUnderline.focusEnabled = false;
		}
		
		private function initializeColorPicker():void {
			cpFontColor.addEventListener(ColorPickerEvent.CHANGE, onFontColorChange, false, 0, true);
			cpFontColor.addEventListener(FocusEvent.FOCUS_OUT, onColorPickerMouseDown, false, 0, true);
			cpFontColor.focusEnabled = false;
		}
		
		private function initializeBbAlignment():void {
			bbAlignment.addEventListener(IndexChangeEvent.CHANGE, onAlignmentChange, false, 0, true);
			bbAlignment.setStyle("skinClass", CustomButtonBarSparkSkin);
			bbAlignment.focusEnabled = false;
			bbAlignment.width = 90;
			bbAlignment.dataProvider = new ArrayCollection([{label:"Left", icon:_alignLeftIcon}, {label:"Center", icon:_alignCenterIcon}, {label:"Right", icon:_alignRightIcon}]);
		}
		
		private function initializeBtnBullets():void {
			btnBullets.addEventListener(Event.CHANGE, onBulletsChange, false, 0, true);
			btnBullets.setStyle("icon", _bulletButtonIcon);
			btnBullets.width = btnUnderline.height = 20;
			btnBullets.focusEnabled = false;
		}
		
		//------------------------------------------------------
		
		private function focusParent(e:Event):void {
			//trace(e.type);
			dispatchEvent(new FloatingToolbarEvent(FloatingToolbarEvent.FOCUS_PARENT));
		}
		
		protected function onColorPickerMouseDown(e:Event = null):void {
			callLater(function():void {
				dispatchEvent(new FocusEvent(FocusEvent.FOCUS_IN));
			});
		}
		//setters and getters
		
		[Bindable]
		public function get font():String {
			if (ddFontFamily.selectedItem)
				return (ddFontFamily.selectedItem as Font).fontName;
			else
				return null;
		}
		
		public function set font(value:String):void {
			if (value) {
				for each (var f:Font in ddFontFamily.dataProvider) {
					if (f.fontName.toUpperCase() == value.toUpperCase()) {
						ddFontFamily.selectedItem=f;
						return;
					}
				}
			} else {
				ddFontFamily.selectedItem=null;
			}
		}
		
		[Bindable]
		public function get fontSize():int {
			return ddFontSize.selectedItem;
		}
		
		public function set fontSize(value:int):void {
			if (_fontSizes.indexOf(value) > -1)
				ddFontSize.selectedItem=value;
			else
				ddFontSize.selectedIndex=0;
		}
		
		[Bindable]
		public function get fontStyle():String {
			if (btnItalic.selected)
				return FontPosture.ITALIC;
			else
				return FontPosture.NORMAL;
		}
		
		
		public function set fontStyle(value:String):void {
			btnItalic.selected=value == FontPosture.ITALIC;
		}
		
		[Bindable]
		public function get fontWeight():String {
			if (btnBold.selected)
				return FontWeight.BOLD;
			else
				return FontWeight.NORMAL;
		}
		
		public function set fontWeight(value:String):void {
			btnBold.selected=value == FontWeight.BOLD;
		}
		
		[Bindable]
		public function get textDecoration():String {
			if (btnUnderline.selected)
				return TextDecoration.UNDERLINE;
			else
				return TextDecoration.NONE;
		}
		
		public function set textDecoration(value:String):void {
			btnUnderline.selected=value == TextDecoration.UNDERLINE;
		}
		
		[Bindable]
		public function get fontColor():uint {
			return cpFontColor.selectedColor;
		}
		
		public function set fontColor(value:uint):void {
			cpFontColor.selectedColor=value;
		}
		
		[Bindable]
		public function get textAlignment():String {
			switch (bbAlignment.selectedIndex) {
				case 0:
					return TextAlign.LEFT;
				case 1:
					return TextAlign.CENTER;
				case 2:
					return TextAlign.RIGHT;
				default:
					return null;
			}
		}
		
		public function set textAlignment(value:String):void {
			switch (value) {
				case TextAlign.LEFT:
					bbAlignment.selectedIndex=0;
					break;
				case TextAlign.CENTER:
					bbAlignment.selectedIndex=1;
					break;
				case TextAlign.RIGHT:
					bbAlignment.selectedIndex=2;
					break;
				default:
					bbAlignment.selectedIndex=-1;
					break;
			}
		}
		
		protected function onFontFamilyChange(ev:Event = null):void {
			var e:FloatingToolbarEvent=new FloatingToolbarEvent(FloatingToolbarEvent.FONT_FAMILY_CHANGE);
			e.newValue=(ddFontFamily.selectedItem as Font).fontName;
			e.propertyName="fontFamily";
			dispatchEvent(e);
		}
		
		protected function onFontSizeChange(ev:Event = null):void {
			var e:FloatingToolbarEvent=new FloatingToolbarEvent(FloatingToolbarEvent.FONT_SIZE_CHANGE);
			e.newValue=ddFontSize.selectedItem;
			e.propertyName="fontSize";
			dispatchEvent(e);
		}
		
		protected function onFontStyleChange(ev:Event = null):void {
			var e:FloatingToolbarEvent=new FloatingToolbarEvent(FloatingToolbarEvent.FONT_STYLE_CHANGE);
			e.newValue=fontStyle;
			e.propertyName="fontStyle";
			dispatchEvent(e);
		}
		
		protected function onWeightChange(ev:Event = null):void {
			var e:FloatingToolbarEvent=new FloatingToolbarEvent(FloatingToolbarEvent.FONT_WEIGHT_CHANGE);
			e.newValue=fontWeight;
			e.propertyName="fontWeight";
			dispatchEvent(e);
		}
		
		protected function onFontDecorationChange(ev:Event = null):void {
			var e:FloatingToolbarEvent=new FloatingToolbarEvent(FloatingToolbarEvent.TEXT_DECORATION_CHANGE);
			e.newValue=textDecoration;
			e.propertyName="textDecoration";
			dispatchEvent(e);
		}
		
		protected function onFontColorChange(ev:Event = null):void {
			var e:FloatingToolbarEvent=new FloatingToolbarEvent(FloatingToolbarEvent.FONT_COLOR_CHANGE);
			e.newValue=cpFontColor.selectedColor;
			e.propertyName="color";
			dispatchEvent(e);
		}
		
		protected function onAlignmentChange(ev:Event = null):void {
			var e:FloatingToolbarEvent=new FloatingToolbarEvent(FloatingToolbarEvent.TEXT_ALIGNMENT_CHANGE);
			e.newValue=textAlignment;
			e.propertyName="textAlign";
			dispatchEvent(e);
		}
		
		protected function onBulletsChange(ev:Event = null):void {
			var e:FloatingToolbarEvent=new FloatingToolbarEvent(FloatingToolbarEvent.BULLETS_CHANGE);
			e.newValue=btnBullets.selected;
			dispatchEvent(e);
		}
	}
}