package controls
{
	import com.Assets;
	import com.FileManage;
	import com.FuncMan;
	import com.nz.EventListBridge;
	import com.nz.IGroupManage;
	import com.SAVEManager;
	import com.Script;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import com.greensock.TweenLite;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import com.nz.GlobalKeyMap;
	import com.nz.ICreatable;
	import com.nz.ISaveObject;
	import com.nz.Transport;
	import mx.controls.Alert;
	import mx.core.FlexSprite;
	import mx.core.UIComponent;
	import cont.*;
	/**
	 * 控制证物的基类.
	 * 
	 * <table class="innertable">
	 * <tr><th>标签</th><td>值</td></tr>
	 * <tr><th>Link:</th><td>无</td></tr>
	 * <tr><th>可创建:</th><td>是</td></tr>
	 * <tr><th>创建类型:</th><td>无</td></tr>
	 * <tr><th>可存档:</th><td>是</td></tr>
	 * </table>
	 * @author CodeX
	 */
	public class PaneCell extends UIComponent implements ISaveObject,ICreatable,IGroupManage
	{
		/**@private */
		static public const NOTICE:String = "notice_event";
		/**@private */
		static public const CREATION_COMPLETE:String = "creation_complete";
		/**@private */
		static public const REMOVE:String = "remove_event";
		/**@private */
		static public const SIDEBAR_CHECK:String = "sidebar_check";
		/**@private */
		static public const EXPAND_MODE_OPEN:String = "expand_mode_open";
		/**@private */
		static public const EXPAND_MODE_CLOSE:String = "expand_mode_close";
		/**@private */
		static public const SYNC_PANE:String = "sync_pane";
		/**@private */
		static public const DETAIL_REG:String = "detail_reg";
		
		/**@private */
		public var field:String;
		/**@private */
		public var func:FuncMan;
		private var _des:String;
		private var _path:String;
		private var _detail:XML;
		/**@private */
		public var addDescriptXML:XML;
		/**@private */
		public var linkName:String;
		/**@private */
		public var detailType:String;
		/**@private */
		public var page:int;
		/**@private */
		public var column:int;
		/**@private */
		public var row:int;
		/**@private */
		public var expanded:Boolean = false;
		/**@private */
		public var hasDetail:Boolean = false;
		/**@private */
		public var background:FlexSprite;
		private var border:FlexSprite;
		private var loader:Loader;
		private var useHtml:Boolean;
		
		private var title:Title_;
		private var descript:Descript_;
		private var reg:Object;
		/**
		 * 设置版本序号.
		 * 暂时好像用不到.以后可能会使用
		 */
		public var version:Number=1;//Version
		
		//Interface
		private var _regit:Boolean=true;
		private var _autoAddDisplayRoot:Boolean=true;
		private var _type:String;
		private var _group:String;
		private var _index:int;
		/**@private */
		protected var _parent:String;
		/**@private */
		public function set autoAddDisplayRoot(value:Boolean):void { _autoAddDisplayRoot = value; }
		/**@private */
		public function get autoAddDisplayRoot():Boolean { return _autoAddDisplayRoot; }
		/**
		 * 设置创建类型.
		 */
		public function set type(value:String):void { _type = value; }
		public function get type():String { return _type; }
		/**@private */
		public function set regit(value:Boolean):void { _regit = value; }
		/**@private */
		public function get regit():Boolean { return _regit };
		/**@private */
		public function set group(value:String):void { _group = value; }
		/**@private */
		public function get group():String { return _group; }
		/**@private */
		public function set index(value:int):void { _index = value; }
		/**@private */
		public function get index():int { return _index };
		/**
		 * 设置父级显示对象.
		 * @see com.Layout#displayParent
		 */
		public function set displayParent(value:String):void
		{
			_parent = value;
			Transport.DisplayRoot[value].addChild(this as DisplayObject);
		}
		public function get displayParent():String {	return _parent; }
		/**@private */
		public function saveData(link:String):void
		{
			var obj:Object = new Object();
			for (var key:String in func.getRow()) {
				var item:Object = func.getFunc(key);
				obj.type = this.type;
				if (item.type == Script.Properties || item.type == Script.BooleanProperties) {
					obj[key] = this[key].toString();
				}
			}
			SAVEManager.appendCreateData(link,obj);
		}
		/**@private */
		public function loadData(link:String):void { };
		/**@private */
		public function creationComplete():void
		{
			dispatchEvent(new Event(CREATION_COMPLETE,true,true));
		}
		/**@private */
		public function remove():void
		{
			dispatchEvent(new Event(REMOVE, true, true));
		}
		/**@private */
		public function select(bl:Boolean = true):void
		{
			if (!bl) {
				border.visible = false;
				return;
			}
			border.visible = true;
			GlobalKeyMap.FocusButton = this;
			GroupManage.getGroupManage(this.group).updateIndex(index,true)
		}
		/**@private */
		public function isSelect():Boolean	{return border.visible;}
		
		/**@private */
		public function PaneCell():void
		{
			reg = new Object();
			loader = new Loader();
			useHtml = false;
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, Transport.eventList[EventListBridge.IO_ERROR_EVENT]);
			addChild(loader);
			
			border = new FlexSprite();
			border.graphics.beginFill(0x000000, 0);
			border.graphics.lineStyle(1, 0xffff00, 1, true);
			border.graphics.drawRect( -1, -1, 42, 42);
			border.graphics.endFill();
			border.visible = false;
			addChild(border);
			
			title = new Title_();
			title.x = 23 - 128;
			title.y = 34 - 106;
			descript = new Descript_();
			descript.alpha = 0;
			descript.x = 88 - 128;
			descript.y = 92 - 106;
			
			background = new FlexSprite();
			background.graphics.beginFill(0x7b2e02, 0.7);
			background.graphics.lineStyle(0.5, 0x000000, 1, true);
			background.graphics.drawRoundRect(10-128, 63-106, 230, 80, 5,5);
			background.graphics.endFill();
			addChildAt(background, 0);
			background.visible = false;
			
			this.addEventListener(MouseEvent.ROLL_OVER, this_roll_over);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this_complete);
			
			func = new FuncMan();
			func.setFunc("version", { type:Script.Properties } );
			func.setFunc("name", { type:Script.Properties } );
			func.setFunc("path", { type:Script.Properties } );
			func.setFunc("des", { type:Script.Properties } );
			func.setFunc("useHtml", { type:Script.BooleanProperties } );
			func.setFunc("type", { type:Script.IgnoreProperties } );
			func.setFunc("detail", { type:Script.ComplexParams } );
			func.setFunc("notice", { type:Script.NoParams } );
		}
		/**
		 * 设置详细说明.
		 */
		public function set des(value:String):void
		{
			_des = value;
			if (useHtml)
				descript._tf.htmlText = Assets.formatText(_des);
			else
				descript._tf.text = _des;
		}
		public function get des():String
		{
			return _des;
		}
		
		/**
		 * 设置显示名称.
		 */
		override public function set name(value:String):void
		{
			title._tf.text = value;
		}
		override public function get name():String
		{
			return title._tf.text;
		}
		/**
		 * 设置图像路径.
		 */
		public function set path(value:String):void
		{
			_path = value;
			loader.load(new URLRequest(FileManage.getResolvePath(value)));
		}
		public function get path():String
		{
			return _path;
		}
		/**
		 * 设置详细信息.
		 * @example 以photo类型做例子.
		 * <listing version="3.0">
		 * &lt;zhaopian_oi detail="photo" &gt;
		 *     &lt;content &gt;photo.jpg&lt;/content &gt;
		 * &lt;/Control &gt;
		 * </listing>
		 * @param	content
		 * @param	type 详细证物类型
		 * @see com.nz.ObjectItemType
		 */
		public function detail(content:XML,type:String):void
		{
			_detail = content.content[0];
			hasDetail = true; 
			detailType = type;
		}
		/**@private */
		public function getDetailContent():XML
		{
			return _detail;
		}
		/**
		 * 生成添加证物的动画.
		 * 随时都可以使用.
		 */
		public function notice():void
		{
			dispatchEvent(new Event(NOTICE, true, true));
		}
		/**@private */
		public function imageCopy():BitmapData
		{
			return (loader.content as Bitmap).bitmapData.clone();
		}
		/**@private */
		public function expand(tween:Boolean = false):void
		{
			expanded = true;
			removeChild(border);
			reg.x = this.x;
			reg.y = this.y;
			loader.x = reg.x % 256;
			loader.y = reg.y;
			if (loader.x > 128) {
				loader.x -= 256;
			}
			this.x = 0;
			this.y = 0;
			addChild(title);
			addChild(descript);
			descript._tf.visible = true;
			if (tween) {
				TweenLite.to(loader, 1.5, { x:20 - 128, y:73 - 106, width:64, height:64 } );
				TweenLite.to(title, 1.5, { x:88 - 128, y:73 - 106, width:146 } );
				TweenLite.to(descript, 1.5, { alpha:1 } );
				}else {
				loader.x = 20 - 128; loader.y = 73 - 106; loader.width = 64; loader.height = 64;
				title.x = 88 - 128; title.y = 73 - 106; title.width = 146;
				descript.alpha = 1;
			}
		}
		/**@private */
		public function unexpand(tween:Boolean = false):void
		{
			expanded = false;
			if (tween) {
				var tx:Number = reg.x % 256;
				if (tx >= 128) {
					tx -= 256;
				}
				TweenLite.to(loader, 1.5, { x:tx, y:reg.y, width:40, height:40} );
				TweenLite.to(title, 1.5, { x:23 - 128, y:34 - 106, width:210 } );
				TweenLite.to(descript, 1.6, { alpha:0,onComplete:tween_complete } );
				descript._tf.visible = false;
				//保证loader,title 完成了动画
			}else {
				removeChild(title);
				removeChild(descript);
				loader.x = 0; loader.y = 0; loader.width = 40; loader.height = 40;
				title.x = 23 - 128; title.y = 34 - 106; title.width = 210;
				descript.alpha = 0;
				this.x = reg.x;
				this.y = reg.y;
				addChild(border);
			}
		}
		private function tween_complete():void
		{
			removeChild(title);
			removeChild(descript);
			loader.x = 0;
			loader.y = 0;
			this.x = reg.x;
			this.y = reg.y;
			addChild(border);
		}
		private function this_roll_over(e:MouseEvent):void 
		{
			this.select();
		}
		private function this_complete(e:Event):void 
		{
			if(expanded == false){
				loader.width = loader.height = 40;
			}else {
				loader.width = loader.height = 64;
			}
		}
	}
}
