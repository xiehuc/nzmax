package org.nochump.zip
{
	import flash.utils.ByteArray;
	import org.nochump.zip.ZipEntry;
	import org.nochump.zip.ZipOutput;
	
	/**
	 * 该类用于创建zip文件
	 * @author Jaja as-max.cn
	 */
	public class ZipWriter extends ZipOutput
	{
		
		public function ZipWriter() 
		{
			
		}
		
		/**
		 * 向zip文件中添加一个文件
		 * @param	path 要添加的文件的路径,如:test.txt,package/test.txt
		 * @param	bytes 要添加的文件的二进制数据
		 */
		public function addFile(path:String, bytes:ByteArray):void {
			var entry:ZipEntry = new ZipEntry(path);
			putNextEntry(entry);
			write(bytes);
		}
		
	}
	
}