package ui
{
	/**
	 * 控制证物的类.
	 * 
	 * <table class="innertable">
	 * <tr><th>标签</th><td>值</td></tr>
	 * <tr><th>Link:</th><td>无</td></tr>
	 * <tr><th>可创建:</th><td>是</td></tr>
	 * <tr><th>创建类型:</th><td>ObjectItem</td></tr>
	 * <tr><th>可存档:</th><td>是</td></tr>
	 * </table>
	 * @author CodeX
	 */
	public class ObjectPaneCell extends PaneCell
	{
		/**@private */
		public function ObjectPaneCell() 
		{
			type = "ObjectItem";
			_parent = "ObjectPane";
		}
		
	}

}