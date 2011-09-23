package nz.support 
{
	import flash.events.IEventDispatcher;
	
	/**
	 * url预加载接手管理接口.
	 * @author codex
	 */
	public interface ILoaderOptimized extends IEventDispatcher
	{
		/**@private**/
		function load(url:Object = null):void;
	}
	
}