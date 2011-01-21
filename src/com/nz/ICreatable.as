package com.nz 
{
	/**
	 * 可创建类的接口
	 * @author codex
	 */
	public interface ICreatable 
	{
		/**@private */
		function set autoAddDisplayRoot(value:Boolean):void 
		/**@private */
		function get autoAddDisplayRoot():Boolean 
		/**
		 * 设置创建类型.
		 */
		function set type(value:String):void 
		function get type():String 
		/**
		 * 设置父级显示对象.
		 */
		function set displayParent(value:String):void
		function get displayParent():String
		/**@private */
		function set regit(value:Boolean):void
		/**@private */
		function get regit():Boolean
		/**@private */
		function creationComplete():void
		/**@private */
		function remove():void
	}
}