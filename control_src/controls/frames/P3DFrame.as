﻿package frames
{
	import org.papervision3d.cameras.FreeCamera3D;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.objects.parsers.Collada;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.materials.BitmapFileMaterial;
	import skins.*;
	/**
	 * ...
	 * @author c
	 */
	public class P3DFrame extends InitFrame
	{
		private var viewport:Viewport3D;
		private var renderer:BasicRenderEngine;
		private var scene:Scene3D;
		private var camera:FreeCamera3D;
		
		private var object:Collada;
		public function P3DFrame(_root:*) 
		{
			super(_root);
			initUI();
			
			//3d
			viewport = new Viewport3D(194, 122);
			viewport.x = 31.4;
			viewport.y = 15;
			renderer=new BasicRenderEngine();
			scene=new Scene3D();
			camera=new FreeCamera3D(2,200);
			//camera.y = 1000;
			//camera.moveBackward(2000);
			camera.z = -1000;
			
			main.addChild(viewport);
			object=new Collada("../script/first/car.dae");
			object.addEventListener(FileLoadEvent.LOAD_COMPLETE,onloaded);
		}
		override public function init(xml:XML):void
		{
			
		}
		private function onloaded(evt:FileLoadEvent):void 
		{
			//object.moveLeft(2000);
			//object.moveUp(50);
			scene.addChild(object);
			
			renderer.renderScene(scene, camera, viewport);
		}
		private function initUI():void
		{
			Assets.setStyleToTarget(main.thumbButton, skins.p3d_t_up, skins.p3d_t_up, skins.p3d_t_down);
			Assets.setStyleToTarget(main.upButton, skins.p3d_x_up, skins.p3d_x_up, skins.p3d_x_down);
			Assets.setStyleToTarget(main.downButton, skins.p3d_y_up, skins.p3d_y_up, skins.p3d_y_down);
		}
	}
	
}