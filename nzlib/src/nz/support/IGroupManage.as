package nz.support 
{
	
	/**
	 * 组管理的接口.
	 * 不是Role的那个group.
	 * @author codex
	 */
	public interface IGroupManage 
	{
		/**@private */
		function select(result:Boolean = true):void;
		/**@private */
		function isSelect():Boolean;
		/**@private */
		function get group():String;
		/**@private */
		function set group(value:String):void;
		/**@private */
		function get index():int;
		/**@private */
		function set index(value:int):void;
	}
	
}