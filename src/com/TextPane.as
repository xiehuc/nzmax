package com
{
	import codex.assets.State;
	import codex.events.BasisEvent;
	import codex.media.GUILoader;
	import com.greensock.easing.Strong;
	import com.nz.EventListBridge;
	import com.nz.IControl;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import com.greensock.TweenLite;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import com.nz.BasicSP;
	import com.nz.ISaveObject;
	import com.nz.Transport;
	import mx.core.FlexSprite;
	
	/**
	 * 用来控制文本显示的类.
	 * 
	 * <table class="innertable">
	 * <tr><th>标签</th><td>值</td></tr>
	 * <tr><th>Link:</th><td>upText</td></tr>
	 * <tr><th>可创建:</th><td>否</td></tr>
	 * <tr><th>可存档:</th><td>是</td></tr>
	 * </table>
	 * @author CodeX
	 */
	public class TextPane extends BasicSP implements ISaveObject
	{
		/** @private */
		static public const START_TRACE:String = "start_trace";
		/** @private */
		static public const PAUSE_TRACE:String = "pause_trace";
		/** @private */
		static public const TYPE_WORD:String = "type_word";
		/** @private */
		static public const END_TRACE:String = "end_trace";
		/** @private */
		static public const KEYWORD:String = "keyword";
		/** @private */
		static public const APPEND:String = "append";
		/** @private */
		static public const APPEND_START:String = "append_start";
		/** @private */
		public const field:String = "global";
		private var sp:_TextBSkin;
		private var nameField:TextField;
		private var textField:TextField;
		private var style:StyleSheet;
		private var halfHeight:Number;
		private var upMove:Number;
		private var waitArr:MovieClip;
		private var tmask:FlexSprite;
		private var timer:Timer;
		private var leftPushTab:FlexSprite;
		private var rightPushTab:FlexSprite;
		
		/**
		 * 设置realName.
		 * 这个参数将会和 当前角色 的 <code>name</code> 比较.
		 * 如果相同的话. 当前角色 将会开始说话(如果能够得话).
		 * 
		 * <p><b>注意:</b>通常的技巧是 紧接着 <code>point</code>
		 * 设置 realName="" 来让 当前角色 不说话.</p>
		 * 
		 * @example 以下代码来达到上述技巧
		 * <listing version="3.0">
		 *  &lt;upText point="l" realName="" text="..."/&gt;
		 * </listing>
		 */
		public var realName:String;
		/** @private */
		public var state:String;
		/**
		 * 用于设置文本输出结束后是否启用playButton.
		 * 就是下屏幕的那个大大的按钮是否enable.
		 * 对directText无效.
		 * 效力只能持续一句的范围.
		 * @example
		 * <listing version="3.0">
		 *  &lt;upText text="成步堂1" append="true" /&gt;
		 *  &lt;upText text="成步堂2"  /&gt;
		 * </listing>
		 */
		public var append:Boolean;
		/**
		 * 控制长文本超出后是否清除以前的文字.
		 * <p>如果设置为 true,那么清除文字.之后继续输出</p>
		 * <p>如果设置为 false,那么产生一个动画.移动文字到上一行.之后继续输出</p>
		 * 具体的可以参见附带的示例剧本
		 */
		public var autoclean:Boolean = false;
		/**
		 * 控制长文本超出后是否等待.
		 * <p>如果设置为 true,将会启动playButton.</p>
		 * <p>如果设置为 false,那么直接继续</p>
		 * 具体的可以参见附带的示例剧本
		 */
		public var autowait:Boolean = false;
		/**
		 * 控制是否输出文本时声音.(与[snd]无关)
		 * <p>如果设置为 true,那么根据一下依据,输出对应的声音.
		 * <ul><li>如果name="",就是不显示名字框.那么输出打字音</li>
		 * <li>否则.如果当前角色的sex属性为 female,输出女性文本声音(就是比较尖的那个),反之....</li></ul></p>
		 * 一般不用设置
		 */
		public var autoSound:Boolean = true;
		private var _name:String;
		private var _speed:int;
		private var _text:String;
		private var index:int;
		private var leftPushPath:String;
		private var rightPushPath:String;
		private const regleft:RegExp = /\[/g;
		private const regright:RegExp = /]/g;
		
		/**
		 * 快速指定当前角色.
		 * <br>
		 * 可以快速将舞台指向某个角色.无动画.<br>
		 * 有动画的是 Main flyto.
		 * 
		 * @param role:Role 所指定的角色的Link.
		 * @see com.Main
		 */
		public var point:Function;
		//这样子要比用dispatchEvent(POINT_ROLE)快些;
		
		/** @private */
		public function TextPane() 
		{
			sp = new _TextBSkin();
			this.addChild(sp);
			this.mouseEnabled = this.mouseChildren = false;
			timer = new Timer(150);
			timer.addEventListener(TimerEvent.TIMER, timer_tracer);
			timer.stop();
			state = State.NORMAL;
			speed = 20;//default:8
			
			style = new StyleSheet();
			style.setStyle("cb",{ color:"#6bc6f7" });
			style.setStyle("cg", { color:"#00f700" });
			style.setStyle("cr", { color:"#ff3300" });
			style.setStyle("cw", { color:"#ffffff" } );
			style.setStyle("co", { color:"#f5ba52" } );
			
			nameField = sp.upArea.textField;
			textField = new TextField();
			textField.multiline = true;
			textField.autoSize = TextFieldAutoSize.NONE;
			textField.wordWrap = true;
			textField.condenseWhite = true;
			textField.x = 13;
			textField.y = 7;
			textField.width = 225;
			textField.height = 32;
			textField.textColor = 0xffffff;
			sp.downArea.addChild(textField);
			textField.defaultTextFormat = new TextFormat();
			textField.styleSheet = style;
			
			tmask = new FlexSprite();
			tmask.graphics.beginFill(0x000000);
			tmask.graphics.drawRect(0, 0, textField.width, textField.height);
			tmask.graphics.endFill();
			tmask.x = textField.x;
			tmask.y = textField.y;
			sp.downArea.addChild(tmask);
			textField.mask = tmask;
			halfHeight = tmask.height / 2;
			upMove = 14;
			
			waitArr = sp.downArea.waitArr;
			waitArr.stop();
			waitArr.visible = false;
			
			leftPushTab = new FlexSprite();
			rightPushTab = new FlexSprite();
			leftPushTab.y = rightPushTab.y = 20 - 192 + 48;
			leftPushTab.x = 20;
			rightPushTab.x = 256 - 20 - 48;
			
			func.setFunc("name", { type:Script.Properties } );
			func.setFunc("realName", { type:Script.Properties} );
			func.setFunc("point", { type:Script.SingleParams} );
			func.setFunc("text", { type:Script.Properties, down:false } );
			func.setFunc("appendText", { type:Script.SingleParams,down:false} );
			func.setFunc("directText", { type:Script.Properties , progress:false } );
			func.setFunc("writeTextDirectely", { type:Script.SingleParams } );
			func.setFunc("append", { type:Script.BooleanProperties } );
			func.setFunc("autoclean", { type:Script.BooleanProperties } );
			func.setFunc("autowait", { type:Script.BooleanProperties } );
			func.setFunc("autoSound", { type:Script.BooleanProperties } );
			func.setFunc("speed", { type:Script.Properties } );
			func.setFunc("leftPush", { type:Script.SingleParams } );
			func.setFunc("rightPush", { type:Script.SingleParams } );
			func.setFunc("cleanPush", { type:Script.NoParams } );
			func.setFunc("cleanText", { type:Script.NoParams } );
		}
		/**
		 * 用于设置名字框显示的文字.
		 * 以后被 <code>point</code> 替代.
		 * 
		 * <p>在设置时会同时设置 <code>realName</code></p>
		 * 
		 * @example 以下代码通常不用
		 * <listing version="3.0">
		 *  &lt;upText name="成步堂" /&gt;
		 * </listing>
		 */
		override public function get name():String
		{
			return _name;
		}
		override public function set name(value:String):void
		{
			_name = value;
			realName = value;
			nameField.text = value;
			if (value == "") {
				sp.upArea.visible = false;
			}else if (sp.upArea.visible == false) {
				sp.upArea.visible = true;
			}
		}
		/**
		 * 用于动画显示文本.
		 * 是最常用的属性之一.
		 * 
		 * <p>
		 * 可以设置html标签.但是在xml文件内不能直接输入&lt; 和 &gt;
		 * 所以将这两个符号用[ ] 代替.<br>
		 * <ul><li> 例如 text="换[br]行"</li></ul>
		 * 但是.不是所有的html标签都能用.因为动画输出文字的缘故.故只有很少量的标签可以用.
		 * 没有测试
		 * </p>
		 * 
		 * <p>
		 * 另外还顺便创建了五个颜色标签.分别是
		 * <table class="innertable">
		 * <tr><th>标签</th><th>详细</th></tr>
		 * <tr><td>cb</td><td>color blur : #6bc6f7</td></tr>
		 * <tr><th>cg</th><td>color green : #00f700</td></tr>
		 * <tr><th>cr</th><td>color red : #ff3300</td></tr>
		 * <tr><th>co</th><td>color orange : #f5ba52</td></tr>
		 * <tr><th>cw</th><td>color white : #ffffff</td></tr>
		 * </table>
		 * 无论设置什么颜色.都最后请设置为cw.而不能用带反斜杠的.
		 * <ul><li> 例如 text="这里是[cr]关键[cw]证物"</li></ul>
		 * </p>
		 * 
		 * <p>
		 * 另外还创建了其他的标签用于处理复杂的文本动画
		 * 这些标签可以带一个参数.用 | 来分隔.
		 * <ul>
		 * <li><b>vib:</b>vibration,用于产生一个屏幕震动的动画.有1,2,3这三个程度大小
		 * 				<p>params:<i>int</i>,default:<i>2</i></p></li>
		 * <li><b>fsrn:</b>flashScreen,用于产生一个闪屏的动画(就是一片白色)
		 * 		 		<p><b>注意:</b>如果时间小于0.5的话.会闪一下就消失.如果时间大于0.5的话.会闪一下然后慢慢消失.</p>
		 * 				<p>params:<i>time</i>,defalut:<i>0.5</i></p></li>
		 * <li><b>p:</b>pause,用于暂停.<p>params:<i>time</i>,default:<i>0.5</i></p></li>
		 * <li><b>cls:</b>clean screen,用于清除文本框文本.</li>
		 * <li><b>snd:</b>sound,用于输出一个声音.可以是文件或是库中的音乐.详见com.Music.
		 * 				<p>params:<i>sound tag or sound file</i></p></li>
		 * <li><b>emo:</b>emotion,用于在文本中更改 当前角色 的emotion值.注意必须是可以speaking的.
		 * 				<p>params:<i>emotion</i></p></li>
		 * </ul>
		 * </p>
		 * 
		 * <p><b>注意:</b>不用每次都加上point.如果上一个已经指定了 当前角色 的话</p>
		 * 
		 * @example 以下代码用于输出带暂停1秒的文本动画
		 * <listing version="3.0">
		 *  &lt;upText text="以下代码用于输出带暂停[p|1]1秒的文本动画" /&gt;
		 * </listing>
		 */
		public function get text():String
		{
			return _text;
		}
		/** @private */
		public function set text(value:String):void
		{
			if (!this.visible) this.visible = true;
			index = 0;
			_text = value;
			_text = _text.replace(regleft,"<");
			_text = _text.replace(regright, ">");
			timer.start();
			textField.htmlText = "";
			dispatchEvent(new Event(TextPane.START_TRACE));
		}
		/**
		 * 用于输出文本动画(不清除上一次的文本).
		 * 通常和 <code>append</code>连用
		 * <p>用法和 <code>text</code>完全一致.只是不会清除上一次的文本.通常中间夹了一些其他的脚本</p>
		 * 
		 * @example 
		 * <listing version="3.0">
		 *  &lt;upText text="这是第一句" append="true"/&gt;
		 *  &lt;Script delay="3" /&gt;
		 *  &lt;upText appendText="这是第一句" /&gt;
		 * </listing>
		 */
		public function appendText(value:String):void
		{
			if (!this.visible) this.visible = true;
			_text += value;
			_text = _text.replace(regleft,"<");
			_text = _text.replace(regright, ">");
			timer.start();
			dispatchEvent(new Event(TextPane.START_TRACE));
		}
		/**
		 * 用于输出文本,无动画.
		 * <p>用法和 <code>text</code>完全一致.只是没有动画效果.通常是在开始证言的时候用一下</p>
		 * <p><b>注意:</b>因为没有动画.所以text的一些限制也没有课.html标签可以使用反斜杠了.</p>
		 * <ul><li> 例如 directText="这里是[b]关键[/b][i]证物[/i]"</li></ul>
		 */
		public function set directText(value:String):void
		{
			writeTextDirectely(value);
			dispatchEvent(new Event(TextPane.END_TRACE));
		}
		/**
		 * 用于设置文本输出速度.
		 * 计算方法是: timer.delay = 1000 / _speed / 2 * 1.5;
		 * 细节就不用管了.自己多试几个数就是了.
		 * @default 8
		 */
		public function get speed():int
		{
			return _speed;
		}
		public function set speed(value:int):void
		{
			_speed = value;
			timer.delay = 1000 / _speed / 2 * 1.5;
		}
		/**
		 * 用于左推出图片.
		 * 就是在左上角有个小图片.通常是证物的图片.
		 * @param	path 是ObjectItem的Link,RoleItem的Link,或是路径.
		 * @example 比如你在之前创建了一个 photo_oi 的ObjectItem.
		 * <listing version="3.0">
		 *  &lt;upText leftPush="photo_oi"/&gt;
		 * </listing>
		 * @example 如果你之前并没有创建的话.就直接引用路径就是了.
		 * <listing version="3.0">
		 *  &lt;upText leftPush="照片.jpg"/&gt;
		 * </listing>
		 */
		public function leftPush(path:String):void
		{
			leftPushPath = path;
			if (Transport.Pro[path] != null) {
				var data:BitmapData = Transport.Pro[path].imageCopy();
				pushImage(leftPushTab, new Bitmap(data));
			}else {
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, Transport.eventList[EventListBridge.IO_ERROR_EVENT]);
				loader.load(new URLRequest(FileManage.getResolvePath(path)));
				pushImage(leftPushTab, loader);
			}
		}
		/**
		 * 用于右推出图片.
		 * 详见 leftPush
		 */
		public function rightPush(path:String):void
		{
			rightPushPath = path;
			if (Transport.Pro[path] != null) {
				var data:BitmapData = Transport.Pro[path].imageCopy();
				pushImage(rightPushTab, new Bitmap(data));
			}else {
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,Transport.eventList[EventListBridge.IO_ERROR_EVENT]);
				loader.load(new URLRequest(FileManage.getResolvePath(path)));
				pushImage(rightPushTab, loader);
			}
		}
		/**
		 * 用于清除推出的图片.
		 * 左右通吃.
		 */
		public function cleanPush():void
		{
			leftPushPath = rightPushPath = null;
			if(leftPushTab.root != null) sp.removeChild(leftPushTab);
			if(rightPushTab.root != null) sp.removeChild(rightPushTab);
		}
		/**
		 * 用于清除文本框文本.
		 * [cls]的原型就是它.
		 */
		public function cleanText():void
		{
			textField.htmlText = "";
		}
		/**@private */
		public function saveData(mod:String):void
		{
			var obj:Object = { name:name,
								writeTextDirectely:textField.htmlText,
								autoclean:this.autoclean,
								autowait:this.autowait,
								autoSound:this.autoSound,
								speed:this.speed};
			if (leftPushPath != null) obj.leftPush = leftPushPath;
			if (leftPushPath != null) obj.leftPush = leftPushPath;
			if (rightPushPath != null) obj.rightPush = rightPushPath;
			SAVEManager.appendData(mod,obj);
		}
		/**@private */
		public function loadData(link:String):void { };
		/**@private */
		public function pushImage(target:FlexSprite,data:DisplayObject):void
		{
			if (target.numChildren != 0) {
				target.removeChildAt(0);
			}
			target.addChild(data);
			target.alpha = 0;
			target.width = target.height = 30;
			TweenLite.to(target, 0.5, { alpha:1, width:48,height:48,ease:Strong } );
			sp.addChild(target);
		}
		/**@private */
		public function writeTextDirectely(value:String):void
		{
			if (!this.visible) this.visible = true;
			index = value.length - 1;
			_text = value;
			_text = _text.replace(regleft,"<");
			_text = _text.replace(regright, ">");
			textField.htmlText = _text;
		}
		/**@private */
		public function show(vi:Boolean):void
		{
			if(autoVi)
				this.visible = vi;
		}
		/**@private */
		public function initFormat(fmt:XMLList):void
		{
			textField.styleSheet = null;
			var orifmt:TextFormat = textField.defaultTextFormat;
			if (fmt.family != undefined) orifmt.font = fmt.family;
			if (fmt.size != undefined) orifmt.size = fmt.size;
			if (fmt.leading != undefined) orifmt.leading = fmt.leading;
			textField.defaultTextFormat = orifmt;
		//	textField.autoSize = TextFieldAutoSize.LEFT;
			textField.htmlText = "测试<br>测试";
		//	textField.autoSize = TextFieldAutoSize.NONE;
			textField.height += Number(orifmt.leading) - 2;
			tmask.height = textField.height;
			upMove = textField.height / 2;
			if (fmt.delta != undefined) upMove += Number(fmt.delta);
			textField.styleSheet = style;
		}
		/**@private */
		public function insidePause(time:Number):void
		{
			timer.stop();
			Transport.Pro["Music"].overStop();
			if (Transport.CurrentRole.isspeaking) {
				Transport.CurrentRole.speak(false);
				TweenLite.delayedCall(time, Transport.CurrentRole.speak,[true]);
			}
			TweenLite.delayedCall(time, timer.start);
			TweenLite.delayedCall(time, Transport.Pro["Music"].overContinue);
		}
		private function timer_tracer(e:TimerEvent):void 
		{
			if (index < _text.length) {
				if (_text.charAt(index) == "<") {
					var endIndex:int = _text.indexOf(">", index) + 1;
					var w:String = _text.slice(index, endIndex);
					textField.htmlText += w;
					index += w.length;
					dispatchEvent(new BasisEvent(TextPane.KEYWORD, false, false, w.slice(1,w.length-1)));
				}else {
					textField.htmlText += _text.charAt(index);
					index++;
				}
				if (textField.scrollV<textField.numLines-1) {
					if (autowait) {
						state = State.EMERGENCY;
						timer.stop();
						dispatchEvent(new Event(TextPane.END_TRACE));
					}else {
						deal_pause();
					}
				}
			}else {
				timer.stop();
				if (append) {
					append = false;
					dispatchEvent(new Event(TextPane.APPEND));
				}else{
					dispatchEvent(new Event(TextPane.END_TRACE));
				}
			}
		}
		/**@private */
		public function deal_pause():void
		{
			if (autowait) {
				if (autoclean) {
					if(_text.charAt(index-1) != ">") textField.text = _text.charAt(index-1);
					dispatchEvent(new Event(START_TRACE));
					timer.start();
				}else {
					TweenLite.to(textField, 1, { y:textField.y-upMove, onComplete:go_on_after_pause } );
				}
			}else {
				if (autoclean) {
					if(_text.charAt(index-1) != ">") textField.text = _text.charAt(index-1);
				}else {
					timer.stop();
					Transport.CurrentRole.speak(false);
					Transport.Pro.Music.overStop();
					TweenLite.to(textField, 1, { y:textField.y-upMove, onComplete:go_on_after_pause } );
				}
			}
		}
		private function go_on_after_pause():void
		{
			textField.y = tmask.y;
			textField.scrollV++;
			if (!autowait) {
				Transport.CurrentRole.speak(true);
				Transport.Pro.Music.overContinue();
			}else {
				dispatchEvent(new Event(START_TRACE));
			}
			timer.start();
		}
		/**@private */
		public function set wait_arr_vi(bo:Boolean):void
		{
			if(bo==true){
				waitArr.visible = true;
				waitArr.play();
			}else {
				waitArr.visible = false;
				waitArr.stop();
			}
		}
		/**@private */
		public function get wait_arr_vi():Boolean
		{
			return waitArr.visible;
		}
	}
	
}