package 
{
	import flash.display.DisplayObject;
	import flash.filters.BitmapFilter;
	public class FilterManager
	{
		private static var filterManagers:Object = new Object();
		public static function getAllFilterManagers():Object
		{
			return filterManagers;
		}
		public static function getFilterManager(name:String):FilterManager
		{
			return filterManagers[name];
		}
		public static function addFilterManager(name:String,value:FilterManager):void
		{
			filterManagers[name] = value;
		}
		public static function removeFilterManager(name:String):void
		{
			filterManagers[name] = null;
		}
		
		
		private var _target:DisplayObject;
		private var filterList:Object;
		private var filterRow:Array;
		public function FilterManager(name:String = null):void
		{
			filterList = new Object();
			filterRow = new Array();
			if (name != null) {
				addFilterManager(name, this);
			}
		}
		public function set target(value:DisplayObject):void
		{
			_target = value;
		}
		public function get target():DisplayObject
		{
			return _target;
		}
		public function getAllFiltersName():Object
		{
			return filterList;
		}
		public function getFilterByName(name:String):BitmapFilter
		{
			return filterRow[filterList[name]];
		}
		public function addFilter(name:String, filter:BitmapFilter):void
		{
			if (filterList[name] == null) {
				filterList[name] = filterRow.length;
				filterRow.push(filter);
			}else {
				filterRow[filterList[name]] = filter;
			}
			update();
		}
		public function removeAllFilters():void
		{
			filterList = { };
			filterRow = [];
			target.filters = [];
		}
		public function removeFilterByName(name:String):void
		{
			var i:int = filterList[name];
			filterRow[i] = filterRow[filterRow.length - 1];
			filterRow.pop();
			filterList[name] = null;
			for (var j:String in filterList) {
				if (filterList[j] == filterRow.length) {
					filterList[j] = i;
				}
			}
			update();
		}
		public function update():void
		{
			target.filters = filterRow;
		}
	}
}
