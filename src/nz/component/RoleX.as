package nz.component 
{
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import mx.controls.SWFLoader;
	import mx.core.FlexSprite;
	
	import nz.LoaderOptimizer;
	import nz.Transport;
	import nz.manager.FileManager;
	import nz.support.IRole;

	/**
	 * ...
	 * @author codex
	 */
	public class RoleX extends Layout implements IRole
	{
		private var _group:String = "auto";
		public function set group(value:String):void { 
			_group = value; 
		}
		public function get group():String { return _group; }
		private var infol:URLLoader;
		private var info:XML;
		private var _linkName:String;
		private var _sex:String = null;
		private var _name:String = null;
		private var _emotion:String = null;
		private var overll:Loader;
		private var container:FlexSprite;
		private var curemo:XML;
		private var dir:String;
		private var mc:Object;
		public var isspeaking:Boolean;
		public var autoSide:Boolean = false;
		protected var loadFinish:Boolean = false;
		public function RoleX() 
		{
			super();
			autoAddDisplayRoot = true;
			_parent = "RoleLayer";
			type = "RoleX";
			regit = true;
			name="";
			container = new FlexSprite();
			this.source = container;
			overll = new Loader();
			overll.contentLoaderInfo.addEventListener(Event.COMPLETE,overll_complete);
			
			this.mouseEnabled = this.mouseChildren = false;
			isspeaking = false;
			infol = new URLLoader();
			info = new XML();
			infol.addEventListener(Event.COMPLETE, xml_complete);
			
			func.setFunc("name", { type:Script.Properties } );
			func.setFunc("active", {type:Script.NoParams } );
			func.setFunc("emotion", { type:Script.Properties } );
			func.setFunc("loop", { type:Script.Properties } );
			func.setFunc("voice", { down:true, progress:false, type:Script.SingleParams } );
			func.setFunc("autoSide", { type:Script.BooleanProperties } );
			func.setFunc("sex", { type:Script.Properties } );
			func.setFunc("zoom", { type:Script.NoParams } );
			func.setFunc("group", { type:Script.Properties } );
		}
		override public function set path(value:String):void
		{
			_path = value;
			loadFinish = false;
			dir = FileManager.getResolvePath(value);
			dir = dir.slice(0, dir.lastIndexOf('/')+1);
			var p:String = FileManager.getResolvePath(value);
			infol.load(new URLRequest(FileManager.getResolvePath(value)));
		}
		public function set emotion(value:String):void
		{
			var act:Boolean = false;
			if (value == null)
			return;
			if (info.emo.(@name == value) == undefined){
				throw -1;
				return;
			}
			curemo = info.emo.(@name == value)[0];
			_emotion = value;
			var path:String;
			if (autoSide) {
				if (curemo.sdact != undefined) {
					path = curemo.sdact[0].toString();
					act = true;
				}else if (isspeaking)
					path = curemo.sdspk[0].toString();
				else
					path = curemo.side[0].toString();
			}else {
				if (curemo.action != undefined) {
					path = curemo.action[0].toString();
					act = true;
				}else if (isspeaking)
					//mc.gotoAndStop(int(curemo.speak[0].toString()));
					//i = 1;
					path = curemo.speak[0].toString();
				else
					//mc.gotoAndStop(int(curemo.normal[0].toString()));
					path = curemo.normal[0].toString();
			}
			overll = new Loader();
			overll.load(new URLRequest(dir+path));
			overll.contentLoaderInfo.addEventListener(Event.COMPLETE,overll_complete);
		}
		public function get emotion():String
		{
			return _emotion;
		}
		public function active():void
		{
			dispatchEvent(new Event(Role.ROLE_ACTIVE, true, false));
			
			Transport.CurrentRole = this;
		}
		public function speak(s:Boolean):void
		{
			isspeaking = s;
			emotion = _emotion;
		}
		private function overll_complete(e:Event):void
		{
			if(container.numChildren>0)
			container.removeChildAt(0);
			container.addChild(overll);
		}
		protected function xml_complete(e:Event):void
		{
			info = new XML(infol.data);
			if (sex == null) sex = info.sex.toString();
			if (name == "") name = info.name.toString();
			//LoaderOptimizer.dispatchLoad(this, dir+info.path.toString());
		}
		public function get sex():String
		{
			return _sex;
		}
		public function set sex(s:String):void
		{
			_sex = s;
		}
		public function get linkName():String
		{
			return _linkName;
		}
		public function set linkName(s:String):void
		{
			_linkName = s;
		}
		override protected function loader_complete(e:Event):void
		{
			loadFinish = true;
			
			(_emotion == null) ? this.emotion = "normal" :this.emotion = _emotion;
		}
	}
}
import flash.display.MovieClip;

class Emo
{
	public var normal:MovieClip;
	public var speak:MovieClip;
	public var action:MovieClip;
	public var side:MovieClip;
	public var sdspk:MovieClip;
	public var sdact:MovieClip;
}