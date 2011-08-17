package nz.component 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
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
		private var curemo:XML;
		private var dir:String;
		private var mc:MovieClip;
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
			
			infol.load(new URLRequest(FileManager.getResolvePath(value)));
		}
		public function set emotion(value:String):void
		{
			var act:Boolean = false;
			if (value == null || mc == null)
			return;
			if (info.emo.(@name == value) == undefined){
				throw -1;
				return;
			}
			curemo = info.emo.(@name == value)[0];
			_emotion = value;
			var i:int;
			if (autoSide) {
				if (curemo.sdact != undefined) {
					i = curemo.sdact[0].toString();
					act = true;
				}else if (isspeaking)
					i = curemo.sdspk[0].toString();
				else
					i = curemo.side[0].toString();
			}else {
				if (curemo.action != undefined) {
					i = curemo.action[0].toString();
					act = true;
				}else if (isspeaking)
					//mc.gotoAndStop(int(curemo.speak[0].toString()));
					i = 1;
				else
					//mc.gotoAndStop(int(curemo.normal[0].toString()));
					i = 6;
			}
			trace(i);
			if(mc.currentFrame != i)
				mc.gotoAndPlay(i);
				//mc.gotoAndStop(i);
			trace("::"+mc.currentFrame);
			
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
		protected function xml_complete(e:Event):void
		{
			info = new XML(infol.data);
			if (sex == null) sex = info.sex.toString();
			if (name == "") name = info.name.toString();
			LoaderOptimizer.dispatchLoad(this, dir+info.path.toString());
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
			
			mc = this.content as MovieClip;
			
			loadFinish = true;
			if(mc == null)
				throw -1;
			mc.stop();
			(_emotion == null) ? this.emotion = "normal" :this.emotion = _emotion;
		}
		/*override public function get name():String
		{
			return _name;
		}
		override public function set name(value:String):void
		{
			_name = value;
		}*/
		
	}

}
