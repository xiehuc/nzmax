package com
{
	import codex.assets.State;
	import codex.events.BasisEvent;
	import codex.media.GUILoader;
	import com.nz.EventListBridge;
	import com.nz.ILoaderOptimized;
	import com.nz.Transport;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import com.greensock.TweenLite;
	import com.nz.ISaveObject;
	import mx.controls.Alert;
	/**
	 * 用来控制剧本的类.
	 * 
	 * <table class="innertable">
	 * <tr><th>标签</th><td>值</td></tr>
	 * <tr><th>Link:</th><td>Script</td></tr>
	 * <tr><th>可创建:</th><td>否</td></tr>
	 * <tr><th>可存档:</th><td>是</td></tr>
	 * </table>
	 * @author CodeX
	 */
	public class Script extends EventDispatcher implements ISaveObject,ILoaderOptimized
	{
		[Event(name = "progress_end", type = "com.ScriptEvent")]
		[Event(name = "progress", type = "com.ScriptEvent")]
		[Event(name = "script_stop", type = "com.Script")]
		[Event(name = "environment_change", type = "com.Script")]
		[Event(name = "script_turnback", type = "com.Script")]
		[Event(name = "complete", type = "flash.events.Event")]
		/**@private */
		static public const SCRIPT_PAUSE:String = "script_pause";
		/**@private */
		static public const SCRIPT_START:String = "script_start";
		/**@private */
		static public const SCRIPT_INSERT:String = "script_insert";
		/**@private */
		static public const SCRIPT_INSERT_SIGN:String = "script_insert_sign";
		/**@private */
		static public const SCRIPT_TURNBACK:String = "script_turnback";
		/**@private */
		static public const SCRIPT_STOP:String = "script_stop";
		/**@private */
		static public const FINISH:String = "finish";
		/**@private */
		static public const ENVIRONMENT_CHANGE:String = "environment_change";
		/**@private */
		static public const SingleParams:String = "singleparams";
		/**@private */
		static public const NoParams:String = "noparams";
		/**@private */
		static public const Properties:String = "properties";
		/**@private */
		static public const ComplexParams:String = "complexparams";
		/**@private */
		static public const BooleanProperties:String = "booleanProperties";
		/**@private */
		static public const IgnoreProperties:String = "ignorepProperties";
		/**@private */
		public const field:String = "global";
		private var permit:Object;
		private var _func:FuncMan;
		private var urlLoader:URLLoader = new URLLoader();
		private var _script:XML;
		private var _cuXML:XML;
		private var _state:String;
		private var _sign_store:Object;
		/**
		 * 用于控制Control的询问界面和普通界面的自动辅助.
		 * <p>可选值:询问</p>
		 * 详解:
		 * <listing version="3.0">
		 *  &lt;Script environment="询问" go="in"&gt;
		 *      &lt;upText text="..."/&gt;    &lt;!---------1--&gt;
		 *      &lt;upText text="..."/&gt;    &lt;!---------2--&gt;
		 *      &lt;Script go="in"&gt;
		 *          &lt;upText text="..."/&gt; &lt;!---------3--&gt;
		 *      &lt;/Script&gt;
		 *  &lt;/Script&gt;
		 * </listing>
		 * <p>第1,2句的upText被包裹在environment="询问"里.
		 * 所以执行它们的时候界面会自动跳转到询问界面.</p>
		 * <p>第3句没有包裹在environment里面.
		 * 所以执行它的时候会跳转到普通界面</p>
		 */
		public var environment:String = "";
		/**@private */
		public var index:int;
		/**@private */
		public var length:int;
		/**@private */
		public var path:Array;
		/**@private */
		public var filePath:String;
		private var autostart:Boolean;
		/**@private */
		public var scriptPath:String;
		/**@private */
		public function Script() 
		{
			path = new Array();
			permit = new Object();
			
			_sign_store = new Object();
			_func = new FuncMan();
			func.setFunc("go", { down:false,progress:true,type:Script.SingleParams} );
			func.setFunc("stop", { down:false, progress:false, type:Script.NoParams } );
			func.setFunc("finish", { down:false, progress:false, type:Script.NoParams } );
			func.setFunc("pause", { down:true, progress:false, type:Script.NoParams } );
			func.setFunc("load", { type:Script.SingleParams } );
			func.setFunc("jump", { down:false, progress:true, type:Script.SingleParams } );
			func.setFunc("pathto", { down:false, progress:true, type:Script.SingleParams } );
			func.setFunc("enter", { down:false, progress:true, type:Script.SingleParams } );
			func.setFunc("sign", { type:Script.SingleParams } );
			func.setFunc("gotoSign", { down:false, progress:false, type:Script.SingleParams } );
			func.setFunc("delay", { down:true, progress:false, type:Script.SingleParams } );
			func.setFunc("label", { type:Script.IgnoreProperties } );
			func.setFunc("environment", { type:Script.IgnoreProperties } );
			func.setFunc("search", { type:Script.SingleParams, progress:false, down:false } );
			func.setFunc("showChapter", { type:Script.SingleParams } );
			func.setFunc("openNode", { type:Script.SingleParams } );
			func.setFunc("hideNode", { down:false,  type:Script.SingleParams } );
			urlLoader.addEventListener(Event.COMPLETE, complete);
			urlLoader.addEventListener(ProgressEvent.PROGRESS, dispatchProgress);
		}
		
		private function dispatchProgress(e:Event):void 
		{
			dispatchEvent(e);
		}
		/**
		 * 用于打开锁死节点.
		 * @see #hideNode()
		 * @param	permit 自己设定的节点名
		 */
		public function openNode(p:String):void
		{
			permit[p] = true;
		}
		/**
		 * 设置锁死节点.一般用于询问的时候.
		 * <p>详解:一段标准的询问语句:</p>
		 * <listing version="3.0">
		 *	&lt;Script go="in" environment="询问"&gt;
		 *		&lt;upText point="w" text="第1句话..."/&gt;
		 *		&lt;upText point="w" text="第2句话...,第一次不要动.第二次时候用威慑"/&gt;
		 *			&lt;deter&gt;
		 *				&lt;upText point="l" text="隐藏的第3句话开启了"/&gt;
		 *				&lt;Main openNode="ask2_hide_ss"/&gt;
		 *			&lt;/deter&gt;
		 *		&lt;/upText&gt;
		 *		&lt;Script hideNode="ask2_hide_ss" environment="询问"&gt;
		 *			&lt;upText point="w" text="第3句话...,出示证物徽章"/&gt;
		 *		&lt;/Script&gt;
		 *	&lt;/Script&gt;
		 * </listing>
		 * 本来执行的时候是不会显示的ask2_hide_ss的节点的.
		 * 但是openNode之后就会显示了.
		 * @param	permit 自己设定的节点名
		 */
		public function hideNode(p:String):void
		{
			if (permit[p] == true) {
				go("in");
			}else {
				go("down");
			}
		}
		private function send_environmentchange_event():void 
		{
			dispatchEvent(new Event(ENVIRONMENT_CHANGE));
		}
		/**
		 * go跳转语句.
		 * 六个方向参数构成了.Script跳转的基础.
		 * <ul>
		 * <li><b>up:</b>向上跳转.一般只会在程序里面用到.你用不到的.</li>
		 * <li><b>down:</b>向下跳转.一般只会在程序里面用到.你用不到的.</li>
		 * <li><b>in:</b>跳转入节点.遇到节点程序不会自动跳入.<i>Script里面有些方法可以.</i>
		 * 				所以需要加上一句go="in".可以参见hideNode的例子.</li>
		 * <li><b>out:</b>.只是跳出节点.一般只会在程序里面用到.你用不到的.因为会死循环的.</li>
		 * <li><b>outdown:</b>.跳出节点的升级版.跳出后自动down一下.就可以继续顺利执行了.
		 * 				<p>大多数时候都有自动辅助.你可以不必输入了.</p></li>
		 * <li><b>turnback:</b>跳回.比如说触发了NOHP了.Script会跳到DEFAULT_NOHP节点.
		 * 				最后再加上这句就跳回来继续执行了.</li>
		 * </ul>
		 * 
		 * @param	direction 方向参数.
		 */
		public function go(value:String,check:Boolean = true):void
		{
			switch(value) {
				case "up":
					if (index -1 >= 0) {
						_cuXML = _cuXML.parent().children()[index - 1];
						index--;
					}
				break;
				case "in":
					path.push(index);
					index = 0; length = _cuXML.children().length();
					_cuXML = _cuXML.children()[0]; 
					if(check) environmentCheck();
				break;
				case "down":
					if (index + 1 < length) {
						_cuXML = _cuXML.parent().children()[index + 1];
						index++;
					}else {
						var n:String = _cuXML.parent().name().localName;
						if (n == "deter" || n == "object" || n == "exist" || n == "nonexist"|| n== "point" || n=="cb") {
							this.jump("out;out;down");
						}else {
							this.go("outdown");
						}
					}
				break;
				case "out":
					index = path.pop(); 
					_cuXML = _cuXML.parent().parent().children()[index];
					length = _cuXML.parent().children().length();
					dispatchEvent(new ScriptEvent(ScriptEvent.PROGRESS_END, false, false, _cuXML.name().localName));
					if (check) environmentCheck();
				break;
				case "outdown":
					if (_cuXML.parent().parent() == null) {
						this.stop();
					}else{
						this.go("out");
						this.go("down");
					}
				break;
				case "turnback":
					//要使用的话先要用一次storePath
					gotoSign("xml");
				break;
			}
		}
		/**@private */
		public function stop():void
		{
			_state = State.STOP;
			dispatchEvent(new Event(SCRIPT_STOP));
		}
		/**
		 * 剧本终止语句.
		 * 有2个动作:1.把剧本移到已完成区.2.返回开始选择画面.
		 */
		public function finish():void
		{
			dispatchEvent(new Event(FINISH));
		}
		/**
		 * 多剧本的时候使用的.
		 * <p>详解:</p>
		 * <p>Info.xml文件里面</p>
		 * <listing version="3.0">
		 *	&lt;Script label="第一章" &gt;first.xml&lt;/Script&gt;
		 *	&lt;Script label="第一章" hide="true"&gt;second.xml&lt;/Script&gt;
		 * </listing>
		 * <p>first.xml文件要结束了</p>
		 * <listing version="3.0">
		 *	&lt;Script showChapter="1" /&gt;
		 *	&lt;Script finish="" /&gt;
		 * </listing>
		 * @param	index 章节序号,从0开始
		 */
		public function showChapter(index:int):void
		{
			FileManage.writeShowChapter(index);
		}
		/**@private */
		public function pause():void
		{
			//等效于设定 func.setFunc({down:true,progress:false});
			_state = State.PAUSE;
		}
		/**
		 * 高级多次跳转.
		 * 一次可以之心许多个go跳转.用;分隔.
		 * @param	value 跳转复合指令
		 * @example
		 * <listing version="3.0">
		 *	&lt;Script jump="out;out;down" /&gt;
		 * </listing>
		 */
		public function jump(value:String):void
		{
			var ar:Array = value.split(";");
			for (var i:int = 0; i < ar.length; i++) {
				go(ar[i],false);
			}
			environmentCheck();
		}
		/**@private */
		public function pathto(value:Object):void
		{
			_cuXML = _script;
			var i:int;
			if(value is String){
				path = [];
				var ar:Array = value.split(";");
				for (i = 0; i < ar.length; i++) {
					path.push(int(ar[i]));
					_cuXML = _cuXML.children()[int(ar[i])];
				}
			}else if (value is Array) {
				path = value as Array;
				for (i = 0; i < path.length;i++){
					_cuXML = _cuXML.children()[path[i]];
				}
			}
			index = path.pop();
			length = _cuXML.parent().children().length();
			environmentCheck();
		}
		/**@private */
		public function enter(value:String):void
		{
			//enter 与 go("in") 的区别是 enter可以有选择.go(in)就只是第一项.
			path.push(index);
			path.push(0);
			_cuXML = _cuXML[value][0].children()[0];
			length = _cuXML.children().length();
			index = 0;
			length = _cuXML.parent().children().length();
			environmentCheck();
		}
		/**
		 * 标记当前位置.
		 * 以后就可以用gotoSign跳转到此处.
		 * @param	key 标记
		 */
		public function sign(key:String = "xml"):void
		{
			_sign_store[key] = _cuXML;
		}
		/**
		 * 高级直接指定跳转.
		 * 跳转到指定的sign.只能向以前跳转.
		 * <p>如果标记是个节点的话自动go="in".</p>
		 * <p>如果标记只是普通的话自动go="down".</p>
		 * @param	key 标记
		 */
		public function gotoSign(key:String,_start:Boolean = true):void
		{
			if (_sign_store[key] != null) {
				insert(_sign_store[key]);
				if (_sign_store[key].hasSimpleContent() || key == "xml") {
					//go("down");为了避免和upText的跳过执行冲突
				}else {
					go("in");
				}
				_state = State.PAUSE;
				if(_start) start();
			}else {
				Transport.getEvent(EventListBridge.PUSH_ERROR)("Script 找不到 " + key + " 的标记(Sign)");
			}
		}
		/**
		 * 延迟,暂停作用.
		 * 有时候可能[p]不起作用.就用这个
		 * @param	time 暂停时间
		 */
		public function delay(time:Number):void
		{
			TweenLite.delayedCall(time, start);
		}
		/**
		 * 搜索节点.
		 * gotoSign.负责向以前跳.search理论上是随便哪里都可以.
		 * 不过search没有gotoSign稳定.所以能少用就少用.
		 * search所搜索的是label值全字匹配.
		 * <p>和gotoSign一样.如果是节点的话就自动go="in".否则go="down"</p>
		 * @param	label
		 */
		public function search(label:String, tgxml:XML = null):void
		{
			if (tgxml == null) {
				tgxml = _script;
			}
			 for each ( var element:XML in tgxml.elements("Script") ) {
				 if (element.@label == label) {
					 insert(element);
					 if (element.hasComplexContent()) {
						 go("in");
					 }else{
						//go("down");
					 }
					 _state = State.PAUSE;
					 start();
					 return;
				 }else {
					 if (element.hasComplexContent()) {
						search(label,element);
					 }
				 }
			 }
		}
		public function searchMap(place:String,version:String,tgxml:XML = null):XML
		{
			if (tgxml == null) {
				tgxml = _script;
			}
			for each(var x:XML in tgxml.children()) {
				if (x.hasComplexContent()) {
					if (x.name().localName == "Script") {
						searchMap(place, version, x);
					}
					if (x.@select == place) {
						if (x.version == version) {
							return x;
						}
					}
				}
			}
			return null;
		}
		/**@private */
		public function saveData(link:String):void
		{
			path.push(index);
			SAVEManager.appendRowData(link,[scriptPath,Assets.arrayToString(path,";"),_sign_store,permit]);
			path.pop();
		}
		/**@private */
		public function loadData(link:String):void
		{
			var obj:Object = SAVEManager.getData(link);
			_state = State.PAUSE;
			pathto(obj[1]);
			_sign_store = obj[2];
			permit = obj[3];
		}
		/**@private */
		public function get func():FuncMan
		{
			return _func;
		}
		/**@private */
		public function start():void
		{
			if (_state != State.START) {
				_state = State.START;
				progress();
			}
		}
		/**@private */
		public function reset():void
		{
			_state = State.STOP;
			_cuXML = _script;
			index = 0; length = _cuXML.children().length();
			_cuXML = _cuXML.children()[0];
		}
		/**@private */
		public function hasChild(name:String):Boolean
		{
			if (_cuXML[name][0] != null) {
				return true;
			}
			return false;
		}
		/**@private */
		public function childClone():XML
		{
			return _cuXML.copy();
		}
		/**@private */
		public function getScriptBySign(s:String):XML
		{
			return _sign_store[s];
		}
		/**@private */
		public function insert(value:XML,check:Boolean = true):void
		{
			if (value == null) {
				Transport.getEvent(EventListBridge.PUSH_ERROR)("插入XML时出错");
				return;
			}
			_cuXML = value;
			path = findPath(_cuXML);
			if(check)environmentCheck();
		}
		/**
		 * 读取剧本.可以把一个章节分成几个部分.
		 * 一个部分结束了就load下一个部分.
		 * @param	path 剧本xml路径
		 */
		public function load(url:Object = null):void
		{
			loadScript(url as String, true);
		}
		/**@private */
		public function loadScript(path:String,start:Boolean = false):void
		{
			autostart = start;
			scriptPath = path;
			urlLoader.load(new URLRequest(FileManage.getResolvePath(path)));
			//LoaderOptimizer.dispatchLoad(urlLoader, FileManage.getResolvePath(path), true);
			//LoaderOptimizer.displayProgress(urlLoader);
		}
		public function loadXML(x:XML):void
		{
			autostart = false;
			_script = x.copy();
			_script.ignoreComments = true;
			_script.ignoreProcessinginstructions = true;
			_script.ignoreWhitespace = true;
			
			LoaderOptimizer.presetLoad(_script);
			
			_cuXML = _script.copy();
			index = 0; length = _cuXML.children().length();
			_cuXML = _cuXML.children()[0];
			
			dispatchEvent(new Event(Event.COMPLETE));
			
			if (autostart) {
				_state = State.PAUSE;
				start();
			}
		}
		/**@private */
		public function unload():void
		{
			_script = null;
			_cuXML = null;
			path = null;
			index = length = 0;
			_sign_store = null;
		}
		private function findPath(xml:XML):Array
		{
			var p:Array = new Array();
			var tempXML:XML = xml;
			index = tempXML.childIndex();
			length = xml.parent().children().length();
			while (tempXML.parent() != undefined) {
				p.unshift(tempXML.parent().childIndex());
				tempXML = tempXML.parent();
			}
			p.shift();
			return p;
		}
		private function complete(e:Event):void 
		{
			_script = new XML(e.currentTarget.data);
			_script.ignoreComments = true;
			_script.ignoreProcessinginstructions = true;
			_script.ignoreWhitespace = true;
			
			
			//LoaderOptimizer.presetLoad(_script);
			
			_cuXML = _script.copy();
			index = 0; length = _cuXML.children().length();
			_cuXML = _cuXML.children()[0];
			
			dispatchEvent(e);
			
			if (autostart) {
				_state = State.PAUSE;
				start();
			}
		}
		/**@private */
		public function progress():void
		{
			if (_state != State.START) {
				return;
			}
			var value:XMLList;
			var node:XML;
			//trace(_cuXML.toXMLString());
			value = _cuXML.attributes();
			node = _cuXML;
			dispatchEvent(new ScriptEvent(ScriptEvent.PROGRESS, false, false,
							_cuXML.name().localName, value, node));
		}
		/**@private */
		public function get state():String
		{
			return _state;
		}
		/**@private */
		public function set oriData(x:XML):void
		{
			_script = x.copy();
			_cuXML = _script;
			index = 0; length = _cuXML.children().length();
			_cuXML = _cuXML.children()[0];
		}
		/**@private */
		public function get oriData():XML
		{
			return _cuXML;
		}
		private function environmentCheck():void
		{
			if (_cuXML == null) {
				return;
			}
			if (_cuXML.parent().@environment != undefined) {
				if (_cuXML.parent().@environment != environment) {
					environment = _cuXML.parent().@environment;
					TweenLite.delayedCall(0.2, send_environmentchange_event);
				}
			}else {
				if (environment != "") {
					environment = "";
					TweenLite.delayedCall(0.2, send_environmentchange_event);
				}
			}
		}
		private function getValue(x:XMLList):Object
		{
			var o:Object = new Object();
			for (var i:int = 1; i < x.length(); i++) {
				o[x[i].names()] = x[i];
			}
			return o;
		}
	}
	
}