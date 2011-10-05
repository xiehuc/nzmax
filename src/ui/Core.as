// ActionScript file
package ui
{
	import mx.collections.ArrayCollection;
	
	import nz.Transport;
	import nz.component.HPBar;
	import nz.component.Role;
	import nz.component.Script;
	import nz.enum.FrameInstance;
	import nz.enum.Mode;
	import nz.manager.FuncMan;
	import nz.support.IControl;
	
	import spark.components.Group;
	
	import ui.frames.BackFrame;
	import ui.frames.ObjectFrame;
	import ui.frames.PlayFrame;
	import ui.frames.SelectorFrame;

	public class Core extends Group implements IControl
	{
		public const version:String = "0.8.1.9"
		/**@private */
		public const field:String = "Control";
		/**@private */
		public var func:FuncMan//储存function设定;
		protected var pageList:Object;
		private var _objectmode:Boolean;
		private var pluginList:Object;
		/**@private */
		public var currentFrame:String;
		private var oldFrame:String;
		public var objectDp:ArrayCollection;
		public var roleDp:ArrayCollection;
		public function Core()
		{
			pageList = new Object();
			objectDp = new ArrayCollection();
			roleDp = new ArrayCollection();
			
			Transport.CreateTypeList["ObjectItem"] = ObjectPaneItem;
			Transport.CreateTypeList["RoleItem"] = RolePaneItem;
			Transport.DisplayRoot["ObjectPane"] = objectDp;
			Transport.DisplayRoot["RolePane"] = roleDp;
			
			objectModeEnabled = false;
			
			
			func = new FuncMan();
			Script.registProcess("objection",pushObjection,null,["target","answer","<init>","<error>","<currect>"]);
			Script.registProcess("selector",selector,null,["*"]);
			func.setFunc("chooseSet", { type:Script.ComplexParams, down:false, progress:false } );
			func.setFunc("pushPage",{type:Script.SingleParams});
			func.setFunc("popPage",{type:Script.NoParams});
		}
		public function selector(child:XMLList):void
		{
			Transport.send('<Script stop="true"/>');
			var dp:ArrayCollection = new ArrayCollection();
			for each(var x:XML in child){
				if(x.localName()=="item"){
					dp.addItem({label:x.@name,data:x});
				}
			}
			SelectorFrame.dp = dp;
			
			pushPage(FrameInstance.CHOOSEFRAME);
		}
		public function pushObjection(target:String,answer:String,init:XML,error:XML,currect:XML):void
		{
			
			if(target == "role"){
				init.appendChild(<Control pushPage="ROLEFRAME"/>);
			}else {
				init.appendChild(<Control pushPage="OBJECTFRAME"/>);
			}
			Transport.send(init,true);
			nz.enum.Mode.objectModeEnabled = true;
			ObjectFrame.error = error;
			ObjectFrame.answer = answer;
			ObjectFrame.currect = currect;
		}
		public function test(params:Object):void
		{
		}
		public function pushPage(page:String):*
		{
			
		}
		public function popPage():void
		{
			
		}
		public function replacePage(page:String):void
		{
			
		}
		public function set playButtonEnabled(value:Boolean):void
		{
			
		}
		public function set objectModeEnabled(value:Boolean):void
		{
		}
	}
}