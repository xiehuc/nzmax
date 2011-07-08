package
{
	/**
	 * 更新历史
	 */
	public class ChangeLog {
		/**
		 * Build:11.02.19.
		 * 将Background并入Layout.Background.load改为Background.path
		 * 更新帮助,添加版本.
		 */
		public const version_0819:String = "0.8.1.9";
		/**
		 * Build:11.02.12.
		 * 更新文字引擎。采用Flex4.的新文字排版引擎。
		 */
		public const version_0754:String = "0.7.5.4";
		/**
		 * Build:11.01.22.
		 * 增加外部链接功能.能在其他网站发贴是粘贴入nzmaxi.
		 * 更新样式和资源文件。
		 */
		public const version_0721:String = "0.7.2.1";
		/**
		 * Build:10.11.20.
		 * 1.增加了预读取的功能。
		 * 一开始游戏的时候只需要读取一小部分的文件。然后一边游戏一边继续读取文件。
		 * 如果游戏进行很快。还没有来得及下载完成。就自动弹出进度框。并暂停游戏。
		 *2.增加游戏选择列表。
		 * 主页里显示一个列表。单击不同的列表就能执行对应的剧本
		 */
		public const version_0710:String = "0.7.1.0";
		/**
		 * Build:10.06.05.
		 * 修正一个小bug.
		 *	确立新建一个新的项目:nzmaxi.
		 *	nzmaxi是独立于nzmax的在线版本.
		 *	强行从nzmax中剥离air的本地类.使得nzmax能网络化.
		 *	编译了一个pre-alpha.没有任何修正的版本.
		 *	证实了这种方案的可行性
		 */
		public const version_0689:String = "0.6.8.9";
		/**
		 * Build:10.03.06.
		 * 1.让法庭人物缩略图可以使用.
		 *	2.增加pushObjection功能.
		 *	3.几个bug修正外带剧本修正.
		 */
		public const version_0678:String = "0.6.7.8";
		/**
		 * Build:10.02.17.
		 * 1.Effect更新:Effect可以储存.
		* Effect可以创建(利用新类EffectTarget.).以便重复利用.
		* Effect.applyFilters,Effect.applyMotion的对象属性现在扩展到所有.以前只能使用visual,现在可以使用所有link
		* (基于DisplayObject的扩展)
		* 内建show_ef,hide_ef来帮助快速应用于对象
		*2.Music更新:新加pause,resume来暂停/回复播放.
		*3.courtSet更新:裁判长法庭表情分离.的确.这个应该是更早做的事情.
		* court模式下新增c(Role,court).name=法庭,path=法庭.swf.
		* 不用指定.用c来访问以前一些裁判长的表情.(如hammer).
		* 另外.这也就意味着附带的两个剧本就不能用了.等以后大更新的时候再修正.
		*4.Script更新:Script.label功能分离.把自动辅助部分用Script.environment代替用法不变.&lt;Script environment= "询问"/&gt;
		* search搜索的内容还是label.
		*5.Role更新:新加group机制.用于控制Role的自动辅助(显示/隐藏);
		*6.Script更新:完善了游戏结束的机制.用&lt;Script finish=""/&gt;来结束游戏.之后.游戏会自动归档到 已完成 类.算是上次的坑的补完.
		*7.章节选择器更新:新添加章节选择机制.如果要使用这个的话.首先.Info.xml里面要这样写
		* &lt;script label="demo剧本"&gt;demo.xml&lt;/script&gt;
		* &lt;script label="测试剧本" hide="false"&gt;test.xml&lt;/script&gt;
		* hide属性可以不加.加了就不会显示了.
		* 然后比如说demo.xml要结束了.用一个&lt;Script showChapter="1"/&gt;来显示测试剧本.
		*8.多脚本更新:这项更新可以把剧本分成几个xml文件.
		* 比如还是&lt;script label="demo剧本"&gt;demo.xml&lt;/script&gt;.那么demo.xml就是 demo剧本 的第一个文件了.
		* 如果demo.xml现在结束了.在最后加上一句&lt;Script load="demo2.xml"/&gt; 这样就抛弃demo.xml.开始了 demo剧本的 第二个文件.
		* 所有对象,属性继承.并没有更改或删除在demo.xml中创建的对象.在demo2.xml中继续使用.
		*9.courtSet更新:&lt;Main courtSet="null"/&gt;来取消courtSet的设置.
		*10.task更新:提供多Script机制.于是在此基础上用&lt;Main task="震惊四座"/&gt;来调用.这个效果.
		*11.Script更新:把Main.open,hide(原Main.checkPermit)设置为Script.openNode,hideNode.用法不变
		*12.Bug修复:存档机制的一些Bug,其他的一些小Bug.
		*13.添加help.rar.以前的help就废掉了.
		 */
		public const version_0667:String = "0.6.6.7";
		/**
		 * Build:10.01.22.
		 * 这次花了很长的时间来做更新.这次的改动比较大.
		 *首先.是整体从Flash转移到了Flex下.一方面是为以后Web的方式(也许有)做准备.一方面是出于自己的好奇.
		 *没有选择最新的Flex4.是因为转移到Flash Builder下失败了.所以继续Flash Develop了.然后嘛.调试的时候就痛苦了.
		 *这次基本上都是重新整理了一遍代码.工作量还是比较大的.
        
		 *Flex带来的好处还有UI界面的提升.以前在AS下创建窗体之类的是很麻烦的.一下子自己也晕了.
		 *Flex这方面就好得多了.所以这次顺便添加了错误提示.以后就不用在xml剧本上摸黑写下去了.
		 *而且这个开始画面也重新设计了.自己设计的感觉还行吧.
		 *剧本选择菜单也增强了.logo.和详细说明都是很实用的.
		 *当然.还没有完成.留了几个坑等下次再补吧.

		 *然后的话.还顺便整理的Control的代码.以前看来是非常混乱的.现在结构调理要清晰得多了.
		 *这次用了很多的Interface.算是解决了我以前的一个死结.

		 *新特性方面增加了 插件模式.这个功能使得扩展性大大增强了.顺便把以前的几个功能转移成了插件:
		 *物品详细类型:photo,report->内部插件.
		 *选择界面(chooseSet)->内部插件.
		 *点击图片的那个(pointPic)->外部插件.

		 *Flex的坏处嘛.就是以前许多东西都不适用了.比如说角色SWF.就不得不更改效果实现方式.
		 *而且文件体积也倍增了.很是不爽.

		 *这次还添加了两个完整的剧本.删掉了以前错误的测试剧本.

		 *然后就是Bug的修复.花了很长的时间来做.现在看来效果是出色的.两个剧本执行起来都很不错.
		 *这个才是比较重要的.

		 *觉得从这个版本开始语言不会有大幅度更改了.已经可以写个剧本自己玩玩.Bug也比较少了.
		 *当然.以后的几个更新还是会改变一点语言的.
		 */
		public const version_0656:String = "0.6.5.6";
		/**
		 * Build:09.12.19.
		 * 继续更新剧本语言。主要是用新的create的方式改写了存档格式。感觉非常的好用。测试效果出众。
		 *	然后Effect小更新一下。改变了一些以前的applyEffect为applyFilters。
		 *	然后添加了一个applyTweens。非常的强大的。
		 */
		public const version_0555:String = "0.5.5.5";
		/**
		 * Build:09.12.05.
		 * 更改了剧本语言(xml).最大的更新是创建的都统一成了Main.create.
		 * 添加了一种新的类layout(其实叫Image更合适）用来加载一些图片.
		 */
		public const version_0544:String = "0.5.4.4";
		/**
		 * Build:09.11.10.
		 * 添加config.exe(在config/config.exe)用于更改设置（config.xml).
		 * 并且把以前集成在nzmax.exe里面的剧本管理的功能移到了config.exe
		 */
		public const version_0533:String = "0.5.3.3";
		/**
		 *  Build:09.10.23.
		 *	支持键盘操作基本上和模拟器上的键位是一样的：而且你还可以更改。在config.xml里
		 *	确定：z；取消：x；L：A；R：B
		 *	菜单：Enter；选择：Backspace；上下左右：上下左右建。
		 *	选择键用来异议的。菜单键呼出存档界面
		 */
		public const version_0521:String = "0.5.2.1";
	}
}
