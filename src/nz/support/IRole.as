package nz.support
{
	public interface IRole extends ICreatable,ISaveObject,ILoaderOptimized
	{
		function get linkName():String;
		function get name():String;
		function speak(s:Boolean):void;
		function get sex():String;
		function get group():String;
		function set visible(v:Boolean):void;
		function get visible():Boolean;
		function set emotion(emo:String):void;
		function get emotion():String;
		function voice(name:String):void
	}
}