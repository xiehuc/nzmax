package com.nz 
{
	
	/**
	 * 可存档类的接口
	 * @author codex
	 */
	public interface ISaveObject 
	{
		/**@private */
		function saveData(link:String):void;
		/**@private */
		function loadData(link:String):void;
		
	}
	
}