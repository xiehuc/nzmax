package ui
{
	
	/**
	 * ...
	 * @author c
	 */
	import com.greensock.TweenLite;
	
	import cont.Grid_;
	import cont.More_bg_;
	import cont.snds.sure_;
	import cont.snds.zwhd;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.text.TextField;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.core.FlexSprite;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;
	
	import nz.Transport;
	import nz.enum.BasisEvent;
	import nz.enum.FrameInstance;
	import nz.manager.GroupManager;
	
	import spark.components.Button;
	
	import ui.PaneCell;

	public class GridPane extends UIComponent
	{
		private var cx:Number;
		private var cy:Number;
		private var cellList:Array;
		private var _group:String;
		private var _currentCellIndex:int = 0;
		//对小单元格子索引,一直可用
		public var currentIndex:int = 0;//对大的格子背景的索引
		public var title:Button;
		public var length:int = 0;
		public var _expandMode:Boolean = false;
		private var gm:GroupManager;
		public var downbar:MovieClip;
		private var h:Number;
		private var paneArea:UIComponent;
		private var iconArea:UIComponent;
		private var more_bg:More_bg_;
		private var overIconArea:UIComponent;
		
		//[Event(name = "select_event", type = "controls.PaneCell")]
		[Event(name = "notice_event", type = "controls.PaneCell")]
		[Event(name = "creation_complete", type = "controls.PaneCell")]
		[Event(name = "detail_reg", type = "controls.PaneCell")]
		[Event(name = "sidebar_check", type = "controls.PaneCell")]
		[Event(name = "expand_mode_open", type = "controls.PaneCell")]
		[Event(name = "expand_mode_close", type = "controls.PaneCell")]
		[Event(name = "sync_pane", type = "controls.PaneCell")]
		public function GridPane(disroot:String)
		{
			cellList = new Array();
			cx = 105;
			cy = 50;
			paneArea = new UIComponent();
			addChild(paneArea);
			iconArea = new UIComponent();
			addChild(iconArea);
			more_bg = new More_bg_();
			addChild(more_bg);
			more_bg.x = 128;
			more_bg.y = -more_bg.height / 2;
			more_bg.visible = false;
			overIconArea = new UIComponent();
			addChild(overIconArea);
			addPane();
			if (Transport.DisplayRoot == null) {
				Transport.DisplayRoot = new Object();
			}

			Transport.DisplayRoot[disroot] = iconArea;
			addEventListener(PaneCell.CREATION_COMPLETE, cell_creation_complete);
			addEventListener(PaneCell.REMOVE, cell_remove);
		}
		public function show(oldf:String):void 
		{
			if (oldf == FrameInstance.PLUGINFRAME) {
				return;
			}
			if(cellLength>0){
				gm.currentIndex = 0;
			}
			if (expandMode) {
				dispatchEvent(new Event(PaneCell.DETAIL_REG));
			}
			paneArea.x = 0;
			iconArea.x = 0;
			currentIndex = 0;
			bar_check();
		}
		public function get currentCellIndex():int
		{
			return gm.currentIndex;
		}
		public function set currentCellIndex(value:int):void
		{
			gm.currentIndex = value;
		}
		public function set group(value:String):void
		{
			_group = value;
			gm = new GroupManager(value);
			gm.addEventListener(IndexChangedEvent.CHANGE, gm_change);
			gm.dataProvider = cellList;
		}
		
		private function gm_change(e:IndexChangedEvent):void 
		{
			title.label = getCellAt(e.newIndex).name;
		}
		public function get group():String
		{
			return _group;
		}
		override public function get height():Number
		{
			return h;
		}
		public function set expandMode(value:Boolean):void
		{
			_expandMode = value;
		}
		public function get expandMode():Boolean
		{
			return _expandMode;
		}
		public function expand(index:int, motion:Boolean = false,sync:Boolean = true):void
		{
			expandMode = true;
			more_bg.visible = true;
			more_bg.x = 128;
			TweenLite.to(more_bg, 1.5, { x: -128 } );
			TweenLite.to(paneArea, 1.5, { alpha:0 } );
			if(currentCell != null){
				overIconArea.addChild(currentCell as DisplayObject);
				currentCell.expand(motion);
			}
			if(sync) dispatchEvent(new BasisEvent(PaneCell.SYNC_PANE, false, false, true));
			dispatchEvent(new Event(PaneCell.EXPAND_MODE_OPEN, true));
			if(motion){
				dispatchEvent(new Event(PaneCell.DETAIL_REG));
			}
		}
		public function unexpand(motion:Boolean = false,sync:Boolean = true):void
		{
			expandMode = false;
			this.reSetPlaceIcons();
			this.more_bg_close(motion);
			if(currentCell != null){
				this.currentCell.unexpand(motion);
				TweenLite.delayedCall(1.6, iconArea.addChild, [currentCell as DisplayObject]);
			}
			if(sync)dispatchEvent(new BasisEvent(PaneCell.SYNC_PANE, false, false, false));
			dispatchEvent(new Event(PaneCell.EXPAND_MODE_CLOSE, true));
		}
		public function nextScene():void
		{
			attachNewSound(zwhd);
			if(expandMode == false){
				TweenLite.to(paneArea, 1,{ x:paneArea.x - 256 } );
				TweenLite.to(iconArea, 1,{ x:iconArea.x - 256 } );
				currentIndex++;
				bar_check();
			}else {
				var cell:PaneCell = getCellAt(currentCellIndex + 1);
				if (cell.expanded == false) {
					cell.expand();
				}else {
					cell.visible = true;
				}
				cell.x = currentCell.x + 256;
				overIconArea.addChild(cell);
				TweenLite.to(overIconArea, 1 , { x:overIconArea.x - 256, onComplete:expand_scene, onCompleteParams:[1] } );
				gm.currentIndex++;
			}
		}
		public function prevScene():void
		{
			attachNewSound(zwhd);
			if(expandMode == false){
				TweenLite.to(paneArea,1, { x:paneArea.x + 256 } );
				TweenLite.to(iconArea,1, { x:iconArea.x + 256 } );
				currentIndex--;
				bar_check();
			}else {
				var cell:PaneCell = getCellAt(currentCellIndex - 1);
				if (cell.expanded == false) {
					cell.expand();
				}else {
					cell.visible = true;
				}
				cell.x = currentCell.x - 256;
				overIconArea.addChild(cell);
				TweenLite.to(overIconArea, 1 , { x:overIconArea.x + 256, onComplete:expand_scene, onCompleteParams:[ -1] } );
				gm.currentIndex--;
			}
		}
		private function expand_scene(direction:int):void
		{
			getCellAt(currentCellIndex-direction).visible = false;
			currentCell.x = 0;
			overIconArea.x = 0;
			dispatchEvent(new Event(PaneCell.DETAIL_REG));
			bar_check();
		}
		public function deltaMove(delta:int):void
		{
			attachNewSound(sure_);
			if (currentCell.page == 0 && currentCell.column == 0 && delta == -1) {
				//第一列移动不许
				currentCell.select();
				return;
			}
			if (currentCell.page == length - 1 && currentCell.column == 3 && delta == 1) {
				//最后一列移动不许
				currentCell.select();
				return;
			}
			if (currentCell.index == cellList.length - 1 && delta == 1) {
				//最后一个移动不许
				currentCell.select();
				return;
			}
			if (delta == 0) {
				if (currentCell.row == 0) {
					if (currentCellIndex +4 < cellList.length) gm.currentIndex += 4;
				}
				else gm.currentIndex -= 4;
			}else {
				if (currentCell.column == 3 && delta == 1) {
					if(currentCellIndex +5<cellList.length){
						gm.currentIndex += 5;
					}else {
						gm.currentIndex += 1;
					}
					nextScene();
				}else if (currentCell.column == 0 && delta == -1) {
					gm.currentIndex -= 5;
					prevScene();
				}else {
					gm.currentIndex += delta;
				}
			}
		}
		private function cell_remove(e:Event):void 
		{
			var cell:PaneCell = e.target as PaneCell;
			for (var i:int=cell.index+1; i < cellList.length; i++) {
				cellList[i - 1] = cellList[i];
				getCellAt(i - 1).index --;
				getCellIndexes(getCellAt(i - 1));
			}
			cellList.pop();
			if (cellList.length>0&&getCellAt(cellList.length - 1).page < length - 1) {
				removePane();
			}
		}
		private function cell_creation_complete(e:Event):void 
		{
			e.stopImmediatePropagation();
			var cell:PaneCell = e.target as PaneCell;
			cell.addEventListener(MouseEvent.CLICK, cell_click);
			cell.index = cellList.length;
			cell.group = this.group;
			getCellIndexes(cell);
			cellList.push(cell);
			if (cell.page > length - 1) {
				addPane();
			}
		}
		public function addCell(cell:PaneCell):void
		{
			getCellIndexes(cell);
			iconArea.addChild(cell);
		}
		public function get cellLength():int
		{
			//对小单元格子的总数,一直可用
			return cellList.length;
		}
		public function get currentCell():PaneCell
		{
			return getCellAt(currentCellIndex);
		}
		public function getCellByName(name:String):PaneCell
		{
			for each(var cell:PaneCell in cellList) {
				if (cell.linkName == name) {
					return cell;
					break;
				}
			}
			return null;
		}
		public function getCellAt(index:int):PaneCell
		{
			if (index == -1) {
				return null;
			}
			return cellList[index];
		}
		public function more_bg_close(motion:Boolean = false):void
		{
			if(motion == true){
				TweenLite.to(more_bg, 1.5, { x: -128 - 256, onComplete:setVis, onCompleteParams:[more_bg] } );
				TweenLite.to(paneArea, 1.5, { alpha:1 } );
			}else {
				more_bg.x = -128 - 256;
				setVis(more_bg);
				paneArea.alpha = 1;
			}
		}
		private function getCellIndexes(cell:PaneCell):void
		{
			cell.page = Math.floor(cell.index / 8);
			cell.column = cell.index % 8 % 4;
			cell.row = Math.floor(cell.index % 8 / 4);
			cell.x = cell.page * 256 - cx + 13 + cell.column * 48;
			cell.y = -cy + 6 + cell.row * 48;
		}
		public function bar_check():void
		{
			dispatchEvent(new Event(PaneCell.SIDEBAR_CHECK));
		}
		private function cell_click(e:MouseEvent):void 
		{
			attachNewSound(sure_);
			expand((e.currentTarget as PaneCell).index, true);
		}
		private function setVis(target:DisplayObject):void
		{
			target.visible = false;
		}
		public function reSetPlaceIcons():void
		{
			if(currentCell != null){
				overIconArea.addChildAt(this.currentCell, 0);
				currentIndex = currentCell.page;
			}
			paneArea.x = -256 * currentIndex;
			iconArea.x = paneArea.x;
			for (var i:int = overIconArea.numChildren-1; i>=1; i--) {
				var cell:PaneCell = overIconArea.getChildAt(i) as PaneCell;
				iconArea.addChild(cell);
				cell.unexpand();
				cell.visible = true;
			}
		}
		private function addPane():void
		{
			var p:Grid_ = new Grid_();
			p.x = length * 256 - cx;
			p.y = -cy;
			length ++;
			paneArea.addChild(p);
			bar_check();
		}
		private function removePane():void
		{
			length --;
			paneArea.removeChildAt(paneArea.numChildren - 1);
			bar_check();
		}
		private function attachNewSound(c:Class):void
		{
			var ns:Sound = new c();
			ns.play();
		}
	}
}
