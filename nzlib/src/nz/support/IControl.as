package nz.support
{
	public interface IControl
	{
		function pushPage(page:String):void;
		function popPage():void;
		function replacePage(page:String):void;
		function set objectModeEnabled(value:Boolean):void;
	}
}