package controls
{
	import codex.events.BasisEvent;
	import com.greensock.events.TweenEvent;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import mx.collections.ArrayCollection;
	
	/**
	 * ...
	 * @author CodeX
	 * @help 
	 * for example:
	 * var tm:TimeManage = new TimeManage();
	 * tm.target = obj;
	 * var dp:DataProvider = new DataProvider();
	 * dp.addItem({type:TimeManage.TYPE_MOTION,last:1,beforeState:{x:0},state:{x:100}});
	 * do.addItem({type:TimeManage.TYPE_STILL,last:1,state:{x:50});
	 * tm.motion= dp;
	 * tm.start();
	 */
	public class TimeManage extends EventDispatcher
	{
		//type:
		static public const TYPE_MOTION:String = "type_motion";
		static public const TYPE_STILL:String = "type_still";
		static public const MOTION_COMPLETE:String = "motion_complete";
		private var dp:ArrayCollection;
		private var index:int;
		private var length:int;
		private var timer:Timer;
		static private var delayCallObject:Object;
		static private var delayCallTimer:Timer;
		private var tg:DisplayObject;//target
		private var rpLength:int = 1;//repeat
		private var rpIndex:int =0;
		private var forbid:Object;
		//format: [time,targetList:Array,targetParams:Array]
		static public function ready():void
		{
			if (delayCallTimer == null) {
				delayCallTimer = new Timer(100);
				delayCallTimer.addEventListener(TimerEvent.TIMER, delay_time);
			}
		}
		static public function delayedCall(delay:Number, fs:Function, fsParams:Array = null):void
		{
			delayCallTimer.delay = delay;
			delayCallTimer.start();
			delayCallObject = [fs, fsParams];
		}
		static private function delay_time(e:TimerEvent):void 
		{
			delayCallTimer.stop();
			delayCallObject[0].apply(null, delayCallObject[1]);
		}

		public function TimeManage():void
		{
			dp = new ArrayCollection();
			timer = new Timer(100);
			timer.addEventListener(TimerEvent.TIMER, every_time);
			index = 0;
			forbid = new Object();
			forbid = { ease:true, delay:true };
			addEventListener(Event.COMPLETE, repeat_start);
		}
		public function start():void
		{
			index = 0;
			progress();
			/*var sta:Object = dp.getItemAt(index);
			if (sta.type == TYPE_STILL) {
				timer.delay = sta.last * 1000;
				if (sta.beforeState != undefined) {
					setState(tg,sta.beforeState);
				}
				timer.start();
			}*/
		}
		private function progress():void
		{
			var pro:Object = dp.getItemAt(index);
			if (pro.type == TYPE_STILL) {
				timer.delay = pro.last * 1000;
				if (pro.state != undefined) {
					setState(tg, pro.state);
				}
				timer.start();
			}else {
				if (pro.beforeState != undefined) {
					setState(target, pro.beforeState);
				}
				pro.state.onComplete = every_tween;
				TweenLite.to(tg, pro.last, pro.state);
			}
		}
		private function setState(target:DisplayObject, init:Object):void
		{
			for (var item:String in init) {
				if (forbid[item] != true) {
					target[item] = init[item];
				}
			}
		}
		private function every_time(e:TimerEvent):void
		{
			timer.stop();
			every_tween();
		}
		private function every_tween():void
		{
			if (index + 1 < length) {
				index++;
				progress();
			}else {
				if (repeat == 1) {
					dispatchEvent(new Event(MOTION_COMPLETE));
					rpIndex = 0;
				}else {
					dispatchEvent(new Event(Event.COMPLETE));
				}
			}
		}
		private function repeat_start(e:Event):void
		{
			if (rpIndex +1 < rpLength) {
				rpIndex ++ ;
				start();
			}else {
				rpIndex = 0;
				dispatchEvent(new Event(MOTION_COMPLETE));
			}
		}
		public function set motion(value:ArrayCollection):void
		{
			dp = value;
			length = dp.length;
		}
		public function set target(value:DisplayObject):void
		{
			tg = value;
		}
		public function get target():DisplayObject
		{
			return tg;
		}
		public function set repeat(value:int):void
		{
			rpLength = value;
			rpIndex = 0;
		/*	if (rpLength == 1 && hasEventListener(Event.COMPLETE)) {
				removeEventListener(Event.COMPLETE, repeat_start);
			}else if (rpLength > 1 && !hasEventListener(Event.COMPLETE)) {
				addEventListener(Event.COMPLETE, repeat_start);
			}*/
		}
		public function get repeat():int
		{
			return rpLength;
		}
		
	}
	
}