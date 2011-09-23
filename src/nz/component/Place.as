package nz.component 
{
	/**
	 * ...
	 * @author codex
	 */
	public class Place
	{
		public var oriXML:XML;
		public var content:XML;
		public var firsttalk:Boolean;
		public var enable:Boolean;
		public function Place(x:XML) 
		{
			oriXML = x;
			enable = (x.@enable.toString() != "false");
		}
		public function get label():String
		{
			return oriXML.@label.toString();
		}
		public function get background():String
		{
			return oriXML.@background.toString();
		}
		public function get version():Number
		{
			if (this.content == null) {
				return 0;
			}
			return Number(this.content.version.toString());
		}
		
	}

}