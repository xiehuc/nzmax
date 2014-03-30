package nz.component 
{
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import lib.Igiari;
	import lib.Kurae;
	import lib.Matta;
	
	import mx.controls.SWFLoader;
	import mx.core.FlexSprite;
	
	import nz.LoaderOptimizer;
	import nz.Transport;
	import nz.enum.VoiceType;
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
		private var normal:Loader;
		private var speaking:Loader;
		private var action:Loader;
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
			normal = new Loader();
			action = new Loader();
			speaking = new Loader();
			overll.contentLoaderInfo.addEventListener(Event.COMPLETE,overll_complete);
			normal.contentLoaderInfo.addEventListener(Event.COMPLETE,overll_complete);
			action.contentLoaderInfo.addEventListener(Event.COMPLETE,emotion_loader_complete);
			
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
					action.load(new URLRequest(curemo.sdact[0].toString()));
					act = true;
				}else{
					overll.load(new URLRequest(dir+curemo.side[0].toString()));
					speaking.load(new URLRequest(dir+curemo.sdspk[0].toString()));
				}
			}else {
				if (curemo.action != undefined) {
					action.load(new URLRequest(curemo.action[0].toString()));
					act = true;
				}else{
					overll.load(new URLRequest(dir+curemo.normal[0].toString()));
					speaking.load(new URLRequest(dir+curemo.speak[0].toString()));
				}
			}
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
			if(s)
				replace_emotion(speaking);
			else
				replace_emotion(normal);
		}
		private function replace_emotion(l:Loader):void
		{
			if(container.numChildren>0)
				container.removeChildAt(0);
			container.addChild(l);
		}
		private function overll_complete(e:Event):void
		{
			var l:Loader = normal;
			normal = overll;
			overll = l;
			replace_emotion(normal);
		}
		private function emotion_loader_complete(e:Event):void
		{
			replace_emotion((e.currentTarget as LoaderInfo).loader);
		}
		protected function xml_complete(e:Event):void
		{
			info = new XML(infol.data);
			if (sex == null) sex = info.sex.toString();
			if (name == "") name = info.name.toString();
			//LoaderOptimizer.dispatchLoad(this, dir+info.path.toString());
		}
		public function voice(name:String):void
		{
			var snd:Sound = new Sound();
			snd.load(new URLRequest(info.voice.snd.(@name=name).toString()));
			snd.addEventListener(Event.COMPLETE,start_play);
			nz.enum.VoiceType
			switch(name){
				case VoiceType.OBJECTION:
					Transport.DisplayRoot.Over.addChild(new lib.Igiari());
					break;
				case VoiceType.WAIT:
					Transport.DisplayRoot.Over.addChild(new lib.Matta());
					break;
				case VoiceType.TAKE:
					Transport.DisplayRoot.Over.addChild(new lib.Kurae());
					break;
			}
		}
		private function start_play(e:Event):void
		{
			(e.currentTarget as Sound).play();
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