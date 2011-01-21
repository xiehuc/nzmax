package com.nz
{
	
	/**
	 * 证物详细插件的类型枚举.
	 * @see controls.PaneCell#detail()
	 * @author CodeX
	 */
	public class ObjectItemType 
	{
		/**
		 * 照片证物类型.
		 * @example
		 * <listing version="3.0">
		 * &lt;content &gt;photo.jpg&lt;/content &gt;
		 * </listing>
		 */
		static public const PHOTO:String = "photo";
		/**
		 * 报告证物类型.注意.Flash使用的换行符和windows有一些区别.
		 * 书写的时候可以回行.把多余的空格删除了(顶格).
		 * @example
		 * <listing version="3.0">
		 * &lt;content &gt;
		 * 设置文字
		 * 设置文字
		 * &lt;/content &gt;
		 * </listing>
		 */
		static public const REPORT:String = "report";
	}
	
}