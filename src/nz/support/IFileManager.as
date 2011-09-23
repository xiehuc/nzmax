package nz.support
{
	public interface IFileManager
	{
		/**
		 * 使用一次
		 */
		function setDirectory(dir:String,globalhost:String = ""):void;
		/**
		 * 加载已经完成的
		 */
		function setStoryInfo(info:XML):void;
		function getStoryPath():String;
		function getResolvePath(path:String):String;
		function rescan():void
	}
}