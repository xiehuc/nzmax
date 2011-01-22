package com.nz 
{
	import flash.display.DisplayObject;
	
	/**
	 * 插件接口.
	 * @author codex
	 */
	public interface IPlugin
	{
		/**@private */
		function get type():String//返回内部类型
		/**@private */
		function set type(value:String):void
		/**@private */
		function get pluginType():String//返回插件类型
		/**@private */
		function get content():DisplayObject
		/**
		 * 初始化滤镜.
		 * 滤镜"生存期"的开始.
		 */
		function init(xml:XML, blank:String = null):void;
		/**@private */
		function close():void;//'生存期'结束
		//如果是证物类型.由外部调用.否则由内部调用
	}
	
}