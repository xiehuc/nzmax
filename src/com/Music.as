package com
{
	import com.nz.EventListBridge;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import com.greensock.TweenLite;
	import lib.tsnds.*;
	import com.nz.ISaveObject;
	import com.nz.Transport;
	import lib.type.female;
	import lib.type.male;
	import lib.type.writer;
	/**
	 * 控制背景音乐播放的类.
	 * 
	 * <p>[snd]可以使用的库声音列表.</p>
	 * <ul>
	 * <li><b>ding</b></li>
	 * <li><b>bam</b></li>
	 * <li><b>key</b></li>
	 * <li><b>shock</b></li>
	 * <li><b>objection</b></li>
	 * <li><b>slap</b></li>
	 * <li><b>slide</b></li>
	 * <li><b>whip</b></li>
	 * <li><b>whoops</b></li>
	 * <li><b>震惊四座</b></li>
	 * </ul>
	 * <table class="innertable">
	 * <tr><th>标签</th><td>值</td></tr>
	 * <tr><th>Link:</th><td>Music</td></tr>
	 * <tr><th>可创建:</th><td>否</td></tr>
	 * <tr><th>可存档:</th><td>是</td></tr>
	 * </table>
	 * @author CodeX
	 */
	public class Music extends EventDispatcher implements ISaveObject
	{
		/**@private */
		static public const MODE_OVERWRITE:String = "overwrite";//原来的就没有了.
		/**@private */
		static public const MODE_PASSOVER:String = "passover";//原来的在播放.就放弃
		/**@private */
		static public const MODE_APPEND:String = "append";//都有
		/**@private */
		static public const MODE_SUPERAPPEND:String = "superappend";//都有。而且不会改变overchn
		/**@private */
		public const field:String = "global";
		private var _func:FuncMan;
		private var snd:Sound;
		private var chn:SoundChannel;
		private var trans:SoundTransform;
		private var overchn:SoundChannel;
		private var oversnd:Sound;
		private var overLength:Number = 0;
		private var BGSoundURL:String="";
		private var _volumn:Number = 1;
		private var replay:Boolean = true;
		private var textSound:Object;
		private var pi:Number;//Pause Time
		/**@private */
		public function Music() 
		{
			textSound = new Object();
			textSound["ding"] = new lib.tsnds.ding();
			textSound["bam"] = new bam();
			textSound["key"] = new key();
			textSound["shock"] = new shock();
			textSound["objection"] = new objection();
			textSound["slap"] = new slap();
			textSound["slide"] = new slide();
			textSound["whip"] = new whip();
			textSound["whoops"] = new whoops();
			textSound["震惊四座"] = new zjsz();
			
			_func = new FuncMan();
			func.setFunc("load", { type:Script.SingleParams } );
			func.setFunc("volumn", { type:Script.Properties } );
			func.setFunc("stop", { type:Script.NoParams } );
			func.setFunc("pause", { type:Script.NoParams } );
			func.setFunc("resume", { type:Script.NoParams } );
			func.setFunc("play", { type:Script.NoParams } );
		}
		/**
		 * 加载mp3声音.
		 * @param	path 声音文件路径
		 */
		public function load(value:String):void
		{
			if (value == "") {
				return;
			}
			if (chn != null) {
				chn.stop();
			}
			BGSoundURL = value;
			snd = new Sound();
			snd.addEventListener(IOErrorEvent.IO_ERROR, Transport.getEvent(EventListBridge.IO_ERROR_EVENT));
			//snd.load(new URLRequest(FileManage.getResolvePath(value)));
			snd.addEventListener(Event.COMPLETE, snd_complete);
			LoaderOptimizer.dispatchLoad(snd, FileManage.getResolvePath(value),true);
		}
		/**
		 * 暂停声音播放.
		 */
		public function pause():void
		{
			pi = chn.position;
			chn.stop();
		}
		/**
		 * 回复声音播放.需要先使用pause();
		 */
		public function resume():void
		{
			chn = snd.play(pi);
			pi = 0;
		}
		/**
		 * 设置音量.
		 */
		public function set volumn(value:Number):void
		{
			_volumn = value;
			if (chn == null) {
				return;
			}
			trans = chn.soundTransform;
			trans.volume = value;
			chn.soundTransform = trans;
		}
		public function get volumn():Number
		{
			return _volumn;
		}
		/**@private */
		public function saveData(link:String):void
		{
			SAVEManager.appendData(link, {load:BGSoundURL,volumn:this.volumn } );
		}
		/**@private */
		public function loadData(link:String):void { };
		/**@private */
		public function get func():FuncMan
		{
			return _func;
		}
		/**@private */
		public function delayVolumn():void
		{
			if (chn == null) {
				return;
			}
			TweenLite.delayedCall(3, delayVolumnContinue,[_volumn]);
			volumn = 0;
		}
		private function delayVolumnContinue(v:Number):void
		{
			TweenLite.to(this,3,{volumn:v})
		}
		/**@private */
		public function overStream(snd:Sound):void
		{
			overStop();
			oversnd = snd;
			overchn = snd.play();
			overchn.addEventListener(Event.SOUND_COMPLETE, re_overStream);
		}
		/**@private */
		public function overContinue():void
		{
			overStream(oversnd);
		}
		/**@private */
		public function overStop():void
		{
			if (overchn == null) {
				return;
			}
			overchn.stop();
		}
		private function re_overStream(e:Event):void 
		{
			overchn = oversnd.play();
			overchn.addEventListener(Event.SOUND_COMPLETE, re_overStream);
		}
		/**@private */
		public function attachTextSound(link:String):void
		{
			//频率要为22KHZ
			if (textSound[link] != null) {
				attach(textSound[link], MODE_SUPERAPPEND);
			}else {
				var tsnd:Sound = new Sound();
				tsnd.addEventListener(Event.COMPLETE, textSound_load_complete);
				tsnd.addEventListener(IOErrorEvent.IO_ERROR, Transport.getEvent(EventListBridge.IO_ERROR_EVENT));
				tsnd.load(new URLRequest(FileManage.getResolvePath(link)));
			}
		}
		/**
		 * 停止所有播放的声音.
		 */
		public function stop():void
		{
			if (chn != null) {
				chn.stop();
			}
			if (overchn != null) {
				overchn.stop();
			}
		}
		public function play():void
		{
			chn = snd.play(0,0,trans);
			chn.addEventListener(Event.SOUND_COMPLETE, chn_complete);
		}
		private function textSound_load_complete(e:Event):void 
		{
			e.currentTarget.play();
		}
		/**@private */
		public function attach(snd:Sound,mode:String = "append"):void
		{
			if (overchn == null) {
				overchn = snd.play();
				overLength = snd.length;
				return;
			}
			switch(mode) {
				case MODE_SUPERAPPEND:
					snd.play();
				break;
				case MODE_APPEND:
					overchn = snd.play();
					overLength = snd.length;
				break;
				case MODE_OVERWRITE:
					overchn.stop();
					overchn = snd.play();
					overLength = snd.length;
				break;
				case MODE_PASSOVER:
					if (overchn.position >= overLength) {
						overchn = snd.play();
						overLength = snd.length;
					}
				break;
			}
		}
		private function snd_complete(e:Event):void 
		{
			play();
		}
		private function chn_complete(e:Event):void 
		{
			if(replay){
				load(BGSoundURL);
			}
		}
	}
	
}