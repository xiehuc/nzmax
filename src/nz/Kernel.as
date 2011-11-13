package nz
{
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import lib.testing;
	import lib.type.writer;
	
	import mx.core.UIComponent;
	
	import nz.component.Background;
	import nz.component.BasicGroup;
	import nz.component.Cover;
	import nz.component.Effect;
	import nz.component.EffectTarget;
	import nz.component.HPBar;
	import nz.component.Layout;
	import nz.component.Map;
	import nz.component.Music;
	import nz.component.Role;
	import nz.component.RoleX;
	import nz.component.Script;
	import nz.component.TextPane;
	import nz.enum.Assets;
	import nz.enum.BasisEvent;
	import nz.enum.EventListBridge;
	import nz.enum.FrameInstance;
	import nz.enum.Mode;
	import nz.enum.ScriptEvent;
	import nz.enum.State;
	import nz.manager.FileManager;
	import nz.manager.FuncMan;
	import nz.manager.SAVEManager;
	import nz.support.GlobalKeyMap;
	import nz.support.IControl;
	import nz.support.ICreatable;
	import nz.support.IFileManager;
	import nz.support.IRole;
	
	import spark.components.Button;
	import spark.components.Group;

	public class Kernel extends Group
	{
		public const version:String = "0.8.1.9";
		//public const globalhost:String = "http://nzmaxi.sinaapp.com/";
		//public const globalhost:String = "http://localhost/nzmaxi/";
		private const field:String = "Kernel";
		protected var define:XML;
		protected var mode:Object;
		protected var config:XML;
		
		protected var display:Group;
		protected var cover:Cover;
		protected var func:FuncMan;
		protected var over:UIComponent;
		protected var zylogo:lib.testing;
		protected var all:Group;
		
		[Bindable]
		public var upScreen:Group;
		protected var pro:Object = new Object();
		protected var state:State;
		protected var mu:Music;
		protected var map:Map;
		protected var bg:Background;
		protected var ef:Effect;
		protected var upText:TextPane;
		protected var cuRole:IRole;
		protected var cuScript:Script;
		protected var hpbar:HPBar;
		
		protected var control:IControl;
		protected var fm:IFileManager;
		
		protected var pushError:Function;
		protected var log:Function;
		public var wrong:XML;//指正失败的事件
		
		public function Kernel()
		{
		}
		public function preinit():void
		{
			Transport.send = send_command;
			Transport.eventList = new Object();
			Transport.eventList[EventListBridge.IO_ERROR_EVENT] = global_ioerror_event;
			Transport.eventList[EventListBridge.LOAD_SCRIPT_EVENT] = loadStory;
			Transport.eventList[EventListBridge.CONTROLBUTTON_EVENT] = deal_button_event_request;
			Transport.eventList[EventListBridge.CORRECTBUTTON_REQUEST] = deal_correctbutton_request;
			FileManager.define_complete = this.define_complete;
		}
		public function init():void
		{
			define = <nz></nz>;
			func = new FuncMan();
			mode = new Object();
			mode.court = false;
			
			all = new Group();
			var bglayer:Group = new Group();
			bg = new Background();
			bglayer.addElement(bg);
			var visual_ca:Group = new Group();
			display = new Group();
			var bgexpand:Group = new Group();
			var over_demo:Background = new Background();
			visual_ca.addElement(bglayer);
			visual_ca.addElement(display);
			visual_ca.addElement(bgexpand);
			visual_ca.addElement(over_demo);
			hpbar = new HPBar();

			//var pluginlayer:Group = new Group();
			upText = new TextPane();
			over = new UIComponent();
			cover = new Cover();
			ef = new Effect();
			all.addElement(visual_ca);
			all.addElement(hpbar);
			all.addElement(upText);
			all.addElement(over);
			all.addElement(ef);
			all.addElement(cover);
			upScreen = new Group();
			upScreen.addElement(all);
			addElement(upScreen);
			over_demo.visible = false;
			upText.y = 144;
			hpbar.visible=false;
			hpbar.x = 166.5;
			hpbar.y = 8.5;
			
			log("display create");
			
			Transport.DisplayRoot["Background"] = bglayer;
			Transport.DisplayRoot["RoleLayer"] = display;
			Transport.DisplayRoot["BgExpand"] = bgexpand;
			Transport.DisplayRoot["Over"] = over;
			Transport.CreateTypeList["Role"] = Role;
			Transport.CreateTypeList["Layout"] = Layout;
			Transport.CreateTypeList["Effect"] = EffectTarget;
			Transport.CreateTypeList["RoleX"] = RoleX;
			
			mu = new Music();
			map = new Map();
			map.addEventListener(Script.SCRIPT_PAUSE, deal_event_request);
			
			//ef.addEventListener(Script.SCRIPT_START, deal_event_request);
			
			
			upText.point = this.pointRole;
			upText.addEventListener(TextPane.START_TRACE, deal_event_request);
			upText.addEventListener(TextPane.END_TRACE, deal_event_request);
			upText.addEventListener(TextPane.APPEND, deal_event_request);
			upText.addEventListener(TextPane.KEYWORD, deal_basisevent_request);
			
			cuScript = new Script();
			cuScript.addEventListener(ScriptEvent.PROGRESS, s_progress);
			//s.addEventListener(ScriptEvent.PROGRESS_END,s_progress_end);
			cuScript.addEventListener(Script.SCRIPT_TURNBACK, deal_event_request);
			cuScript.addEventListener(Script.ENVIRONMENT_CHANGE, deal_event_request);
			cuScript.addEventListener(Script.FINISH, deal_event_request);
			cuRole = new Role();
			
			log("component create");
			
			LoaderOptimizer.init();
			LoaderOptimizer.addEventListener(LoaderOptimizer.SHOW_PROGRESS, show_progress);
			
			state = new State();
			
			pro["Bg"] = bg;
			pro["Over"] = over_demo;
			pro["Music"] = mu;
			pro["Main"] = this;
			pro["upText"] = upText;
			pro["Text"] = upText;
			pro["HP"] = hpbar;
			pro["Effect"] = ef;
			pro["Map"] = map;
			pro["Script"] = cuScript;
			//下面是Effect使用
			pro["background"] = bglayer;
			pro["role"] = display;
			pro["visual"] = visual_ca;
			pro["all"] = all;
			Transport.Pro = pro;
			
			Transport.KeyMap = new Object();
			Transport.KeyMap["Enter"] = 13;
			
			/*lp = new LoaderProgress();
			lp.addEventListener(LoaderProgress.PROGRESS_FINISH, close_progress);
			LoaderOptimizer.init();
			LoaderOptimizer.addEventListener(LoaderOptimizer.SHOW_PROGRESS, show_progress);*/
			
			upScreen.addEventListener(Script.SCRIPT_START, deal_event_request);
			upScreen.addEventListener(Script.SCRIPT_PAUSE, deal_event_request);
			upScreen.addEventListener(Script.SCRIPT_INSERT, deal_basisevent_request);
			upScreen.addEventListener(Script.SCRIPT_INSERT_SIGN, deal_basisevent_request);
			upScreen.addEventListener(Assets.REMOVE_TARGET, deal_event_request);
			//this.stage.addEventListener(KeyboardEvent.KEY_UP, global_key_event_request);
			
			upScreen.addEventListener(Role.START_TALK, deal_event_request);
			upScreen.addEventListener(Role.STOP_TALK, deal_event_request);
			upScreen.addEventListener(Role.INTERCEPT_END_TRACE, deal_event_request);
			upScreen.addEventListener(Role.UNINTERCEPT_END_TRACE, deal_event_request);
			upScreen.addEventListener(Role.ROLE_ACTIVE, deal_event_request);
			upScreen.addEventListener(Role.SHOW, deal_event_request);
			upScreen.addEventListener(Assets.SYNC_ARROW, deal_basisevent_request);
			upScreen.addEventListener(Assets.SAVE_EVENT, deal_basisevent_request);
			upScreen.addEventListener(SAVEManager.RETURNTOTITLE, deal_event_request);
			//addEventListener(SAVEManager.RESTART, save_read);
			//addEventListener(SAVEManager.INIT, save_read);
			
			//addEventListener(HPBar.HIDE_LIGHT, deal_event_request);
			
			Script.registProcess("create",create,null,["*","type"]);
			Script.registProcess("court",court_start,court_end,null);
			Script.registProcess("import",define_import,null,["path"]);
			Script.registProcess("define",blank);
			Script.registProcess("remove",remove,null,["id","type"]);
			Script.registProcess("run",run,null,["define"]);
			Script.registProcess("inquire",inquire_start,inquire_end,null);
			Script.registProcess("deter",deter_start,deter_end,null);
			func.setFunc("flyto", { type:Script.SingleParams} );
			func.setFunc("task", { type:Script.SingleParams } );
			func.setFunc("checklink", {down:false,progress:false, type:Script.SingleParams } );
			func.setFunc("plugin", { type:Script.ComplexParams, progress:false } );
			func.setFunc("pluginUnload", { type:Script.SingleParams } );
			func.setFunc("addEvent",{type:Script.ComplexParams});
			func.setFunc("xmlns", { type:Script.IgnoreProperties } );
			
			SAVEManager.ready();
			FileManager.initComlib();
			/*SAVEManager.addEventListener(SAVEManager.READ_SUCCESS, save_read);
			SAVEManager.addEventListener(SAVEManager.READ_FAILED, save_read);
			SAVEManager.addEventListener(SAVEManager.PREPARE_DATA, save_read);*/
		}
		public function addEvent(child:XML,event:String):void
		{
			this[event] = child;
			if(event=="wrong")
				wrong.appendChild(<Control popPage=""/>);
		}
		public function blank():void
		{
			
		}
		public function inquire_start():void
		{
			cuScript.go("in");
			Mode.mainState = Mode.STATE_INQUIRE;
			control.pushPage(FrameInstance.INQUIREFRAME);
		}
		public function inquire_end():void
		{
			Mode.mainState = Mode.STATE_NORMAL;
			control.popPage();
		}
		public function court_start():void
		{
			cuScript.go("in");
			run("court");
			cuScript.start();
		}
		public function court_end():void
		{
			
		}
		public function afterinit():void//执行后续初始化工作
		{
			run("init");
		}
		public function link(obj:*):void//连接Control
		{
			if(obj is IControl){
				control = obj;
				Transport.c = control;
				pro["Control"] = control;
			}
		}
		public function define_import(path:String):void
		{
			var l:URLLoader = new URLLoader(new URLRequest(FileManager.getResolvePath(path)));
			l.addEventListener(Event.COMPLETE,define_complete);
		}
		public function regist(str:String,func:Function):void
		{
			switch(str){
				case "error":
					pushError = func;
					Transport.eventList[EventListBridge.PUSH_ERROR] = pushError;
					Transport.pushError = pushError;
					break;
				case "log":
					log = func;
					break;
			}
		}
		public function initConfig(path:String= ""):void
		{//第一层载入:载入config;
			var loader:URLLoader = new URLLoader();
			var url:URLRequest = new URLRequest(path+"config.xml");
			loader.addEventListener(Event.COMPLETE,config_complete);
			loader.load(url);
			
			//FileManage.setDirectory();
		}
		public function loadStory(infoPath:String):void
		{
			FileManager.setDirectory(infoPath.substring(0,infoPath.lastIndexOf("/")+1));
			var l:URLLoader = new URLLoader();
			l.load(new URLRequest(infoPath));
			l.addEventListener(Event.COMPLETE,load_story_complete);
		}
		private function load_story_complete(e:Event):void
		{
			FileManager.setStoryInfo(new XML(e.currentTarget.data));
			cuScript.loadScript(FileManager.getStoryPath());
			cuScript.addEventListener(Event.COMPLETE,start_story );
			afterinit();
		}
		private function define_complete(e:Event):void
		{
			//在FileManager加载完成comlib的import标签之后调度
			var x:XML = new XML(e.currentTarget.data);
			define.appendChild(x.children());
		}
		private function config_complete(e:Event):void 
		{
			//第二层载入:载入control,;
			config = new XML(e.currentTarget.data);
			nz.support.GlobalKeyMap.init(config.keyMap[0]);
		}
		private function pointRole(link:String):void
		{
			pro[link].active();
		}
		private function send_command(cmd:*,_stop:Boolean = false):void
		{
			pro["Script"].receive(cmd,_stop);
		}
		private function global_ioerror_event(e:IOErrorEvent):void
		{
			pushError(e.toString());
		}
		private function show_progress(e:BasisEvent):void 
		{
		}
		public function create(list:XMLList,type:String):void
		{
			var cl:Class;
			var muliclass:Boolean = false;
			var name:String;
			
			if (type != "") {
				muliclass = false;
				cl = Transport.CreateTypeList[type];
			}else {
				muliclass = true;
			}
			for (var i:int = 0; i < list.length(); i++) {
				var ct:Object = Transport.CreateTypeList;
				if (muliclass) cl = Transport.CreateTypeList[list[i].@type.toString()];
				var target:ICreatable = new cl();
				if(target.regit) (target as Object).linkName = list[i].localName();
				pro[list[i].localName()] = target;
				if (target.autoAddDisplayRoot) target.displayParent = target.displayParent;//强制设置
				target.creationComplete();
			}
			cuScript.go("in");
		}
		private function s_progress(e:ScriptEvent):void 
		{
			var info:Object;
			var downBoolean:Boolean = true;
			var progressBoolean:Boolean = true;
			var progressIndex:int = 0;
			var cmd:String;
			//错误检查
			if (e.name == "Script")
				return;
			while (progressIndex < e.value.length()) {
				cmd = e.value[progressIndex].name();
				info = pro[e.name].func.getFunc(cmd);
				if (info.type == undefined) {
					pushError(e.name+" 没有 "+cmd+" 属性或方法\n   请仔细检查.");
					return;
				}
				if (info.down == false) downBoolean = false;
				if (info.progress == false) progressBoolean = false;
				switch(info.type) {
					case Script.SingleParams:
						pro[e.name][cmd](e.value[progressIndex].toString());
						progressIndex++;
						break;
					case Script.NoParams:
						pro[e.name][cmd]();
						progressIndex++;
						break;
					case Script.Properties:
						pro[e.name][cmd] = e.value[progressIndex].toString();
						progressIndex ++;
						break;
					case Script.ComplexParams:
						pro[e.name][cmd](e.node, e.value[progressIndex].toString());
						progressIndex++;
						break;
					case Script.BooleanProperties:
						pro[e.name][cmd] = Assets.stringToBoolean(e.value[progressIndex].toString());
						progressIndex++;
						break;
					case Script.IgnoreProperties:
						progressIndex++;
						break;
				}
			}
			e.currentTarget.downbreak = !downBoolean;
		}
		/*private function save_read(e:Event):void 
		{
			switch(e.type) {
				case SAVEManager.READ_SUCCESS:
					control.updateSaver(SAVEManager.getData("Info", "Info"));
					break;
				case SAVEManager.RESTART:
					control.gotoPage(FrameInstance.PLAYFRAME);
					si.parent.visible = false;
					cuScript = pro["Script"];
					cuScript.start();
					break;
				case SAVEManager.INIT:
					control.gotoPage(FrameInstance.PLAYFRAME);
					var xml:XML = SAVEManager.getData("Create") as XML;
					trace(xml.toXMLString());
					var script:Script = new Script();
					cuScript = script;//暂时更改cuScript以提高兼容性
					script.oriData = xml;
					script.addEventListener(ScriptEvent.PROGRESS, s_progress);
					script.addEventListener(ScriptEvent.PROGRESS_END, s_progress_end);
					script.addEventListener(Script.SCRIPT_STOP, createScriptStop);
					script.start();
					for (var item:String in pro) {
						if (pro[item] is ISaveObject) {
							(pro[item] as ISaveObject).loadData(item);
						}
					}
					control.loadData("Control");
					si.parent.visible = false;
					break;
				case SAVEManager.READ_FAILED:
					cuScript = pro["Script"];
					control.updateSaver();
					break;
				case SAVEManager.PREPARE_DATA:
					SAVEManager.cleanData();
					for (var savetarget:String in pro) {
						if (pro[savetarget] is ISaveObject) {
							(pro[savetarget] as ISaveObject).saveData(savetarget);
						}
					}
					control.saveData("Control");
					var bitmap:BitmapData = new BitmapData(130, 96.5,true,0xffffff);
					bitmap.draw(this.stage,new Matrix(130/256,0,0,96.5/192));
					var date:Date = new Date();
					var s:String = date.getMonth() + "." + date.getDate() + " " +date.toLocaleTimeString();
					var png:PNGEncoder = new PNGEncoder();
					var o:Object = [png.encode(bitmap), s];
					SAVEManager.appendRowData("Info", o, "Info");
					control.updateSaver(o);
					break;
			}
		}*/
		private function update_court_i(e:Event):void 
		{
			/*var r:Role = e.currentTarget as Role;
			if (r.getOutput("court")[r.linkName] == undefined) {
				return;
			}
			var c:Class = r.getOutput("court")[r.linkName] as Class;
			var bd:BitmapData = new c(256,192);
			var b:Bitmap = new Bitmap(bd);
			pro[r.linkName + "i_layout"].source = b;*/
		}
		private function roleOnCourt(link:String):Boolean
		{
			//对于flyto的辅助判断
			if (link == "l" || link == "p" || link == "w") {
				return true;
			}
			return false;
		}
		public function run(define:String):void
		{
			task(define);
		}
		public function task(t:String):void
		{
			switch(t) {
				case "证言开始":
					cuScript.stop();
					zylogo = new lib.testing();
					over.addChild(zylogo);
					var lts:lib.test_start = new lib.test_start();
					over.addChild(lts);
					TweenLite.delayedCall(2.5, continue_task);
					break;
				case "询问开始":
					cuScript.stop();
					hpbar.visible = true;
					control.pushPage(FrameInstance.NULLFRAME);
					//var lsh:DisplayObject = pro["l"].headMotion(Position.LEFT);
					//var jsh:DisplayObject = pro["p"].headMotion(Position.RIGHT);
					//over.addChild(lsh);
					//over.addChild(jsh);
					
					var lis:lib.inquire_start = new lib.inquire_start();
					over.addChild(lis);
					//addChild(upText);//把Uptext提到顶端
					Mode.playButtonEnabled = true;
					//TweenLite.delayedCall(2.5, Assets.removeTargets, [[jsh,lsh,lis]]);
					TweenLite.delayedCall(2.5, control.popPage, []);
					break;
				case "证言结束":
					over.removeChild(zylogo);
					zylogo = null;
					break;
				case "询问结束":
					state["ask"] = false;
					hpbar.visible = false;
					break;
				default:
					if (define.define.(@name == t) != undefined) {
						var txml:XML = define.define.(@name == t)[0];
						cuScript.receive(txml);
					}
					break;
			}
		}
		private function continue_task():void
		{
			Mode.playButtonEnabled = true;
		}
		public function flyto(value:String):void {
			if (cuRole.linkName == value) {
				pointRole(value);
				return;
			}
			if (roleOnCourt(cuRole.linkName) && roleOnCourt(value)) {
				cuScript.stop();
				cuRole = pro[value];
				Transport.CurrentRole = pro[value];
				upText.show(false);
				upText.name = cuRole.name;
				TweenLite.to(display.parent, 1.5, { x: -pro[value].x , onComplete:script_start } );
			}else {
				pointRole(value);
			}
		}
		
		public function remove(id:String=null,type:String=null):void
		{
			if(id != null && id != ""){
				var list:Array = id.split(";");
				for each(var link:String in list) {
					var target:ICreatable = pro[link] as ICreatable;
					target.remove();
					if (target.autoAddDisplayRoot) pro[link].parent.removeElement(target);
					pro[link] = null;
				}
			}
			if(type != null && type != ""){
				for (var item:String in pro) {
					if (pro[item] is ICreatable && pro[item].type == type) {
						var tg:ICreatable = pro[item] as ICreatable;
						tg.remove();
						if(tg.autoAddDisplayRoot) pro[item].parent.removeElement(tg);
						pro[item] = null;
					}
				}
			}
		}
		private function script_start():void
		{
			cuScript.start();
			Mode.playButtonEnabled = false;
		}
		private function start_story(e:Event):void
		{
			e.currentTarget.removeEventListener(Event.COMPLETE,start_story);
			script_start();
			all.removeElement(cover);
			cover = null;
			
		}
		private function deal_event_request(e:Event):void
		{
			switch(e.type) {
				case Script.SCRIPT_START:
					script_start();
					break;
				case Script.SCRIPT_PAUSE:
					cuScript.stop();
					Mode.playButtonEnabled = false;
					break;
				case Script.FINISH:
					/*FileManager.writeFinish();
					FileManager.rescan();
					dispatchEvent(new Event(SAVEManager.RETURNTOTITLE));*/
					cuScript.stop();
					break;
				case TextPane.START_TRACE:
					cuScript.stop();
					Mode.playButtonEnabled = false;
					if(upText.realName == cuRole.name){
						cuRole.speak(true);
						if (upText.name != "" && upText.autoSound) {
							(cuRole.sex == "male") ? mu.overStream(new lib.type.male()):mu.overStream(new lib.type.female());
						}
					}
					if (upText.name == "" && upText.autoSound) {
						mu.overStream(new writer());
					}
					break;
				case TextPane.END_TRACE:
					mu.overStop();
					cuRole.speak(false);
					Mode.playButtonEnabled = true;
					break;
				case TextPane.APPEND:
					mu.overStop();
					cuRole.speak(false);
					cuScript.go("down");
					cuScript.start();
					Mode.playButtonEnabled = false;
					break;
				case Role.INTERCEPT_END_TRACE:
					upText.addEventListener(TextPane.END_TRACE, e.target.zoomEndSpeakEvent);
					break;
				case Role.UNINTERCEPT_END_TRACE:
					upText.removeEventListener(TextPane.END_TRACE, e.target.zoomEndSpeakEvent);
					break;
				case Role.ROLE_ACTIVE:
					display.parent.x = -pro[e.target.linkName].x;
					if (e.target.visible == false) {
						e.target.visible = true;
						if (e.target.group == cuRole.group) {
							cuRole.visible = false;
						}else{
							for each(var r:* in pro) {
								if (r is IRole && r.visible == true && r.group == e.target.group && r.linkName != e.target.linkName ) {
									r.visible = false;
									break;
								}
							}
						}
					}
					cuRole = e.target as IRole;
					upText.name = cuRole.name;
					Transport.CurrentRole = e.target;
					break;
				case Assets.REMOVE_TARGET:
					e.target.removeEventListener(Assets.REMOVE_TARGET, deal_event_request);
					var t:MovieClip = e.target as MovieClip;
					t.gotoAndStop(1);
					t.parent.removeChild(t);
					break;
				case SAVEManager.RETURNTOTITLE:
					//bg.unload();
					mu.stop();
					cuScript.unload();
					upText.show(false);
					ef.cleanAllFilters();
					upText.cleanPush();
					for (var i:String in pro) {
						if (pro[i] is ICreatable) {
							remove(i);
						}
					}
					//startMotion.play();
					//control.gotoPage(FrameInstance.FILEFRAME);
					break;
			}
		}
		private function deal_basisevent_request(e:BasisEvent):void 
		{
			switch(e.type) {
				case Script.SCRIPT_INSERT:
					cuScript.insert(e.data as XML);
					break;
				case Script.SCRIPT_INSERT_SIGN:
					cuScript.sign();
					cuScript.gotoSign(e.data as String);
					break;
				case Assets.SYNC_ARROW:
					upText.wait_arr_vi = e.data;
					break;
				case Assets.SAVE_EVENT:
					SAVEManager.prepare();
					SAVEManager.save(e.data as int);
					break;
				case TextPane.KEYWORD:
					var cmd:Array = (e.data as String).split("|");
					switch(cmd[0]) {
						case "vib":ef.vibration(display.parent, Assets.nullReplace(cmd[1],2));break;
						case "fsrn":ef.flashScreen(this, Assets.nullReplace(cmd[1],0.5));break;
						case "p":upText.insidePause(Assets.nullReplace(cmd[1], 0.5)); break;
						case "s":upText.speed = Assets.nullReplace(cmd[1], 15); break;
						case "cls":upText.cleanText();break;
						case "snd":mu.attachTextSound(cmd[1]); break;
						case "emo":
							cuRole.emotion = cmd[1];
							cuRole.speak(true);
							break;
					}
					break;
			}
		}
		private function deal_button_event_request(type:String):void 
		{
			switch(type) {
				case Assets.PLAYBUTTON_CLICK:
					if (upText.state == State.EMERGENCY) {
						upText.deal_pause();
						upText.state = State.NORMAL;
					}else {
						Mode.playButtonEnabled = false;
						if (cuScript.oriData.name().localName == "upText" || cuScript.oriData.name().localName == "Text") {
							if (cuScript.oriData.@text != undefined || cuScript.oriData.@appendText != undefined){
								cuScript.go("down");
							}
						}
						cuScript.start();
					}
					break;
				case Assets.PREVBUTTON_CLICK:
					if (cuScript.oriData.parent().@hide != undefined) {
						cuScript.go("out");
					}
					cuScript.go("up");
					cuScript.start();
					break;
				case Assets.DETERBUTTON_CLICK:
					if(cuScript.hasChild("deter")){
						cuScript.enter("deter");
						cuScript.start();
					}
					break;
				case Assets.OBJECTBUTTON_CLICK:
					control.pushPage(FrameInstance.OBJECTFRAME);
					Mode.objectState = Mode.OBJECT_INQUIRE;
					break;
			}
		}
		private function deal_correctbutton_request(link:String):void
		{
			cuScript.stop();
			mu.delayVolumn();
			pro["l"].voice("异议");
			var successObject:Boolean = false;
			control.pushPage(FrameInstance.PLAYFRAME);
			if (cuScript.hasChild("object")) {
				for each(var item:XML in cuScript.oriData.object) {
					if (item.@answer == link) {
						cuScript.receivexml(item,false,false);
						successObject = true;
						break;
					}
				}
				if (!successObject) {
					cuScript.receivexml(wrong,false,false);
				}
			}else {
				cuScript.receivexml(wrong,false,false);
			}
		}
		public function deter_start():void
		{
			control.pushPage(FrameInstance.PLAYFRAME);
			pro["l"].voice("等下");
			cuScript.go("in");
		}
		public function deter_end():void
		{
			control.popPage();
			//跳转由Script负责
		}
	}
}