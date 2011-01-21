package com 
{
	import com.nz.ICreatable;
	import com.nz.Transport;
	import flash.events.Event;
	/**
	 * 用来创建特效显示的类.
	 * 一次创建.多次使用.
	 * 因为之前只设计了Effect不能创建.所以
	 * 现在设计了一个新的类.专门负责创建Effect.改的代码比较少.
	 * <table class="innertable">
	 * <tr><th>标签</th><td>值</td></tr>
	 * <tr><th>Link:</th><td>无</td></tr>
	 * <tr><th>可创建:</th><td>是</td></tr>
	 * <tr><th>创建类型:</th><td>Effect</td></tr>
	 * <tr><th>可存档:</th><td>是</td></tr>
	 * </table>
	 * @see com.Effect
	 * @author CodeX
	 */
	public class EffectTarget implements ICreatable
	{
		private var _autoAddDisplayRoot:Boolean = false;
		private var _regit:Boolean = false;
		private var _type:String = "Effect";
		/**@private */
		public const field:String = "Effect";
		
		/**@private */
		public function set autoAddDisplayRoot(value:Boolean):void { _autoAddDisplayRoot = value; }
		/**@private */
		public function get autoAddDisplayRoot():Boolean { return _autoAddDisplayRoot; }
		/**@private */
		public function set displayParent(value:String):void { }
		/**@private */
		public function get displayParent():String { return null };
		/**@private */
		public function set regit(value:Boolean):void { _regit = value; }
		/**@private */
		public function get regit():Boolean { return _regit; }
		/**@private */
		public function set type(value:String):void { _type = value; }
		/**@private */
		public function get type():String { return _type; }
		/**@private */
		public function creationComplete():void { }
		/**@private */
		public function remove():void { }
		/**@private */
		public function saveData(link:String):void
		{
			var o:Object = new Object();
			SAVEManager.appendCreateData(link, { type:_type } );
			SAVEManager.appendRowData(link, [data, method], field);
		}
		/**@private */
		public function loadData(link:String):void
		{
			var obj:Object = SAVEManager.getData(link, field);
			data = obj[0];
			method = obj[1];
		}
		/**@private */
		public var func:FuncMan;
		private var data:XML;
		private var method:String;
		private var replaceObject:Object;
		/**@private */
		public function EffectTarget() 
		{
			func = new FuncMan();
			func.setFunc("writeFilters", { type:Script.ComplexParams } );
			func.setFunc("writeMotion", { type:Script.ComplexParams } );
			func.setFunc("writeTweens", { type:Script.ComplexParams } );
			func.setFunc("applyToTarget", { type:Script.SingleParams, down:true, progress:false } );
			func.setFunc("cleanFilters", { type:Script.SingleParams } );
			func.setFunc("cleanAllFilters", { type:Script.NoParams } );
			func.setFunc("type", { type:Script.IgnoreProperties } );
		}
		/**
		 * 用于登记要使用的是 Effect applyFilters.
		 * 写法和Effect.applyFilters完全一样.
		 * 先创建.一次.然后用applyToTarget来使用.
		 * @param	data 滤镜XML列表
		 * @param	target 无.
		 * @example
		 * <listing version="3.0">
		 * &lt;Main create="Effect"/&gt;
		 *    &lt;my_ef writeFilters=""/&gt;
		 *       &lt;grey/&gt;
		 *       &lt;blur blurX="30" blurY="30"/&gt;
		 *    &lt;/my_ef&gt;
		 * &lt;/Main/&gt;
		 * &lt;/my_ef applyToTarget="l"/&gt;
		 * </listing>
		 */
		public function writeFilters(x:XML,blank:String):void
		{
			data = x.copy();
			method = "applyFilters"
		}
		/**
		 * 用于登记要使用的是  Effect applyMotion.
		 * 基本上看了writeFilters就不用讲了.
		 * @param	data 帧滤镜XML列表
		 * @param	target 无
		 */
		public function writeMotion(x:XML, blank:String):void
		{
			data = x.copy();
			method = "applyMotion";
		}
		/**
		 * 用于登记要使用的是  Effect applyTweens.
		 * 基本上看了writeFilters就不用讲了.
		 * <p><b>注意:</b>writeFilters可以使用参数功能.其实实现的原理就是简单的文本替换.不过效率其实要低得多.
		 * target参数写上被替换的文本,用;分隔.然后在XML里面就可以用了.注意.只能是对象名用参数.不能属性名.
		 * 看了例子就明白了</p>
		 * @param	x
		 * @param	target
		 * @example
		 * <listing version="3.0">
		 * &lt;Main create=""/&gt;
		 *    &lt;my_ef type="Effect" writeTweens="tg1;tg2"/&gt;
		 *       &lt;frame&gt;
		 *          &lt;tg1 alpha="0"/&gt;
		 *          &lt;tg2 alpha="1"/&gt;
		 *          &lt;Bg y="-192"/&gt;
		 *       &lt;/frame&gt;
		 *       &lt;frame last="1"/&gt;
		 *          &lt;tg1 alpha="1"/&gt;
		 *          &lt;tg2 alpha="0"/&gt;
		 *          &lt;Bg y="0"/&gt;
		 *       &lt;/frame&gt;
		 *    &lt;/my_ef&gt;
		 * &lt;/Main&gt;
		 * &lt;/my_ef applyToTarget="l;w"&gt;
		 * </listing>
		 */
		public function writeTweens(x:XML, blank:String):void
		{
			data = x.copy();
			if (blank != "") {
				replaceObject = new Object();
				var ar:Array = blank.split(";");
				for (var i:int = 0; i < ar.length; i++) {
					replaceObject[ar[i]] = i;
				}
			}else {
				replaceObject = null;
			}
			method = "applyTweens"
		}
		/**
		 * 用于使用指定的特效到指定的对象.
		 * @param	target 对象或对象列表.
		 */
		public function applyToTarget(t:String):void
		{
			var d:XML = data.copy();
			if (method == "applyTweens" && replaceObject != null) {
				var nar:Array = t.split(";");
				for (var i:int = 0; i < d.frame.length(); i++) {
					for (var j:int = 0; j < d.frame[i].children().length(); j++) {
						var k:int = getTweenTargetIndex(d.frame[i].children()[j].name().localName);
						if (k!=-1) {
							d.frame[i].children()[j].setName(nar[k]);
						}
					}
				}
			}
			//trace(d.toXMLString());
			Transport.Pro["Effect"][method](d, t);
		}
		/**
		 * 取消滤镜.
		 * 其实就是调用了Effect.cleanFilters
		 * @param	target 指定对象
		 */
		public function cleanFilters(t:String):void
		{
			Transport.Pro["Effect"].cleanFilters(t);
		}
		/**
		 * 取消所有滤镜.
		 * 其实就是调用了Effect.cleanAllFilters
		 */
		public function cleanAllFilters():void
		{
			Transport.Pro["Effect"].cleanAllFilters();
		}
		private function getTweenTargetIndex(name:String):int
		{
			if (replaceObject[name] == null) {
				return -1;
			}
			return replaceObject[name];
		}
		
	}

}