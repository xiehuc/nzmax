package ui.frames 
{
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	
	import cont.Cross_;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import mx.collections.ArrayCollection;
	import mx.effects.Tween;
	import mx.events.FlexEvent;
	
	import nz.manager.GroupManager;
	import nz.Transport;
	import nz.enum.PluginsType;
	import nz.manager.TimeManager;
	import nz.support.GlobalKeyMap;
	import nz.support.IPlugin;
	
	import spark.components.Group;

	/**
	 * 控制选择画面的类.
	 * 
	 * <table class="innertable">
	 * <tr><th>标签</th><td>值</td></tr>
	 * <tr><th>Link:</th><td>无</td></tr>
	 * <tr><th>插件类型:</th><td>Control显示插件</td></tr>
	 * <tr><th>插件位置:</th><td>内部插件</td></tr>
	 * <tr><th>可存档:</th><td>否</td></tr>
	 * </table>
	 * @see Control#chooseSet()
	 * @author CodeX
	 */
	public class ChooseFrame extends Group implements IPlugin
	{
		private var _type:String = "";
		private var cross:Cross_;
		private var btnLayer:Group;
		private var length:int;
		private var blankHeight:Number;
		private var fmt:TextFormat;
		private var blankX:Number;
		private var tm:TimeManager;
		private var gm:GroupManager;
		/**@private */
		public function ChooseFrame() 
		{
			blankX = (256 - 170) / 2;
			btnLayer = new Group();
			btnLayer.width = 256;
			btnLayer.height = 192;
			addChild(btnLayer);
			fmt = new TextFormat();
			fmt.font = "微软雅黑";
			fmt.size = 14;
			fmt.color = 0x69472e;
			
			tm = new TimeManager();
			tm.addEventListener(TimeManager.MOTION_COMPLETE, tm_complete);
			var dp:ArrayCollection = new ArrayCollection();
			dp.addItem( { type:TimeManager.TYPE_STILL, last:0.3, state: { alpha:0 }} );
			dp.addItem( { type:TimeManager.TYPE_STILL, last:0.3, state: { alpha:1 }} );
			tm.motion = dp;
			tm.repeat = 3;
			
			gm = new GroupManager("chooseFrameGroup");
			
			this.addEventListener(FlexEvent.SHOW, show_event);
		}
		
		private function show_event(e:FlexEvent):void 
		{
			for (var i:int = 0; i < btnLayer.numChildren; i++) {
				TweenLite.from(btnLayer.getChildAt(i), 0.5, { alpha:0,z:-200,rotationX:-90} );
			}
		}
		/**@private */
		public function set currentButtonIndex(value:int):void
		{
			gm.currentIndex = value;
		}
		/**@private */
		public function get currentButtonIndex():int
		{
			return gm.currentIndex;
		}
		/**@private */
		public function get pluginType():String
		{
			return PluginsType.CONTROL_DISPLAY_TYPE;
		}
		/**@private */
		public function init(xml:XML,blank:String=null):void
		{
			this.stage.addEventListener(KeyboardEvent.KEY_UP, key_event);
			//cleanButton();
			var list:XMLList = xml.children();
			length = list.length();
			blankHeight = Math.max((192-28*length) / (length + 1),10);
			for (var i:int = 0; i < list.length(); i++) {
				var cb:ChooseButton = new ChooseButton();
				cb.index = i;
				cb.button.label = list[i].@label;
				cb.button.setStyle("textFormat", fmt);
				cb.button.addEventListener(MouseEvent.CLICK, cb_btn_click);
				cb.linkedXML = list[i].children()[0];
				cb.x = blankX;
				cb.y = blankHeight*(i+1)+28*i;
				btnLayer.addChild(cb);
				gm.dataProvider.push(cb);
			}
			currentButtonIndex = 0;
		}
		
		private function key_event(e:KeyboardEvent):void 
		{
			switch(e.keyCode) {
				case GlobalKeyMap.ConfirmButton:
					tm.target = (GlobalKeyMap.FocusButton as ChooseButton).button as DisplayObject;
					tm.start();
				break;
				case GlobalKeyMap.UpArrow:
					deltaMove( -1);
				break;
				case GlobalKeyMap.DownArrow:
					deltaMove(1);
				break;
			}
		}
		private function deltaMove(i:int):void
		{
			if (i == -1 && currentButtonIndex == 0) currentButtonIndex = btnLayer.numChildren - 1;
			else if (i == 1 && currentButtonIndex == btnLayer.numChildren - 1) currentButtonIndex = 0;
			else currentButtonIndex += i;
		}
		/**@private */
		public function close():void
		{
			this.stage.removeEventListener(KeyboardEvent.KEY_UP, key_event);
			Transport.Pro["Control"].activePlugin(null);
		}
		/**@private */
		public function cleanButton():void
		{
			for (var i:int = btnLayer.numChildren - 1; i >= 0; i--) {
				btnLayer.removeChildAt(i);
			}
			gm.dataProvider = new Array();
		}
		/**@private */
		public function get currentButton():ChooseButton
		{
			return btnLayer.getChildAt(currentButtonIndex) as ChooseButton;
		}
		private function cb_btn_click(e:MouseEvent):void 
		{
			tm.target = e.currentTarget as DisplayObject;
			tm.start();
		}
		private function tm_complete(e:Event):void 
		{
			cleanButton();
			(tm.target.parent as ChooseButton).startDispatchEvent();
			close();
		}
		/**@private */
		public function set type(value:String):void { }
		/**@private */
		public function get type():String { return "" }
		/**@private */
		public function get content():DisplayObject
		{
			return btnLayer as DisplayObject;
		}
		
	}

}
