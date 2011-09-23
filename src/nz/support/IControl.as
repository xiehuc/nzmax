package nz.support
{
	public interface IControl
	{
		function pushPage(page:String):*;
		function popPage():void;
		function replacePage(page:String):void;
	}
}