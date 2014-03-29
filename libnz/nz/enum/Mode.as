package nz.enum
{
	public class Mode
	{
		[Bindable]
		static public var playButtonEnabled:Boolean = false;
		[Bindable]
		static public var objectState:String = "normal";
		[Bindable]
		static public var mainState:String = "normal";
		static public const OBJECT_NORMAL:String = "normal";
		static public const OBJECT_FORCE:String = "object";
		static public const OBJECT_INQUIRE:String = "inquire";
		static public const STATE_INQUIRE:String = "inquire";
		static public const STATE_NORMAL:String = "normal";
		
		static public function set objectModeEnabled(v:Boolean):void
		{
			if(v)
				objectState = "object";
			else
				objectState = "normal";
		}
		public function Mode()
		{
		}
		
	}
}