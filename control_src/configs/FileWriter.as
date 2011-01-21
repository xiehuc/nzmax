package configs 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.OutputProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author codex
	 */
	public class FileWriter extends EventDispatcher
	{
		[Event(name="close",type="flash.events.Event")]
		public var fs:FileStream;
		
		public function FileWriter() 
		{
			fs = new FileStream();
			fs.addEventListener(Event.CLOSE, dispatchEvent);
			fs.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS, dispatchEvent);
		}
		public function writeFile(by:ByteArray,name:String, folder:File):void
		{
			var f:File = folder.resolvePath(name);
			if ( name.lastIndexOf("/") == name.length-1 ) {
				f.createDirectory();
				dispatchEvent(new Event(Event.CLOSE));
				return;
			}
			fs.openAsync(folder.resolvePath(name), FileMode.WRITE);
			fs.writeBytes(by, 0, by.length);
			fs.close();
		}
		
	}

}