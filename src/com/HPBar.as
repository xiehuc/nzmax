package com
{
	import com.SAVEManager;
	import flash.events.Event;
	import com.greensock.TweenLite;
	import lib.hpbar;
	import com.nz.BasicSP;
	import com.nz.ISaveObject;
	/**
	 * 用于控制血条的类.
	 * 其实血条是一直存在的.就是没有显示而已.
	 * 满血是100
	 * <table class="innertable">
	 * <tr><th>标签</th><td>值</td></tr>
	 * <tr><th>Link:</th><td>HP</td></tr>
	 * <tr><th>可创建:</th><td>否</td></tr>
	 * <tr><th>可存档:</th><td>是</td></tr>
	 * </table>
	 * @author c
	 */
	public class HPBar extends BasicSP implements ISaveObject
	{
		/**
		 * 引用 DEFAULT_NOHP
		 * @eventType nohp
		 */
		static public const NOHP:String = "nohp";
		/**@private */
		static public const HIDE_LIGHT:String = "hide_light";
		/**@private */
		public const field:String = "global";
		private var _perhp:Number = 20;
		private var _hp:Number = 100;
		private var sp:hpbar;
		public const version:String = "0.6.5.6";
		/**@private */
		public function HPBar() 
		{
			sp = new hpbar();
			addChild(sp);
			hidelight();
			func.setFunc("reduce", { type:Script.NoParams } );
			func.setFunc("increase", { type:Script.NoParams } );
			func.setFunc("showlight", { type:Script.NoParams } );
			func.setFunc("hidelight", { type:Script.NoParams } );
			func.setFunc("perhp", { type:Script.Properties } );
			func.setFunc("hp", { type:Script.Properties } );
		}
		/**
		 * 减少perhp这么多的血量.
		 *  如果血量少于0了会触发NOHP事件
		 * @see #NOHP
		 */
		public function reduce():void
		{
			if(this.hp-perhp>0){
				this.hp = this.hp - perhp;
			}else {
				this.hp = 0;
				dispatchEvent(new Event(HPBar.NOHP, true));
			}
			hidelight();
		}
		/**
		 * 减少perhp这么多的血量.
		 */
		public function increase():void
		{
			if(this.hp + perhp < 100){
				this.hp = this.hp + perhp;
			}else {
				this.hp = 100;
			}
			hidelight();
		}
		/**
		 * 直接设置hp的值.
		 */
		public function set hp(value:Number):void
		{
			hidelight();
			_hp = value;
			TweenLite.to(sp.body, 1, { scaleX:value / 100 } );
		}
		public function get hp():Number
		{
			return _hp;
		}
		/**
		 * 显示高亮.
		 * 就是一闪一闪的那个.长度是perhp那么长.
		 * 这个你不用管.
		 * @see #hidelight()
		 */
		public function showlight():void
		{
			sp.light.visible = true;
			sp.light.play();
			sp.light.x = sp.body.x + sp.body.width - sp.light.width;
		}
		/**
		 * 不显示高亮.
		 * 就是一闪一闪的那个.长度是perhp那么长.
		 * 这个你不用管.
		 * @see #showlight()
		 */
		public function hidelight():void
		{
			sp.light.visible = false;
			sp.light.stop();
		}
		/**
		 * 设置perhp.
		 */
		public function set perhp(value:Number):void
		{
			_perhp = value;
			sp.light.width = 80 * _perhp / 100;
		}
		public function get perhp():Number
		{
			return _perhp;
		}
		/**@private */
		public function saveData(link:String):void
		{
			SAVEManager.appendData(link, {hp:this.hp,perhp:this.perhp } );
		}
		/**@private */
		public function loadData(link:String):void { };
		
	}
	
}