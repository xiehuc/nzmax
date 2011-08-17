package nz.support
{
	public interface IControl
	{
		function pushPage(page:String):void;
		function popPage():void;
		function set playButtonEnabled(value:Boolean):void;
		function set objectModeEnabled(value:Boolean):void;
	}
}