package
{
	
	/**
	 * ...
	 * @author c
	 */
	public class FileType 
	{
		public static const ImageType:String = "imagetype";
		public static const TextType:String = "texttype";
		public static const XMLType:String = "xmltype";
		public static const SwfType:String = "swftype";
		private static const type:Object = { png:ImageType, bmp:ImageType, jpg:ImageType,
											txt:TextType, xml:XMLType,
											swf:SwfType};
		public function FileType():void
		{
		}
		public static function getType(url:String):String
		{
			var c:String = url.slice(url.lastIndexOf(".") + 1, url.length);
			c = c.toLowerCase();
			return type[c];
		}
		static public function getName(url:String):String
		{
			//format(url);
			var c:String = url.slice(url.lastIndexOf("/") + 1, url.lastIndexOf("."));
			return c;
		}
		
	}
	
}