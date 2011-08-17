package ui
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import nz.Transport;
	import nz.component.Script;
	import nz.manager.FuncMan;
	import nz.manager.SAVEManager;
	import nz.support.ICreatable;
	import nz.support.IGroupManage;
	import nz.support.ISaveObject;

	public class PaneItem extends EventDispatcher implements ICreatable, ISaveObject, IGroupManage
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
		
		
		public var name:String;
		public var path:String;
		public var des:String;
		public var useHTML:Boolean;
		public var func:FuncMan;
		public var linkName:String;
		
		
		//--- Interface Start --
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
			
			var dp:ArrayCollection = nz.Transport.DisplayRoot[value] as ArrayCollection;
			dp.addItem(this);
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
			//dispatchEvent(new Event(REMOVE, true, true));
			var dp:ArrayCollection = Transport.DisplayRoot[_parent] as ArrayCollection;
			//dp.removeItemAt(
		}
		/**@private */
		public function select(bl:Boolean = true):void
		{
		}
		/**@private */
		public function isSelect():Boolean	{return false}
		//---Interface End---
		public function PaneItem()
		{
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
	}
}