package nz.enum {
	import mx.core.UIComponent;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	/**
	 * ...
	 * @author c
	 */
	public class Assets {
		static public const SAVE_EVENT:String = "save_event";
		static public const REMOVE_TARGET:String = "remove_target";

		static public const PLAYBUTTON_CLICK:String = "playbutton_click";
		static public const PREVBUTTON_CLICK:String = "prevbutton_click";
		static public const DETERBUTTON_CLICK:String = "deterbutton_click";
		static public const OBJECTBUTTON_CLICK:String = "objectbutton_click";

		static public const TWEEN_COMPLETE:String = "tween_complete";
		static public const SYNC_ARROW:String = "sync_arrow";

		static public const HIDE_LIGHT:String = "hide_light";
		static private const regleft:RegExp = /\[/g;
		static private const regright:RegExp = /]/g;

		public function Assets(){

		}

		static public function nullReplace(n:*, d:*):* {
			if (n == null){
				return d;
			}
			return n;
		}

		static public function formatTextToArray(text:String):Array {
			var ar:Array = text.split(";");
			for (var i:int = 0; i < ar.length; i++){
				ar[i] = Number(ar[i]);
			}
			return ar;
		}

		static public function formatText(text:String):String {
			var str:String = text.replace(regleft, "<");
			str = str.replace(regright, ">");
			return str;
		}

		static public function removeTargets(targets:Array):void {
			for each (var i:DisplayObject in targets){
				i.parent.removeChild(i);
			}
		}

		static public function setVis(target:DisplayObject, vi:int = -1):void {
			if (vi == -1){
				if (target.alpha == 0){
					target.visible = false;
				}
			} else {
				target.visible = Boolean(vi);
			}
		}

		static public function booleanToInt(value:Boolean):int {
			//返回值有 + 1, -1;
			return int(value) * 2 - 1;
		}

		static public function stringToBoolean(value:*):Boolean {
			var bl:Boolean;
			if (value is String){
				if (value.toString() == "false")
					bl = false;
				if (value.toString() == "true")
					bl = true;
			} else {
				bl = value
			}
			return bl;
		}

		static public function arrayToString(arr:Array, mid:String = ""):String {
			var str:String;
			for (var i:int = 0; i < arr.length - 1; i++){
				str += arr[i];
				str += mid;
			}
			str += arr[arr.length - 1];
			return str;
		}

		static public function buttonDispatch(button:Object, event:Event = null):void {
			if (event == null){
				event = new MouseEvent(MouseEvent.CLICK);
			}
			if (button is UIComponent){
				if (button.visible && button.enabled){
					button.dispatchEvent(event);
				}
			} else if (button is DisplayObject){
				if (button.visible == true){
					button.dispatchEvent(event);
				}
			}
		}

		static public function setStyleToTarget(target:UIComponent, up:Class, over:Class, down:Class, fmt:TextFormat = null, icon:* = null):void {
			target.setStyle("upSkin", up);
			target.setStyle("downSkin", down);
			target.setStyle("overSkin", over);
			if (fmt != null){
				target.setStyle("textFormat", fmt);
			}
			if (icon != null){
				target.setStyle("icon", icon);
			}
		}

	}

}