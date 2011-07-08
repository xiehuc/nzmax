package org.nochump.zip 
{
	import flash.utils.ByteArray;
	import org.nochump.zip.ZipEntry;
	import org.nochump.zip.ZipFile;
	
	/**
	 * 用于读取zip文件
	 * @author Jaja as-max.cn
	 */
	public class ZipReader extends ZipFile
	{
		private var _names:Array = new Array;
		
		public function ZipReader(bytes:ByteArray) :void
		{
			super(bytes);
			
			for (var i:int = 0; i < entries.length; i++) {
				_names.push(ZipEntry(entries[i]).name);
			}
		}
		
		/**
		 * 获得zip文件中的文件名称数组
		 * @return
		 */
		public function get names():Array {
			return _names;
		}
		
		/**
		 * 通过文件名称获得文件的数据字节数组
		 * @param	name
		 * @return
		 */
		public function getFile(name:String):ByteArray {
			return getInput(getEntry(name));
		}
		
	}
	
}