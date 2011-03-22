package com
{
	import com.nz.FrameInstance;
	import com.nz.ISaveObject;
	import com.nz.Place;
	import com.nz.Transport;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	/**
	 * 用于辅助构建Map.在侦探模式中使用.
	 * <table class="innertable">
	 * <tr><th>标签</th><td>值</td></tr>
	 * <tr><th>Link:</th><td>Map</td></tr>
	 * <tr><th>可创建:</th><td>否</td></tr>
	 * <tr><th>可存档:</th><td>是</td></tr>
	 * </table>
	 * @author CodeX
	 */
	public class Map extends EventDispatcher implements ISaveObject
	{
		/**@private */
		public const PROCESSOR_BUILDROLES:int = 0;
		/**@private */
		public const PROCESSOR_FIRSTTALK:int = 1;
		/**@private */
		public const PROCESSOR_SHOWCONTROL:int = 2;
		/**@private */
		public const field:String = "global";
		private var _func:FuncMan;
		private var _source:String;
		private var map:XML;
		private var placelist:Object;
		private var currentPlace:String;
		private var processor:int = 0;
		public const version:String = "0.7.5.8";
		/**@private */
		public function Map() 
		{
			placelist = new Object();
			_func = new FuncMan();
			//func.setFunc("source", { type:Script.Properties ,progress:false} );
			func.setFunc("source", { type:Script.Properties } );
			func.setFunc("gotoPlace", { type:Script.SingleParams } );
			func.setFunc("select", { type:Script.ComplexParams , progress:true, down:false } );
			func.setFunc("update", { type:Script.ComplexParams } );
		}
		/**
		 * @param path map.xml所在路径
		 * 方便的加载map.xml--描述map的xml文件.
		 * 其中.最顶层默认为root.一般是事务所.
		 * @example 一个默认的map文件
		 * <listing version="3.0">
		 *	&lt;?xml version="1.0" encoding="utf-8"?&gt;
		 *	&lt;nz&gt;
		 *		&lt;map&gt;
		 *			&lt;place label="事务所" background="bg/事务所.png"&gt;
		 *				&lt;place label="拘留所" background="bg/拘留所.png"/&gt;
		 *				&lt;place label="剧院" enabled="false" background="bg/剧院.png"&gt;
		 *					&lt;place label="走廊" background="bg/走廊.png" /&gt;
		 *				&lt;/place&gt;
		 *			&lt;/place&gt;
		 *		&lt;/map&gt;
		 *	&lt;/nz&gt;
		 * </listing>
		 */
		public function get source():String
		{
			return _source;
		}
		public function set source(path:String):void
		{
			Transport.send("<Script stop=''/>");
			_source = path;
			var u:URLLoader = new URLLoader();
			u.load(new URLRequest(FileManage.getResolvePath(path)));
			u.addEventListener(Event.COMPLETE, buildmap);
		}
		/**@private */
		public function getMoveList():Array
		{
			var p:Place = getPlace(currentPlace);
			var ar:Array = new Array();
			var fp:Place = getFatherPlace(p);
			if (fp != null) {
				ar.push(fp);
			}
			for (var i:int = 0; i < p.oriXML.children().length(); i++) {
				var child:Place = getPlace(p.oriXML.place[i].@label);
				if (child.enable) {
					ar.push(child);
				}
			}
			return ar;
		}
		/**@private */
		public function getPlace(place:String):Place
		{
			return placelist[place] as Place;
		}
		/**
		 * 转到指定的地点
		 * @param	place map.xml中地点的label标签
		 */
		public function gotoPlace(place:String):void
		{
			if (placelist[place] == null) {
				//dispatchEvent(new ErrorEvent());
				return;
			}
			var p:Place = getPlace(place);
			if (!p.enable) p.enable = true;
			Transport.send("<Bg path='"+p.oriXML.@background+"'/>");
			currentPlace = place;
			if (p.content != null) {
				processor = 0;
				Transport.send("<Text visible='false'/>");
				updateAll();
			}
		}
		/**
		 * 用于为指定的地点创建剧本.
		 * 如果select的值是当前地点的话.会触发gotoPlace.强制刷新内容.
		 * 如果select的值不是当前地点的话.只是静默更新地点列表.准备给gotoPlace触发.
		 * @param	content 内容XML
		 * @param	place 地点标签
		 * 其中
		 * <ul>
		 * 	<li><b>roles</b>:表示每次都要执行的脚本,默认是创建角色的脚本</li>
		 * 	<li><b>first</b>:表示第一次要执行的脚本,默认是一些对话</li>
		 * 	<li><b>find</b>:表示点击[调查]按钮执行的脚本,需要[Plugin]PointPic.swf的支持</li>
		 * 	<li><b>talk</b>:表示点击[交谈]按钮执行的脚本,用topic来分开话题</li>
		 * 	<li><b>objection</b>:表示点击[指正]按钮执行的脚本,默认里面包了一个Control.pushObjection而已</li>
		 * </ul>
		 * [移动]按钮执行后.又系统生成地点列表.然后出发Map.gotoPlace指令
		 * @example 
		 * <listing version="3.0">
		 *	&lt;Map select="地点"&gt;
		 * 		&lt;version&gt;1&lt;/version&gt;
		 *		&lt;roles&gt;
		 *			&lt;Main create="Role"&gt;
		 *				&lt;!--role list--&gt;
		 *			&lt;/Main&gt;
		 *			&lt;Script jump="out;out"/&gt;
		 *		&lt;/roles&gt;
		 *		&lt;first&gt;
		 *			&lt;!-- ..place script here.. --&gt;
		 *			&lt;Script jump="out;out"/&gt;
		 *		&lt;/first&gt;
		 *		&lt;find&gt;
		 *			&lt;pp_pl init=""&gt;
		 *				  &lt;content position="30;30;10;10"&gt;
		 *					  &lt;!-- ..place script here.. --&gt;
		 *					  &lt;Script jump="out;out;out;out"/&gt;
		 *				  &lt;/content&gt;
		 *				  &lt;content position="60;60;10;10"&gt;
		 *					  &lt;!-- ..place script here.. --&gt; 
		 *					  &lt;Script jump="out;out;out;out"/&gt;
		 *				  &lt;/content&gt;
		 *			  &lt;/pp_pl&gt;
		 *		&lt;/find&gt;
		 *		&lt;talk&gt;
		 *			&lt;topic label="话题1"&gt;
		 *				&lt;!-- ..place script here.. --&gt;
		 *				&lt;Script jump="out;out;out"/&gt;
		 *			&lt;/topic&gt;
		 *			&lt;topic label="话题2"&gt;
		 *				&lt;!-- ..place script here.. --&gt;
		 *				&lt;Script jump="out;out;out"/&gt;
		 *			&lt;/topic&gt;
		 *		&lt;/talk&gt;
		 *		&lt;objection&gt;
		 *			&lt;Control pushObjection="" &gt;
		 *				 &lt;object link="huizhang_oi" &gt;
		 *					 &lt;Control cleanPushObjection=""/&gt;
		 *					 &lt;!-- ..place script here.. --&gt;
		 *					 &lt;Script jump="out;out;out;out"/&gt;
		 *				 &lt;/object&gt;
		 *			 &lt;/Control&gt;
		 *		&lt;/objection&gt;
		 *	&lt;/Map&gt;
		 * </listing>
		 */
		public function select(content:XML,place:String):void
		{
			regPlace(content, place);
			if (currentPlace == place) {
				updateAll();
			}
		}
		private function regPlace(content:XML, place:String):void
		{
			if (placelist[place] == null) {
				//dispatchEvent(new ErrorEvent());
				return;
			}
			var p:Place = getPlace(place);
			if (p.version < Number(content.version.toString())) {
				p.content = content;
			}else if(p.version > Number(content.version.toString())){
				//Transport.Pro["Script"].go("down");
				Transport.send("<Script go='down'/>");
				return;
			}
		}
		/**
		 * 全域搜索满足地点匹配和版本匹配的Map.select的代码并更新到地点列表中.
		 * 不会引起Script的当前指针的移动.
		 * @param	content place的version的XML
		 * @param	place 要更新的地点
		 * 注意.速度缓慢.能少用则少用
		 * @example 
		 * <listing version="3.0">
		 *	&lt;Map update="地点"&gt;
		 * 		&lt;version&gt;1&lt;/version&gt;
		 * 		&lt;enable&gt;true&lt;/enable&gt;
		 *	&lt;/Map&gt;
		 * </listing>
		 */
		public function update(content:XML,place:String):void
		{
			var xml:XML;
			if (content.enable != undefined) {
				getPlace(place).enable = (content.enable.toString() != "false");
			}else {
				getPlace(place).enable = true;
			}
			if (content.version != undefined) {
				var version:String = content.version.toString();
				var target:XML = Transport.Pro["Script"].searchMap(place, version);
				if (target == null) {
					//dispatchError
				}else {
					regPlace(target, place);
				}
			}
		}
		/**@private */
		public function updateAll():void
		{
			var p:Place = getPlace(currentPlace);
			switch(processor) {
				case PROCESSOR_BUILDROLES:
					processor = PROCESSOR_FIRSTTALK;
					Transport.Pro["Main"].removeType("Role");
					Transport.Pro["Script"].insert(p.content.roles[0]);
					Transport.Pro["Script"].go("in");
					Transport.Pro["Script"].start();
				break;
				case PROCESSOR_FIRSTTALK:
					processor = PROCESSOR_SHOWCONTROL;
					if (p.firsttalk != true) {
						p.firsttalk = true;
						Transport.Pro["Control"].gotoPage(FrameInstance.PLAYFRAME);
						Transport.Pro["Script"].insert(p.content.first[0]);
						Transport.Pro["Script"].go("in");
					}else {
						updateAll();
						return;
					}
				break;
				case PROCESSOR_SHOWCONTROL:
					Transport.Pro["Control"].showPanel(getPlace(currentPlace));
					dispatchEvent(new Event(Script.SCRIPT_PAUSE));
				break;
				default:
					
				break;
			}
		}
		private function buildmap(e:Event):void 
		{
			map = new XML(e.currentTarget.data);
			searchplace(map.map[0]);
			Transport.send("<Script start=''/>");
		}
		private function searchplace(target:XML):void
		{
			for each(var element:XML in target.children()) {
				placelist[element.@label] = new Place(element);
				if (element.hasComplexContent()) {
					searchplace(element);
				}
			}
		}
		private function getFatherPlace(place:Place):Place
		{
			var father:String = place.oriXML.parent().@label;
			return getPlace(father);
		}
		/**@private */
		public function saveData(link:String):void
		{
			SAVEManager.appendData(link, { source:this.source } );
			var p:Place = getPlace("事务所");
			SAVEManager.appendRowData("事务所",p,"Map");
			//SAVEManager.appendData(link, { update:"事务所" }, };
		}
		/**@private */
		public function loadData(link:String):void 
		{
			var obj:Object = SAVEManager.getData("事务所", "Map");
			
			var p:Place = obj as Place;
		};
		/**@private */
		public function get func():FuncMan
		{
			return _func;
		}
	}
}