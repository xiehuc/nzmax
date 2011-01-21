package com
{
	import flash.events.Event;
	import com.nz.Transport;
	import com.nz.EventListBridge;
	import flash.display.MovieClip;
	import mx.controls.Alert;
	public class RoleX extends Role
	{
		protected var info:XML;
		
		public function RoleX()
		{
			
		}
		override public function set emotion(value:String):void
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
			if (info.action.(@emo == emo) != undefined) {
				mc.addEventListener(Event.FRAME_CONSTRUCTED, action_start);
				active();
				dispatchEvent(new Event(Script.SCRIPT_PAUSE, true));
				Transport.Pro["upText"].show(false);
			}
			_emotion = emo;
			mc.gotoAndStop(emo);
		}
		override protected function loader_complete(e:Event):void
		{
			
			mc = this.content as MovieClip;
			loadFinish = true;
			info = (mc.info == undefined) ? new XML() : mc.info;
			for (var i:int = 1; i <= mc.currentLabels.length; i++) {
				labelToIndex[mc.currentLabels[i-1].name] = i;
			}
			(_emotion == null) ? this.emotion = "normal" :this.emotion = _emotion;
			if(this.sex == null)
			//(mc.sex == undefined) ? this.sex = "male":this.sex = mc.sex;
			this.sex = info.sex.toString();
			 //强制把之前emotion没有执行完的补上
		}
	}
}