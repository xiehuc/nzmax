package ui.frames
{
	import spark.components.Button;
	
	/**
	 * ...
	 * @author codex
	 */
	public class TalkButton extends Button
	{
		public var topic:XML;
		public function TalkButton() 
		{
			this.styleName = "talkButtonStyle";
			this.width = 140;
			this.height = 26;
			this.x = 11;
		}
		
	}

}