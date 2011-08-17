package nz.manager
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import mx.events.IndexChangedEvent;
	/**
	 * ...
	 * @author codex
	 */
	public class GroupManager extends EventDispatcher
	{
		[Event(name = "change", type = "mx.events.IndexChangedEvent")]
		static private var groupSource:Object = new Object();
		static public function getGroupManage(g:String):GroupManager
		{
			return groupSource[g];
		}
		static public function addGroupManage(g:String, gm:GroupManager):void
		{
			groupSource[g] = gm;
		}
		static public function removeGroupManage(g:String):void
		{
			groupSource[g] = null;
		}
		
		private var dataSource:Array;
		private var _currentIndex:int;
		private var oldIndex:int;
		public function GroupManager(g:String = null) 
		{
			dataSource = new Array();
			_currentIndex = 0;
			oldIndex = 0;
			if (g != null) {
				addGroupManage(g, this);
			}
		}
		[Bindable]
		public function set currentIndex(i:int):void
		{
			dataSource[i].select();
		}
		public function get currentIndex():int
		{
			return _currentIndex;
		}
		public function refresh(exclude:Object):void
		{//刷新.排除错误
			for (var index:String in dataSource) {
				if (dataSource[index].isSelect() && dataSource[index]!=exclude) {
					dataSource[index].select(false);
					break;
				}
			}
		}
		public function updateIndex(index:int,result:Boolean):void
		{
			if (result) {
				oldIndex = _currentIndex;
				_currentIndex = index;
				dataSource[oldIndex].select(false);
				dispatchEvent(new IndexChangedEvent(IndexChangedEvent.CHANGE, false, false, null, oldIndex, _currentIndex));
			}
		}
		public function set dataProvider(value:Array):void
		{
			dataSource = value;
		}
		public function get dataProvider():Array
		{
			return dataSource;
		}
		
	}

}
