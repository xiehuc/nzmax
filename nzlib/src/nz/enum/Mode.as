package nz.enum
{
	public class Mode
	{
		[Bindable]
		static public var playButtonEnabled:Boolean = false;
		[Bindable]
		static public var objectState:String = "normal";
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