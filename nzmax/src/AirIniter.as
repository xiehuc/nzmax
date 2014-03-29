package
{
	import nz.DefaultIniter;
	import nz.support.Initer;

	public class AirIniter extends DefaultIniter implements Initer
	{
		private var fileframe:FileFrame;
		public function AirIniter()
		{
		}
		public override function initWithConfig(config:XML):void
		{
			super.initWithConfig(config);
			//fileframe.init();
		}
	}
}