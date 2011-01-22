package com.nz 
{
	import com.FuncMan;
	import com.Script;
	import mx.core.UIComponent;
	/**
	 * 可视化对象的基类
	 * @author CodeX
	 */
	public class BasicSP extends UIComponent
	{
		/**@private */
		public var func:FuncMan;
		/**@private */
		public var autoVi:Boolean = true;
		/**@private */
		public function BasicSP() 
		{
			func = new FuncMan();
			func.setFunc("x", {type:Script.Properties } );
			func.setFunc("y", {type:Script.Properties } );
			func.setFunc("alpha", { type:Script.Properties } );
			func.setFunc("visible", { type:Script.BooleanProperties } );
			func.setFunc("autoVi", { type:Script.BooleanProperties } );
		}
		/**
		 * 设定横坐标值.
		 */
		override public function set x(value:Number):void
		{
			super.x = value;
		}
		/**
		 * 设定纵坐标值.
		 */
		override public function set y(value:Number):void
		{
			super.y = value;
		}
		/**
		 * 设定透明度值.
		 */
		override public function set alpha(value:Number):void
		{
			super.alpha = value;
		}
		/**
		 * 设定是否显示.
		 */
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
		}
	}

}