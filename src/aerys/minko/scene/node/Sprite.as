package aerys.minko.scene.node
{
	import aerys.minko.render.Effect;
	import aerys.minko.render.material.sprite.SpriteShader;
	import aerys.minko.render.material.Material;
	import aerys.minko.scene.node.mesh.Mesh;
	import aerys.minko.scene.node.mesh.geometry.Geometry;
	import aerys.minko.scene.node.mesh.geometry.primitive.BillboardsGeometry;
	
	public final class Sprite extends Mesh
	{
		private static const EFFECT	: Effect	= new Effect(new SpriteShader());
		private static const GEOM	: Geometry	= new BillboardsGeometry(1);
		
		public function get x() : Number
		{
			return bindings.getProperty('x') as Number;
		}
		public function set x(value : Number) : void
		{
			properties.setProperty('x', value);
		}
		
		public function get y() : Number
		{
			return bindings.getProperty('y') as Number;
		}
		public function set y(value : Number) : void
		{
			properties.setProperty('y', value);
		}
		
		public function get width() : Number
		{
			return bindings.getProperty('width') as Number;
		}
		public function set width(value : Number) : void
		{
			properties.setProperty('width', value);
		}
		
		public function get height() : Number
		{
			return bindings.getProperty('height') as Number;
		}
		public function set height(value : Number) : void
		{
			properties.setProperty('height', value);
		}
		
		public function get depth() : Number
		{
			return bindings.getProperty('depth') as Number;
		}
		public function set depth(value : Number) : void
		{
			properties.setProperty('depth', value);
		}
		
		public function Sprite(x 			: Number	= 0.,
							   y 			: Number	= 0.,
							   width		: Number	= 128.,
							   height		: Number	= 128.,
							   properties 	: Object 	= null,
							   depth 		: Number 	= 0)
		{
			super(GEOM, new Material(EFFECT, properties));
			
			this.x = x;
			this.y = y;
			this.width 	= width;
			this.height = height;
			this.depth 	= depth;
		}
	}
}