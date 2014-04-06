package ui.frames 
{
	import cont.cb_over_l;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	import nz.manager.GroupManager;
	import nz.Transport;
	import nz.component.Script;
	import nz.support.GlobalKeyMap;
	import nz.support.IGroupManage;
	
	import spark.components.Button;
	import spark.components.Group;

	/**
	 * ...
	 * @author codex
	 */
	public class ChooseButton extends Group implements IGroupManage
	{
		//Interface
		private var _index:int;
		private var _group:String = "chooseFrameGroup";
		public function set index(value:int):void { _index = value; }
		public function get index():int { return _index; }
		public function set group(value:String):void { _group = value; }
		public function get group():String { return _group; }
		public function select(bl:Boolean = true):void
		{
			if (!bl) {
				overLayer.visible = false;
				return;
			}
			overLayer.visible = true;

			GlobalKeyMap.FocusButton = this as DisplayObject;
			GroupManager.getGroupManage(this.group).updateIndex(this.index, true);
		}
		public function isSelect():Boolean { return overLayer.visible ; }
		
		public var btn:Button;
		private var xml:XML;
		private var overLayer:UIComponent;
		public function ChooseButton() 
		{
			[Embed(source='../../../../lib/skins.swf',symbol='skins.cb_up')]
			var up:Class;
			[Embed(source='../../../../lib/skins.swf',symbol='skins.cb_down')]
			var down:Class;
			[Embed(source='../../../../lib/skins.swf',symbol='skins.cb_over_l')]
			var over:Class;
			btn = new Button();
			btn.setStyle("upSkin", up);
			btn.setStyle("overSkin", up);
			btn.setStyle("downSkin", down);
			addChild(btn);
			
			overLayer = new UIComponent();
			overLayer.mouseEnabled = false;
			overLayer.visible = false;
			overLayer.addChild(new cb_over_l());
			addChild(overLayer);
			
			btn.addEventListener(MouseEvent.ROLL_OVER, this_roll_over);
		}
		public function startDispatchEvent():void
		{
			var s:Script = Transport.Pro.Script as Script;
			s.insert(xml);
			s.start();
		}
		public function set linkedXML(value:XML):void
		{
			xml = value;
		}
		public function get linkedXML():XML
		{
			return xml;
		}
		public function get button():Button
		{
			return btn;
		}
		private function this_roll_over(e:MouseEvent):void 
		{
			select();
		}
	}

}
