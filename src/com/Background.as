package com
{
	import com.nz.BasicSP;
	import com.nz.EventListBridge;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import com.nz.ISaveObject;
	import com.nz.Transport;
	import mx.core.UIComponent;
	/**
	 * 用来控制背景显示的类.
	 * 
	 * <table class="innertable">
	 * <tr><th>标签</th><td>值</td></tr>
	 * <tr><th>Link:</th><td>Bg</td></tr>
	 * <tr><th>可创建:</th><td>否</td></tr>
	 * <tr><th>可存档:</th><td>是</td></tr>
	 * </table>
	 * @author CodeX
	 */
	public class Background extends BasicSP implements ISaveObject
	{
		/**@private */
		public const field:String = "global";
		/**@private */
		public var content:Loader;
		/**@private */
		public var blackBack:Sprite;
		/**@private */
		public var linkName:String;
		/**@private */
		public var overDemoMode:Boolean = false;
		/**@private */
		public var path:String = "";
		/**@private */
		public function Background() 
		{
			this.mouseEnabled = this.mouseChildren = false;
			content = new Loader();
			content.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, Transport.eventList[EventListBridge.IO_ERROR_EVENT]);
			blackBack = new Sprite();
			blackBack.graphics.beginFill(0x000000);
			blackBack.graphics.drawRect(0, 0, 256, 192);
			blackBack.graphics.endFill();
			blackBack.visible = false;
			addChild(blackBack);
			addChild(content);
			func.setFunc("load", { type:Script.SingleParams } );
			func.setFunc("loadDemo", { type:Script.SingleParams, down:true, progress:false } );
			func.setFunc("unload", { type:Script.NoParams } );
		}
		/**
		 * 读取图片并显示
		 * @param	path 图片所在路径
		 */
		public function load(value:String):void
		{
			if (value == "") {
				return;
			}
			path = value;
			LoaderOptimizer.dispatchLoad(content, FileManage.getResolvePath(path),true);
			//content.load(new URLRequest(FileManage.getResolvePath(path)));
		}
		/**
		 * 读取动画并显示.
		 * 格式必须是swf.
		 * 读取成功后会显示动画并暂停Script.
		 * 直到动画结束.
		 * <p>一般是用来载入开始动画的.</p>
		 * @param	path 动画路径
		 */
		public function loadDemo(value:String):void
		{
			this.visible = true;
			load(value);
			Transport.Pro["upText"].show(false);
			content.contentLoaderInfo.addEventListener(Event.COMPLETE, attachEndEvent);
		}
		/**
		 * 取消读取的图片
		 */
		public function unload():void
		{
			path = null;
			content.unload();
			if (overDemoMode) {
				this.visible = false;
			}
		}
		/**@private */
		public function saveData(link:String):void
		{
			SAVEManager.appendData(link, { load:this.path } );
		}
		/**@private */
		public function loadData(link:String):void { };
		/**@private */
		public function set blankBackEnable(value:Boolean):void
		{
			blackBack.visible = value;
		}
		/**@private */
		public function get blankBackEnable():Boolean
		{
			return blackBack.visible;
		}
		private function attachEndEvent(e:Event):void 
		{
			var m:MovieClip = content.content as MovieClip;
			m.addFrameScript(m.totalFrames - 1, demo_end_event);
		}
		private function demo_end_event():void
		{
			content.unload();
			this.visible = false;
			dispatchEvent(new Event(Script.SCRIPT_START, true));
		}
		/**@private */
	}
	
}