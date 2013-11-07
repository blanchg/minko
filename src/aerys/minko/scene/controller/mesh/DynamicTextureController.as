package aerys.minko.scene.controller.mesh
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import aerys.minko.render.Viewport;
	import aerys.minko.render.resource.texture.TextureResource;
	import aerys.minko.scene.controller.EnterFrameController;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.scene.node.Mesh;
	import aerys.minko.scene.node.Scene;
	import aerys.minko.type.binding.DataProvider;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * The DynamicTextureController makes it possible to use Flash DisplayObjects
	 * as dynamic textures.
	 * 
	 * <p>
	 * The DynamicTextureController listen for the Scene.enterFrame signal and
	 * update the specified texture property of the targeted Meshes by rasterizing
	 * the source Flash DisplayObject.
	 * </p>
	 *   
	 * @author Jean-Marc Le Roux
	 * 
	 */
	public final class DynamicTextureController extends EnterFrameController
	{
		private var _data					: DataProvider;
		
		private var _source					: Object;
		private var _framerate				: Number;
		private var _mipMapping				: Boolean;
		private var _propertyName			: String;
		private var _matrix					: Matrix;
		private var _forceBitmapDataClear	: Boolean;
		private var _tmpBitmapData			: BitmapData;
		private var _texture				: TextureResource;
		
		private var _lastDraw	            : Number;
		private var _updateRequired:Boolean = true;
		
		/**
		 * Create a new DynamicTextureController.
		 * 
		 * @param source The source (BitmapData or DisplayObject) to use as a dynamic texture.
		 * @param mipMapping Whether mip-mapping should be enabled or not. Default value is 'true'.
		 * @param framerate The frame rate of the dynamic texture. Default value is '30'.
		 * @param propertyName The name of the bindings property that should be set with the
		 * dynamic texture. Default value if 'diffuseMap'.
		 * @param matrix The Matrix object that shall be used when rasterizing the DisplayObject
		 * into the dynamic texture. Default value is 'null'.
		 * 
		 */
		public function DynamicTextureController(source					: Object,
												 mipMapping				: Boolean	= true,
												 framerate				: Number	= 30.,
												 propertyName			: String	= 'diffuseMap',
												 matrix					: Matrix	= null,
												 forceBitmapDataClear	: Boolean	= false)
		{
			super();

			if (!(source is DisplayObject) && !(source is BitmapData))
				throw new Error("Invalid argument: source must be of type DisplayObject or BitmapData.");
			
			_source = source;
			_texture = new TextureResource();
            _texture.name = "DynamicTextureController";
            _texture.contextLost.add(onContextLost);
			_framerate = framerate;
			_mipMapping = mipMapping;
			_propertyName = propertyName;
			_matrix = matrix;
			_forceBitmapDataClear = forceBitmapDataClear;
			
			_data = new DataProvider();
			_data.setProperty(propertyName, _texture);
		}
        
        private function onContextLost(texture:TextureResource):void
        {
            if (_tmpBitmapData)
                _tmpBitmapData.dispose();
            _tmpBitmapData = null;
            update();
        }
        
		public function get forceBitmapDataClear():Boolean
		{
			return _forceBitmapDataClear;
		}

		public function set forceBitmapDataClear(value:Boolean):void
		{
			_forceBitmapDataClear = value;
		}

		override protected function targetAddedHandler(ctrl		: EnterFrameController,
													   target	: ISceneNode) : void
		{
            trace("DTC Target added: " + target.name);
			super.targetAddedHandler(ctrl, target);
			
			if (target is Scene)
				(target as Scene).bindings.addProvider(_data);
			else if (target is Mesh)
				(target as Mesh).bindings.addProvider(_data);
			else
				throw new Error();
		}
		
		override protected function targetRemovedHandler(ctrl	: EnterFrameController,
														 target	: ISceneNode) : void
		{
            trace("DTC Target removed: " + target.name);
			super.targetRemovedHandler(ctrl, target);
			
			if (target is Scene)
				(target as Scene).bindings.removeProvider(_data);
			else if (target is Mesh)
				(target as Mesh).bindings.removeProvider(_data);
		}
		
		override protected function sceneEnterFrameHandler(scene	: Scene,
														   viewport	: Viewport,
														   target	: BitmapData,
														   time		: Number) : void
		{
			if (_updateRequired || (_framerate > 0 && (!_lastDraw || time - _lastDraw > 1000. / _framerate)))
			{
				_lastDraw = time;
                _updateRequired = false;
				
				if (_source is DisplayObject)
				    updateFromDisplayObject();
				else
					updateFromBitmapData();
			}
		}

		private function updateFromDisplayObject() : void
		{
			var sourceDisplayObject : DisplayObject = _source as DisplayObject;

			refreshTempBitmapData();
            
            trace("DTC update: " + sourceDisplayObject.name);
			_tmpBitmapData.draw(sourceDisplayObject, _matrix);
			_texture.setContentFromBitmapData(_tmpBitmapData, _mipMapping);
		}

		private function updateFromBitmapData() : void
		{
			if (_matrix)
			{
				refreshTempBitmapData();

				_tmpBitmapData.draw(_source as BitmapData, _matrix);
				_texture.setContentFromBitmapData(_tmpBitmapData, _mipMapping);
			}

			_texture.setContentFromBitmapData(_source as BitmapData, _mipMapping);
		}

		private function refreshTempBitmapData() : void
		{
			if (!_tmpBitmapData)
				_tmpBitmapData = new BitmapData(_source.width, _source.height);
			
            if (_forceBitmapDataClear)
				_tmpBitmapData.fillRect(
					new Rectangle(0, 0, _tmpBitmapData.width, _tmpBitmapData.height),
					0
				);
		}
        
        public function update():void
        {
            _updateRequired = true;
        }
        
        public function updateSize():void
        {
            _updateRequired = true;
            if (_tmpBitmapData)
                _tmpBitmapData.dispose();
            _tmpBitmapData = null;
        }
	}
}