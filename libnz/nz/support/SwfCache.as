package nz.support
{ 
	import flash.display.AVM1Movie;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.core.FlexSprite;
	import mx.core.UIComponent;

	public class SwfCache extends UIComponent implements ICache
	{
		private var capacity:int;
		private var sets:Vector.<Set>;
		private var last_cache:Set;
		private var last_request:Set;
		private var l:Loader; 
		private var lc:Loader;
		public function SwfCache()
		{
			capacity = 5;
			sets = new Vector.<Set>();
			l = new Loader();
			lc = new Loader();
		}
		public function addRequest(r:String):void
		{
			var item:Set = findreq(r);
			if(item==null){
				item = new Set();
				item.g = new Loader();
				item.g.contentLoaderInfo.addEventListener(Event.COMPLETE,complete);
				item.req = r;
				sets.push(item);
			}
			item.hit++;
			if(!item.cached){
				last_request = item;
				item.g.load(new URLRequest(r));
			}else replace(item.g);
			
		}
		public function addCache(r:String):void
		{
			var item:Set = findreq(r);
			if(item==null){
				item = new Set();
				item.g = new Loader();
				item.g.contentLoaderInfo.addEventListener(Event.COMPLETE,cache_complete);
				item.req = r;
				sets.push(item);
			}
			if(!item.cached){
				last_request = item;
				item.g.load(new URLRequest(r));
			}
		}
		private function replace(g:Loader):void
		{
			if(this.numChildren>0)
				this.removeChildAt(0);
			this.addChild(g);
		}
		private function complete(e:Event):void
		{
			last_request.cached = true;
			replace(last_request.g);
		}
		private function cache_complete(e:Event):void
		{
			last_request.cached = true;
		}
		private function findreq(req:String):Set
		{
			for each(var item:Set in sets){
				if(item.req == req)
					return item;
			}
			return null;
		}
	}
	
}
import flash.display.Loader;
import flash.display.MovieClip;

class Set{
	public var g:Loader;
	public var cached:Boolean = false;
	public var hit:int = 0;
	public var req:String;
}