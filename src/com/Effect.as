package com
{
	import codex.manager.FilterManager;
	import codex.Note;
	import com.greensock.events.TweenEvent;
	import com.greensock.TimelineLite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shader;
	import flash.display.ShaderData;
	import flash.display.ShaderParameter;
	import flash.display.ShaderPrecision;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.filters.ShaderFilter;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.nz.ISaveObject;
	import com.nz.Transport;
	
	/**
	 * 用来控制特效显示的类.
	 * <table class="innertable">
	 * <tr><th>标签</th><td>值</td></tr>
	 * <tr><th>Link:</th><td>Effect</td></tr>
	 * <tr><th>可创建:</th><td>否</td></tr>
	 * <tr><th>可存档:</th><td>是</td></tr>
	 * </table>
	 * @see com.EffectTarget
	 * @author CodeX
	 */
	public class Effect extends EventDispatcher implements ISaveObject
	{
		[Embed(source = "../../lib/effect/zoomblur.pbj", mimeType = "application/octet-stream")]private var zoomBlurPB:Class;
		[Embed(source = "../../lib/effect/sharpen.pbj", mimeType = "application/octet-stream")]private var sharpenPB:Class;
		[Embed(source = "../../lib/effect/pixelate.pbj", mimeType = "application/octet-stream")]private var pixelatePB:Class;
		/**@private */
		public var func:FuncMan;
		private var filterList:Object;
		private var filterDescription:Object;//存档专用
		private var motionTarget:String;
		private var motionDic:Dictionary;
		private var timer:Timer;
		private var vibTween:TimelineLite;
		private var vibpre:Object;
		private var _whiteScreen:Sprite;
		/**@private */
		public function Effect() 
		{
			filterList = new Object();
			filterDescription = new Object();
			motionDic = new Dictionary();
			
			filterList.zoomBlur = new Shader(new zoomBlurPB());
			filterList.zoomBlur.precisionHint = ShaderPrecision.FAST;//amount
			filterList.zoomBlur.data.center.value = [128, 96];
			filterList.sharpen = new Shader(new sharpenPB());
			filterList.sharpen.precisionHint = ShaderPrecision.FAST;
			filterList.pixelate = new Shader(new pixelatePB());
			filterList.pixelate.precisionHint = ShaderPrecision.FAST;
			
			filterDescription.zoomBlur = ["amount"];
			filterDescription.sharpen = ["amount"];
			filterDescription.pixelate = ["dimension"];
			
			filterList.blur = new BlurFilter();
			filterList.invert = new ColorMatrixFilter([ -1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0]);
			filterList.grey = new ColorMatrixFilter([0.11, 0.59, 0.3, 0, 0, 0.11, 0.59, 0.3, 0, 0, 0.11, 0.59, 0.3, 0, 0, 0, 0, 0, 1, 0]);
			filterList.relief = new ConvolutionFilter(3, 3, [ -10, -1, 0, -1, 1, 1, 0, 1, 10]);
			
			filterDescription.blur = ["blurX", "blurY"];
			filterDescription.invert = [];
			filterDescription.grey = [];
			filterDescription.relief = [];
			
			timer = new Timer(50);
			timer.repeatCount = 7;
			timer.stop();
			timer.addEventListener(TimerEvent.TIMER, vib_timer);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, vib_timer_complete);
			
			_whiteScreen = new Sprite();
			_whiteScreen.graphics.beginFill(0xffffff);
			_whiteScreen.graphics.drawRect(0, 0, 256, 192);
			_whiteScreen.graphics.endFill();
			
			func = new FuncMan();
			func.setFunc("applyFilters", { type:Script.ComplexParams,down:true,progress:false } );
			func.setFunc("cleanFilters", { type:Script.SingleParams } );
			func.setFunc("cleanAllFilters", { type:Script.NoParams } );
			func.setFunc("applyMotion", { down:true, progress:false, type:Script.ComplexParams } );//每一帧都要有完全滤镜列表.或者前面多余后面
			func.setFunc("applyTweens", { down:true, progress:false, type:Script.ComplexParams } );
		}
		/**
		 * 用于设定单帧滤镜.
		 * 可以使用的滤镜列表:
		 * <ul>
		 * <li><b>blur:</b>模糊滤镜.参数:
		 * 	<p>    <i>blurX:</i>X轴方向模糊系数.</p>
		 * 	<p>    <i>blurY:</i>Y轴方向模糊系数.</p></li>
		 * <li><b>invert:</b>颜色反转.参数:无</li>
		 * <li><b>grey:</b>灰度滤镜.参数:无</li>
		 * <li><b>relief:</b>浮雕滤镜.从来不用.参数:无</li>
		 * <li><b>pixelate:</b>像素化滤镜.只能从左上角开始.参数:
		 * 	<p>    <i>dimension:</i>像素化程度.默认为1.越大越不清楚.</p></li>
		 * <li><b>sharpen:</b>锐化滤镜.参数:
		 * 	<p>    <i>amound:</i>锐化程度.越大越不清楚.</p></li>
		 * <li><b>zoomBlur:</b>动态模糊滤镜.效果不好.参数:
		 * 	<p>    <i>amound:</i>模糊程度.越大越不清楚.</p></li>
		 * </ul>
		 * <p><b>注意:</b>pixelate,sharpen,zoomBlur使用的是Pixel Bender.翻译过来就是又慢又卡.慎用.</p>
		 * 
		 * @param	data 滤镜XML列表
		 * @param	target 目标对象.除了所有可以显示的对象的Link外,还有几个比较常用的.
		 * <ul>
		 * <li><b>all:</b>范围:所有</li>
		 * <li><b>visual:</b>范围:上屏幕</li>
		 * <li><b>background:</b>范围:背景层.包括了Bg和一些自己设定的Layout</li>
		 * <li><b>role:</b>范围:人物显示的图层.包括了所有人物和自己设定的Layout</li>
		 * </ul>
		 * <p><b>注意:</b>以上列表都不可直接使用.只能在Effect中使用.就是&lt;visual visible="false"/&gt;是不行的.</p>
		 * @example
		 * <listing version="3.0">
		 * &lt;Effect applyFilters="visual"/&gt;
		 *    &lt;grey/&gt;
		 *    &lt;blur blurX="30" blurY="30"/&gt;
		 * &lt;/Effect/&gt;
		 * </listing>
		 */
		public function applyFilters(data:XML,target:String):void
		{
			for each(var filter:XML in data.children()) {
				var fi:* = setFilter(filter);
				getFilterManager(target).addFilter(filter.name().localName, fi);
			}
			TweenLite.delayedCall(0.1, script_start);//保证顺利执行
		}
		/**
		 * 用于设定多帧动态滤镜.
		 * 基本用法和applyFilters一样.但是所有的滤镜都包含在了frame标签中.
		 * <p><b>注意:</b>因为是动态的.所以像grey之类的没有参数的就不能用了.</p>
		 * <p>frame 有一个可选的last参数.用于从上一个frame到这个frame的时间.</p>
		 * @param	data 帧滤镜XML列表
		 * @param	target 目标对象
		 * @example
		 * <listing version="3.0">
		 * &lt;Effect applyMotion="visual"/&gt;
		 *    &lt;frame&gt;
		 *       &lt;blur blurX="0" blurY="0"/&gt;
		 *    &lt;/frame&gt;
		 *    &lt;frame last="1"/&gt;
		 *       &lt;blur blurX="30" blurY="30"/&gt;
		 *    &lt;/frame&gt;
		 *    &lt;frame last="1"/&gt;
		 *       &lt;blur blurX="0" blurY="0"/&gt;
		 *    &lt;/frame&gt;
		 * &lt;/Effect&gt;
		 * </listing>
		 */
		public function applyMotion(data:XML,target:String):void
		{
			motionTarget = target;
			motionDic = new Dictionary();
			var objectList:Object = new Object();
			var fIndex:int;
			var last:Number;
			var mTimeline:TimelineLite = new TimelineLite({onComplete:script_start});
			for each(var frame:XML in data.children()) {
				if (frame.@last == undefined) last = 0;
				else last = Number(frame.@last);
				var ar:Array = new Array();
				for each(var tg:XML in frame.children()) {
					if (objectList[tg.name().localName] == null) {
						objectList[tg.name().localName] = toObject(tg);
					}
					var tm:TweenMax = new TweenMax(objectList[tg.name().localName], last, toObject(tg));
					motionDic[tm] = tg.name().localName;
					tm.addEventListener(TweenEvent.UPDATE, shaderMotion_update);
					ar.push(tm);
				}
				mTimeline.insertMultiple(ar,mTimeline.duration);
			}
			mTimeline.gotoAndPlay(0);
		}
		/**
		 * 用于设定多帧缓动动画.
		 * 和filter不一样.这个tween是非常实用的.在flash编程中也是.就是可以创造对象属性的补间动画.
		 * <p>什么是属性.比如Music的volumn就是属性.alpha啊之类的.x,y.之类的.</p>
		 * <p>如果是不用tween的话.直接设置属性就好了.&lt;Music volumn="0.5"/&gt;</p>
		 * @param	data 帧属性XML列表
		 * @param	target 无
		 * @example 
		 * <listing version="3.0">
		 * &lt;Effect applyTweens=""/&gt;
		 *    &lt;frame&gt;
		 *       &lt;l alpha=0/&gt;
		 *    &lt;/frame&gt;
		 *    &lt;frame last="1"/&gt;
		 *       &lt;l alpha="1"/&gt;
		 *    &lt;/frame&gt;
		 *    &lt;frame last="1"/&gt;
		 *       &lt;l alpha="0"/&gt;
		 *    &lt;/frame&gt;
		 * &lt;/Effect&gt;
		 * </listing>
		 */
		public function applyTweens(data:XML,target:String):void
		{
			var last:Number;
			var mTimeline:TimelineLite = new TimelineLite({onComplete:script_start});
			for each(var frame:XML in data.children()) {
				if (frame.@last == undefined) last = 0;
				else last = Number(frame.@last);
				var ar:Array = new Array();
				for each(var tg:XML in frame.children()) {
					ar.push(new TweenLite(Transport.Pro[tg.name().localName], last, toObject(tg)));
				}
				mTimeline.insertMultiple(ar,mTimeline.duration);
			}
			mTimeline.gotoAndPlay(0);
		}
		/**
		 * 清除某个对象的滤镜.
		 * 因为添加滤镜会减慢速度.所以用了之后要记着清除.
		 * 而且我试验过的.滤镜有些不稳定.比如用了grey之后.还是会出现几帧有色彩的图像.
		 * @param	target 施用了滤镜的对象
		 */
		public function cleanFilters(target:String):void
		{
			getFilterManager(target).removeAllFilters();
		}
		/**
		 * 清除所有对象的滤镜.
		 */
		public function cleanAllFilters():void
		{
			for each(var item:FilterManager in FilterManager.getAllFilterManagers()) {
				item.removeAllFilters();
			}
		}
		/**@private */
		public function saveData(link:String):void
		{
			cleanFilterManagers();
			for (var target:String in FilterManager.getAllFilterManagers()) {
				SAVEManager.appendData(link, { applyFilters:target }, toFilterXMLDescript(target));
			}
		}
		private function toFilterXMLDescript(target:String):XMLList
		{
			var x:XMLList = new XMLList();
			var fm:FilterManager = FilterManager.getFilterManager(target);
			var names:Object = fm.getAllFiltersName();
			var i:int = 0;
			for (var name:String in names) {
				x[i] = <nz/>
				x[i].setName(name);
				for each(var item:String in filterDescription[name]) {
					x[i].@[item] = fm.getFilterByName(name)[item];
				}
				i++;
			}
			return x;
		}
		/**@private */
		public function loadData(link:String):void
		{
		}
		/**@private */
		public function cleanFilterManagers():void
		{
			for (var item:String in FilterManager.getAllFilterManagers()) {
				if (Transport.Pro[item] == null) {
					FilterManager.removeFilterManager(item);
				}
			}
		}
		/**@private */
		public function getFilterManager(name:String):FilterManager
		{
			if (FilterManager.getFilterManager(name) == null) {
				var fm:FilterManager = new FilterManager(name);
				fm.target = Transport.Pro[name];
				return fm;
			}
			return FilterManager.getFilterManager(name);
		}
		private function script_start():void
		{
			dispatchEvent(new Event(Script.SCRIPT_START));
		}
		private function shaderMotion_update(e:TweenEvent):void 
		{
			var filter:BitmapFilter = setFilterObject(motionDic[e.target], e.target.target) as BitmapFilter;
			getFilterManager(motionTarget).addFilter(motionDic[e.target], filter);
		}
		/**@private */
		public function vibration(target:DisplayObject,amount:int):void
		{
			vibpre = { target:target, amount:amount, x:target.x, y:target.y };
			timer.reset();
			timer.start();
		}
		private function vib_timer(e:TimerEvent):void 
		{
			vibpre.target.x = vibpre.x+radom(10, -5) * vibpre.amount;
			vibpre.target.y = vibpre.y+radom(10, -5) * vibpre.amount;
		}
		/**@private */
		public function radom(range:int,start:int = 0):int {
			return Math.floor(Math.random()*range)+start;
		}
		private function vib_timer_complete(e:TimerEvent):void 
		{
			vibpre.target.x = vibpre.x;
			vibpre.target.y = vibpre.y;
		}
		private function setFilter(filter:XML):*
		{
			var fi:* = filterList[filter.name().localName];
			var params:XML;
			if (fi is Shader) {
				for each(params in filter.attributes()) {
					var p:ShaderParameter = fi.data[params.name().localName];
					p.value = formatParams(params.toString().split(","), p.type);
					return new ShaderFilter(fi);
				}
			}else {
				for each(params in filter.attributes()) {
					fi[params.name().localName] = params.toString();
				}
			}
			return fi;
		}
		private function setFilterObject(name:String,filter:Object):Object
		{
			var fi:Object = filterList[name];//源滤镜.全属性.filter:目标滤镜.部分属性
			var params:String;
			if (fi is Shader) {
				for (params in filter) {
					var p:ShaderParameter = fi.data[params];
					p.value = [filter[params]];
				}
				var sf:ShaderFilter = new ShaderFilter(fi as Shader);
				return sf;
			}else {
				for (params in filter) {
					fi[params] = filter[params];
				}
			}
			return fi;
		}
		private function toObject(filter:XML):Object
		{
			var ob:Object = new Object();
			for each(var param:XML in filter.attributes()) {
				ob[param.name().localName] = Number(param.toString());
			}
			return ob;
		}
		private function formatParams(array:Array, type:String):Array
		{
			var cl:Class;
			if (type.indexOf("INT") != -1) {
				cl = int;
			}else if (type.indexOf("bool") != -1) {
				cl = Boolean;
			}else {
				cl = Number;
			}
			for (var i:int = 0; i < array.length;i++ ) {
				array[i] = cl(array[i]);
			}
			return array;
		}
		/**@private */
		public function flashScreen(target:DisplayObjectContainer, t:Number):void
		{
			target.addChild(_whiteScreen);
			if(t<=0.5){
				TweenLite.delayedCall(t, target.removeChild, [_whiteScreen]);
			}else {
				TweenLite.delayedCall(t, TweenLite.to, [_whiteScreen, 1, { alpha:0, onComplete:flashScreenContinue } ]);
			}
		}
		private function flashScreenContinue():void
		{
			_whiteScreen.alpha = 1;
			_whiteScreen.stage.removeChild(_whiteScreen);
		}
	}
	
	
}