package nz.component
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	
	import mx.controls.SWFLoader;
	import mx.core.FlexSprite;
	import mx.core.UIComponent;
	
	import nz.manager.FileManager;
	import nz.manager.FuncMan;
	import nz.LoaderOptimizer;
	import nz.manager.SAVEManager;
	import nz.Transport;
	import nz.component.Script;
	import nz.enum.EventListBridge;
	import nz.support.ICreatable;
	import nz.support.ILoaderOptimized;
	import nz.support.ISaveObject;

	/**
	 * 用来加载显示单张图片的类.
	 * 
	 * <table class="innertable">
	 * <tr><th>标签</th><td>值</td></tr>
	 * <tr><th>Link:</th><td>无</td></tr>
	 * <tr><th>可创建:</th><td>是</td></tr>
	 * <tr><th>创建类型:</th><td>Layout</td></tr>
	 * <tr><th>可存档:</th><td>是</td></tr>
	 * </table>
	 * @see com.Role
	 * @author CodeX
	 */
	public class Layout extends SWFLoader implements ICreatable,ISaveObject,ILoaderOptimized
	{
		protected var _path:String = "";
		/**@private */
		public var func:nz.manager.FuncMan;
		/**@private */
		public var autoVi:Boolean = true;
		//Interface
		/**@private */
		protected var _parent:String;
		private var _regit:Boolean;
		private var _autoAddDisplayRoot:Boolean;
		private var _type:String;
		/**
		 * 设置父级显示对象.
		 * 可以使用的值有:
		 * <ul>
		 * <li><b>Background:</b>背景层.此层有一个固定的对象:Bg</li>
		 * <li><b>RoleLayer:</b>人物显示层.Role的默认值</li>
		 * <li><b>BgExpand:</b>背景扩展层.</li>
		 * <li><b>Over:</b>覆盖层.此层经常用来存放一些临时显示对象</li>
		 * </ul>
		 */
		public function set displayParent(value:String):void
		{
			_parent = value;
			Transport.DisplayRoot[value].addElement(this);
		}
		public function get displayParent():String
		{
			return _parent;
		}
		/**@private */
		public function set regit(value:Boolean):void { _regit = value; }
		/**@private */
		public function get regit():Boolean { return _regit; }
		/**@private */
		public function set autoAddDisplayRoot(value:Boolean):void { _autoAddDisplayRoot = value; }
		/**@private */
		public function get autoAddDisplayRoot():Boolean { return _autoAddDisplayRoot; }
		/**
		 * 设置创建类型.
		 * Layout的创建类型是Layout.
		 */
		public function set type(value:String):void { _type = value; }
		public function get type():String { return _type; }
		/**@private */
		public function creationComplete():void { }
		/**@private */
		public function remove():void 
		{
			Transport.DisplayRoot[displayParent].removeChild(this as DisplayObject);
		}
		/**@private */
		public function saveData(link:String):void
		{
			var obj:Object = new Object();
			
			for (var key:String in func.getRow()) {
				var item:Object = func.getFunc(key);
				obj.type = this.type;
				if (item.type == Script.Properties || item.type == Script.BooleanProperties) {
					obj[key] = this[key];
				}
			}
			SAVEManager.appendCreateData(link,obj);
		}
		/**@private */
		public function loadData(link:String):void { };
		/**@private */
		public function Layout() 
		{
			regit = false;
			autoAddDisplayRoot = false;
			type = "Layout";
			_parent = "";
			this.addEventListener(Event.COMPLETE, loader_complete);
			//this.addEventListener(IOErrorEvent.IO_ERROR, Transport.eventList[EventListBridge.IO_ERROR_EVENT]);
			func = new FuncMan();
			func.setFunc("x", {type:Script.Properties } );
			func.setFunc("y", {type:Script.Properties } );
			func.setFunc("alpha", { type:Script.Properties } );
			func.setFunc("visible", { type:Script.BooleanProperties } );
			func.setFunc("autoVi", { type:Script.BooleanProperties } );
			func.setFunc("path", { type:Script.Properties } );
			func.setFunc("displayParent", { type:Script.Properties } );
			func.setFunc("type", { type:Script.IgnoreProperties } );
		}
		/**
		 * 设定横坐标值.
		 */
		override public function set x(value:Number):void
		{
			super.x = value;
		}
		/**
		 * 设定纵坐标值.
		 */
		override public function set y(value:Number):void
		{
			super.y = value;
		}
		/**
		 * 设定透明度值.
		 */
		override public function set alpha(value:Number):void
		{
			super.alpha = value;
		}
		/**
		 * 设定是否显示.
		 */
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
		}
		/**@private */
		protected function loader_complete(e:Event):void
		{
			
		}
		/**
		 * 设置路径.
		 * 设置即载入.
		 * <p><b>注意:</b>此处的路径是相对路径.首先程序在当前剧本目录下查找.如果找不到.自动转到comlib下查找.</p>
		 */
		public function set path(value:String):void
		{
			_path = value;
			LoaderOptimizer.dispatchLoad(this, FileManager.getResolvePath(value));
		}
		public function get path():String
		{
			return _path;
		}
	}
}
