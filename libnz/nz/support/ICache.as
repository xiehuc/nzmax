package nz.support
{
	import mx.core.IFlexDisplayObject;
	import mx.core.IUIComponent;

	public interface ICache extends IUIComponent
	{
		function addRequest(r:String):void;
		function addCache(r:String):void;
	}
}