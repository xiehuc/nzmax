package nz
{
	import nz.manager.FileManager;
	import nz.support.Initer;

	public class DefaultIniter implements Initer
	{
		public function DefaultIniter()
		{
		}
		public function initWithConfig(config:XML):void
		{
			nz.support.GlobalKeyMap.init(config.keyMap[0]);
			FileManager.initComlib(config.path.comlib);
			FileManager.STORY_DIR = config.path.story;
		}
	}
}