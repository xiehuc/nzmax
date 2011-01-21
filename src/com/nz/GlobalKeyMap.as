package com.nz 
{
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author ...
	 */
	public class GlobalKeyMap
	{
		static public var ConfirmButton:int;
		static public var CancelButton:int;
		static public var SelectButton:int;
		static public var MenuButton:int;
		static public var LButton:int;
		static public var RButton:int;
		static public var LeftArrow:int;
		static public var RightArrow:int;
		static public var UpArrow:int;
		static public var DownArrow:int;
		static public var FocusButton:DisplayObject;
		
		static public function init(source:XML):void
		{
			ConfirmButton = int(source.Confirm);
			CancelButton = int(source.Cancel);
			SelectButton = int(source.Select);
			MenuButton = int(source.Menu);
			LButton = int(source.LButton);
			RButton = int(source.RButton);
			LeftArrow = int(source.Left);
			RightArrow = int(source.Right);
			UpArrow = int(source.Up);
			DownArrow = int(source.Down);
		}
		public function GlobalKeyMap() 
		{
			
		}
		
		
	}

}