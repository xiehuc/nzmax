package nz.support
{ 
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.core.FlexSprite;
	import mx.core.UIComponent;
	
	import org.bytearray.gif.player.GIFPlayer;

	public class SeqCache extends UIComponent implements ICache
	{
		private var capacity:int;
		private var sets:Vector.<Set>;
		private var last_cache:Set;
		private var last_req:Set;
		private var l:URLLoader; 
		private var lc:URLLoader;
		public function SeqCache()
		{
			capacity = 5;
			sets = new Vector.<Set>();
			l = new URLLoader();
			lc = new URLLoader();
			l.dataFormat = lc.dataFormat =  "binary";
			l.addEventListener(Event.COMPLETE,complete);
			lc.addEventListener(Event.COMPLETE,cache_complete);
		}
		public function addRequest(r:String):void
		{
			var item:Set = findreq(r);
			if(item==null){
				item = new Set();
				item.req = r;
				sets.push(item);
			}
			item.hit++;
			if(!item.cached){
				last_req = item;
				l.load(new URLRequest(r));
			}else replace(item.g);
		}
		public function addCache(r:String):void
		{
			var item:Set = findreq(r);
			if(item==null){
				item = new Set();
				item.req = r;
				sets.push(item);
			}
			if(!item.cached){
				last_cache = item;
				l.load(new URLRequest(r));
			}
		}
		private function replace(g:GIFPlayer):void
		{
			if(this.numChildren){
				this.addChild(g);
				this.removeChildAt(0);
			}else
				this.addChild(g);
		}
		private function complete(e:Event):void
		{
			last_req.g = new GIFPlayer();
			last_req.g.loadBinary((e.currentTarget as URLLoader).data as ByteArray);
			last_req.cached = true;
			replace(last_req.g);
		}
		private function cache_complete(e:Event):void
		{
			last_cache.g = new GIFPlayer();
			last_cache.g.loadBinary((e.currentTarget as URLLoader).data as ByteArray);
			last_cache.cached = true;
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
import org.bytearray.gif.player.GIFPlayer;
class Set{
	public var g:GIFPlayer;
	public var cached:Boolean = false;
	public var hit:int = 0;
	public var req:String;
}