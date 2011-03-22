package com
{
	import codex.assets.Position;
	import codex.events.BasisEvent;
	import codex.manager.GroupManage;
	import com.nz.EventListBridge;
	import com.nz.IGroupManage;
	import flash.utils.getDefinitionByName;
	import lib.Guilty;
	import lib.Igiari;
	import lib.Kurae;
	import lib.Matta;
	import lib.Notguilty;
	import lib.tsnds.objection;
	import com.nz.ISaveObject;
	import com.nz.Transport;
	import com.nz.VoiceType;
	import com.nz.ICreatable;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import codex.media.GUILoader;
	import com.greensock.TweenLite;
	import lib.speedline;
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	import mx.flash.UIMovieClip;
	/**
	 * 直接控制swf角色的类.提供了丰富的控制功能.
	 * 
	 * <table class="innertable">
	 * <tr><th>标签</th><td>值</td></tr>
	 * <tr><th>Link:</th><td>无</td></tr>
	 * <tr><th>可创建:</th><td>是</td></tr>
	 * <tr><th>创建类型:</th><td>Role</td></tr>
	 * <tr><th>可存档:</th><td>是</td></tr>
	 * </table>
	 * @author CodeX
	 */
	public class Role extends Layout
	{
		public const version:String = "0.8.1.9"
		private var _group:String = "auto";
		/**
		 * 设置显示组.
		 * 每一个组只能有一个可以显示的角色.
		 * 通过设置visible=true.此Role所属组的其他Role就会自动的影藏.
		 * @default auto
		 */
		public function set group(value:String):void { 
			_group = value; 
		}
		public function get group():String { return _group; }
		/**@private */
		static public const ROLE_ACTIVE:String = "role_active";
		/**@private */
		static public const START_TALK:String = "start_talk";
		/**@private */
		static public const STOP_TALK:String = "stop_talk";
		/**@private */
		static public const EMOTION_CHANGE:String = "emotion_change";
		/**@private */
		static public const INTERCEPT_END_TRACE:String = "intercept_end_trace";//用来拦截upText的endTrace
		/**@private */
		static public const UNINTERCEPT_END_TRACE:String = "unintercept_end_trace";
		/**@private */
		static public const SHOW:String = "role_show";
		/**@private */
		public const field:String = "Role";//域,存档用
		/**
		 * 设置性别.影响到文字输出时选择哪种声音.
		 * <p>如果角色swf里面没有定义的话.默认选择male</p>
		 * <p>可用值为male,female</p>
		 */
		public var sex:String;
		/**
		 * 设置表情循环次数.只对action的表情有效.
		 * @example
		 * <listing version="3.0">
		 * &lt;c loop="3" emotion="hammer" /&gt;
		 * </listing>
		 */
		public var loop:int = 1;
		/**
		 * 设置是否自动加入"side_"在emotion的前面.
		 * <p>为了分别表示人物的普通状态,和法庭的侧面的状态.
		 * 用side_前缀加在emotion来区分.比如side_normal.</p>
		 * <p>但是,在法庭上的时候,lawer当然是不会使用到普通状态的.
		 * 为了简化.创建了这个功能.设置了这个之后.就不用加side_了</p>
		 * <p>在courtSet时已经自动的将l,p,a的autoSide打开了</p>
		 */
		public var autoSide:Boolean = false;
		/**@private*/
		protected var childFunc:Object;//本来是FuncMan 但是错误提示无法将FuncMan@xxx转化为FuncMan
		/**@private*/
		protected var _emotion:String;
		/**@private*/
		protected var mc:MovieClip;
		/**@private*/
		protected var labelToIndex:Object;
		private var _name:String = "";
		/**@private */
		public var linkName:String;
		/**@private */
		public var isspeaking:Boolean;
		private var _speedline:MovieClip;
		private var zoomImage:Sprite;
		private var zoomClass:Class;
		private var zoomSpeakingClass:Class;
		protected var loadFinish:Boolean = false;
		/**@private */
		public function Role() 
		{
			//Interface
			super();
			autoAddDisplayRoot = true;
			_parent = "RoleLayer";
			type = "Role";
			regit = true;
			
			this.mouseEnabled = this.mouseChildren = false;
			zoomImage = new Sprite();
			zoomImage.y = 192;
			labelToIndex = new Object();
			
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
		/**@private */
		override public function creationComplete():void
		{
			this.visible = false;
		}
		/**@private */
		override public function remove():void { };
		/**
		 * 启动放大的表情.
		 * 好像NDS里面是在上屏幕的.我忘记了.我设定的是下屏幕.
		 * 很早以前就有的功能了.现在又不想改过去了.
		 * 个人觉得.下屏幕还是很帅的.
		 * 这个是过一定的时间久会取消的.
		 */
		public function zoom():void
		{
			_speedline = new lib.speedline();
			zoomImage.addChild(_speedline);
			zoomClass = childFunc.getFunc("zoom").mc as Class;
			zoomSpeakingClass = childFunc.getFunc("zoom_speaking").mc as Class;
			zoomImage.addChild(new zoomSpeakingClass() as DisplayObject);
			Transport.DisplayRoot.Over.addChild(zoomImage);
			dispatchEvent(new Event(INTERCEPT_END_TRACE, true));
		}
		/**@private */
		public function zoomEndSpeakEvent(e:Event):void 
		{
			zoomImage.removeChildAt(1);
			zoomImage.addChild(new zoomClass() as DisplayObject);
			removeEventListener("script_start", zoomEndSpeakEvent);
			TweenLite.delayedCall(2, zoomDisable);
		}
		private function zoomDisable():void
		{
			zoomImage.removeChildAt(1);
			zoomImage.removeChildAt(0);
			zoomClass = null;
			zoomSpeakingClass = null;
			Transport.DisplayRoot.Over.removeChild(zoomImage);
			dispatchEvent(new Event(UNINTERCEPT_END_TRACE, true));
		}
		/**
		 * 设定 表情.
		 * 表情.也就是emotion.是标示角色的不同的动作,心理的.在Nzmax里.表情分两大类.
		 * <p>一类是action.是动作.没有说话的.upText也不会显示.等到一段时间后.脚本会继续执行.表情也会自动切换回normal.</p>
		 * <p>另一类是speak.这个包括了两种表情.在文字输出时自动切换到_speaking的.输出结束后自动切换回去.</p>
		 * <p>你还会看到还有一种.是speak和action都有的.比如说handondesk,handondesk_action.加了一个_action后缀来区分.</p>
		 * <p>普通的action切换回的是normal,而handondesk_action的切换回的是handondesk.</p>
		 * <p>normal是每个角色都必须拥有的表情.是默认值</p>
		 */
		public function set emotion(value:String):void
		{
			var emo:String = value;
			autoSide ? emo = "side_" + value: emo = value;
			if (labelToIndex[emo] == undefined) {
				if(loadFinish){
					Transport.getEvent(EventListBridge.PUSH_ERROR)(this.linkName + "(Role) 没有" + emo + "的表情(emotion)\n请仔细检查");
				}else {
					_emotion = value;
				}
				return;
			}
			_emotion = emo;
			mc.gotoAndStop(emo);
			if (childFunc.getFunc(emo).pause == true) {
				mc.addEventListener(Event.FRAME_CONSTRUCTED, action_start);
				active();
				dispatchEvent(new Event(Script.SCRIPT_PAUSE, true));
				Transport.Pro["upText"].show(false);
			}
		}
		/**@private*/
		protected function action_start(e:Event):void
		{
			mc.removeEventListener(Event.FRAME_CONSTRUCTED, action_start);
			if (childFunc.getFunc(emotion).snd != null) {
				var scstr:String = childFunc.getFunc(emotion).snd;
				var sc:Class = this.content.loaderInfo.applicationDomain.getDefinition(scstr) as Class;
				var snd:Sound = new sc();
				snd.play();
			}
			var cl:MovieClip = mc.getChildAt(0) as MovieClip;
			cl.addFrameScript(cl.totalFrames - 1, action_end);
		}
		public function get emotion():String
		{
			if (autoSide) {
				return _emotion.slice(5, _emotion.length);
			}
			return _emotion;
		}
		/**@private */
		public function hasemotion(value:String):Boolean
		{
			var emo:String;
			autoSide ? emo = "side_" + value: emo = value;
			if (labelToIndex[emo] != undefined) {
				return true;
			}
			return false;
		}
		override public function set path(value:String):void
		{
			_emotion = null;
			loadFinish = false;
			super.path = value;
		}
		/**
		 * 激活Role.
		 * 有n个动作.1.visible设置为true.2.把当前角色设定为此.3.把镜头指向此.4.把名字框的值设置为此Role的name.
		 * <p>所以说一般推荐使用active而不是visible.</p>
		 * <p>程序有许多地方会自动调用active.所以你需要使用这个的时候还是比较少.</p>
		 * <p>upText的point直接调用这个active.</p>
		 */
		public function active():void
		{
			dispatchEvent(new Event(Role.ROLE_ACTIVE, true,false));
			Transport.CurrentRole = this;
		}
		/**@private */
		public function speak(s:Boolean):void
		{
			if(s){
				if (labelToIndex[_emotion + "_speaking"] != undefined) {
					isspeaking = true;
					mc.gotoAndStop(_emotion + "_speaking");
				}
			}else{
				if (isspeaking) {
					mc.gotoAndStop(_emotion);
				}
			}
		}
		/**@private */
		public function gotoAndStop(frame:Object, scene:String = null):void
		{
			mc.gotoAndStop(frame, scene);
		}
		/**@private */
		public function get childClip():MovieClip
		{
			return mc;
		}
		/**
		 * 设定角色名称.
		 * 会和upText.realName比较以决定当前角色是否要说话.
		 * 在point时会自动更新名字框的值.
		 */
		override public function get name():String
		{
			return _name;
		}
		override public function set name(value:String):void
		{
			_name = value;
		}
		/**@private */
		public function get head():DisplayObject
		{
			var cl:Class = childFunc.getFunc("head").mc as Class;
			var h:DisplayObject = new cl() as DisplayObject;
			return h;
		}
		/**@private */
		public function getOutput(link:String):Object
		{
			return childFunc.getFunc(link) as Object;
		}
		/**
		 * 高声呼喊吧.
		 * 当要使用异议的时候就是设置的这个.
		 * 有五个可选值:异议,等下,接招,无罪,有罪.
		 * 前三个大家已经很熟悉了.有罪无罪是给c用的.
		 * @param	name
		*/
		public function voice(name:String):void
		{
			Transport.send("<Script stop=''/>")
			Transport.Pro.upText.show(false);
			switch(name) {
				case "异议":
					getSound(VoiceType.IGIARI).play();
					Transport.DisplayRoot.Over.addChild(new Igiari());
				break;
				case "等下":
					getSound(VoiceType.MATTA).play();
					Transport.DisplayRoot.Over.addChild(new Matta());
				break;
				case "接招":
					getSound(VoiceType.KURAE).play();
					Transport.DisplayRoot.Over.addChild(new Kurae());
				break;
				case "无罪":
					Transport.DisplayRoot.Over.addChild(new Notguilty());
				break;
				case "有罪":
					Transport.DisplayRoot.Over.addChild(new Guilty());
				break;
			}
		}
		/**@private */
		public function getSound(name:String):Sound
		{
			var cl:Class;
			if (childFunc.getFunc(name).snd == undefined) {
				cl = objection;
			}else {
				cl = childFunc.getFunc(name).snd as Class;
			}
			var snd:Sound = new cl() as Sound;
			return snd;
		}
		/**@private */
		public function headMotion(position:String):DisplayObject
		{
			var h:DisplayObject = this.head;
			if (position == Position.LEFT) {
				h.y = 198 + 17;
				TweenLite.from(h, 1, { x: -256 } );
			}else {
				h.rotationY = 180;
				h.x = 256;
				h.y = 198 + 105;
				TweenLite.from(h, 1, { x:512 } );
			}
			return h;
		}
		/**@private */
		override protected function loader_complete(e:Event):void
		{
			mc = this.content as MovieClip;
			loadFinish = true;
			childFunc = (mc.func == undefined)?new FuncMan():mc.func;
			for (var i:int = 1; i <= mc.currentLabels.length; i++) {
				labelToIndex[mc.currentLabels[i-1].name] = i;
			}
			(_emotion == null) ? this.emotion = "normal" :this.emotion = _emotion;
			if(this.sex == null)
			(mc.sex == undefined) ? this.sex = "male":this.sex = mc.sex;
			 //强制把之前emotion没有执行完的补上
		}
		/**@private*/
		protected function action_end():void
		{
			if (loop > 1) {
				loop --;
			}else {
				if(emotion.indexOf("_action")!= -1){
					var emo:String = emotion.slice(0, emotion.indexOf("_"));
					if (hasemotion(emo)) {
						emotion = emo;
					}else {
						emotion = "normal";
					}
				}else {
					emotion = "normal";
				}
				dispatchEvent(new Event(Script.SCRIPT_START, true));
			}
		}
	}
}
