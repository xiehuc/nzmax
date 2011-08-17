package ui.frames 
{
	import flash.display.DisplayObject;
	
	import mx.core.UIComponent;
	
	import nz.enum.PluginsType;
	import nz.support.IPlugin;
	
	import spark.components.Group;
	import spark.components.supportClasses.TextBase;

	/**
	 * 控制report证物类型的类.
	 * 
	 * <table class="innertable">
	 * <tr><th>标签</th><td>值</td></tr>
	 * <tr><th>Link:</th><td>无</td></tr>
	 * <tr><th>插件类型:</th><td>Control详细插件</td></tr>
	 * <tr><th>插件位置:</th><td>内部插件</td></tr>
	 * <tr><th>可存档:</th><td>否</td></tr>
	 * </table>
	 * @see com.nz.ObjectItemType#REPORT
	 * @see controls.PaneCell#detail()
	 * @author CodeX
	 */
	public class ReportFrame extends Group implements IPlugin
	{
		private var _type:String = "report";
		private var text:TextBase;
		/**@private */
		public function ReportFrame() 
		{
			super();
			var black:UIComponent = new UIComponent();
			black.graphics.beginFill(0x000000,0.8);
			black.graphics.drawRect(0, 0, 256, 192);
			black.graphics.endFill();
			addChild(black);
			text = new TextBase();
			text.y = 20;
			text.setStyle("color", "#ffffff");
			text.width = 256;
			text.height = 145;
			addChild(text);
		}
		/**@private */
		public function get content():DisplayObject
		{
			return text as DisplayObject
		}
		/**@private */
		public function get type():String
		{
			return _type;
		}
		/**@private */
		public function set type(value:String):void
		{
			_type = value;
		}
		/**@private */
		public function get pluginType():String
		{
			return PluginsType.CONTROL_DETAIL_TYPE;
		}
		/**@private */
		public function init(xml:XML,blank:String=null):void
		{
			text.text = xml.toString();
		}
		/**@private */
		public function close():void { };
		
	}

}