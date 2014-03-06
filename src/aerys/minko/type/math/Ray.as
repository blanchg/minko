package aerys.minko.type.math
{
	public final class Ray
	{
		private var _origin		: Vector4	= null;
		private var _direction	: Vector4	= null;
		public var _inverseDirection	: Vector4	= null;
        public var _negativeX      :Boolean    = false;
        public var _negativeY      :Boolean    = false;
        public var _negativeZ      :Boolean    = false;
		
		public function get origin() : Vector4
		{
			return _origin;
		}
		
		public function get direction() : Vector4
		{
			return _direction;
		}
		
		public function Ray(origin		    : Vector4	= null,
							direction	    : Vector4 	= null,
                            inverseDirection: Vector4 = null)
		{
			_origin = origin || new Vector4();
			_direction = direction || new Vector4();
            _inverseDirection = inverseDirection || new Vector4(1.0 / _direction.x, 1.0 / _direction.y, 1.0 / _direction.z, 1.0);
            _negativeX = _inverseDirection.x < 0;
            _negativeY = _inverseDirection.y < 0;
            _negativeZ = _inverseDirection.z < 0;
		}
        
        public function toString() : String
        {
            return '[Ray=(' + _origin.toString() + ' -> ' + _direction.toString() + ')]';
        }
	}
}