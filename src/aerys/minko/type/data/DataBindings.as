package aerys.minko.type.data
{
	import aerys.minko.type.Signal;
	
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public final class DataBindings
	{
		private static const NO_KEY	: String		= "__no_key__";
		
		private var _bindings			: Dictionary		= new Dictionary(true);
		private var _values				: Object			= {};
		private var _properties			: Vector.<String>	= new <String>[];
		
		private var _propertyChanged	: Object			= {};
		private var _propertyRemoved	: Object			= {};
		
		public function get numProperties() : uint
		{
			return _properties.length;
		}
		
		public function DataBindings()
		{
		}
		
		public function propertyExists(propertyName : String) : Boolean
		{
			return _values.hasOwnProperty(propertyName);
		}
		
		public function getPropertyChangedSignal(property : String) : Signal
		{
			var signal : Signal = _propertyChanged[property];
			
			if (!signal)
				_propertyChanged[property] = signal = new Signal();
			
			return signal;
		}
		
		public function clone(exclude : Vector.<String>) : DataBindings
		{
			var clone 			: DataBindings 	= new DataBindings();
			var clonedBindings	: Dictionary	= clone._bindings;
			
			for (var source : Object in _bindings)
			{
				var bindingTable 	: Object 	= _bindings[source];
				var clonedTable		: Object	= {};
				var excluded		: Boolean	= true;
				
				for (var key : String in bindingTable)
				{
					if (exclude.indexOf(bindingTable[key]) < 0)
					{
						clonedTable[key] = bindingTable[key];
						excluded = false;
					}
				}
				
				if (!excluded)
					clonedBindings[source] = clonedTable;
			}
			
			for (var propertyName : String in _values)
			{
				if (exclude.indexOf(propertyName) < 0)
				{
					clone._values[propertyName] = _values[propertyName];
					clone._properties.push(propertyName);
				}
			}
			
			return clone;
		}
		
		public function add(dataProvider : IDataProvider) : DataBindings
		{
			var dataDescriptor 	: Object 	= dataProvider.dataDescriptor;
			
			dataProvider.changed.add(dataProviderChangedHandler);
			
			for (var propertyName : String in dataDescriptor)
			{
				var key 		: String		= dataDescriptor[propertyName] as String;
				var property 	: IDataProvider = dataProvider[key] as IDataProvider;
				
				if (property != null)
				{
					addProperty(
						propertyName,
						property,
						null
					);
				}
				
				addProperty(
					propertyName,
					dataProvider,
					key
				);
			}
			
			if (dataProvider is IDynamicDataProvider)
			{
				var dynamicProvider : IDynamicDataProvider = dataProvider
					as IDynamicDataProvider;
				
				dynamicProvider.propertyAdded.add(dynamicPropertyAddedHandler);
				dynamicProvider.propertyRemoved.add(dynamicPropertyRemovedHandler);
			}
						
			return this;
		}
		
		public function remove(dataProvider : IDataProvider) : DataBindings
		{
			var dataDescriptor 	: Object 	= dataProvider.dataDescriptor;
			
			for (var parameterName : String in dataDescriptor)
				removeProperty(parameterName);
			
			return this;
		}
		
		public function setProperty(propertyName : String, value : Object) : DataBindings
		{
			var oldValue : Object = _values[propertyName];
			
			if (_properties.indexOf(propertyName) < 0)
				_properties.push(propertyName);
			
			_values[propertyName] = value;
			
			getPropertyChangedSignal(propertyName).execute(
				this, propertyName, oldValue, value
			);
			
			return this;
		}
		
		public function setProperties(properties : Object) : DataBindings
		{
			for (var propertyName : String in properties)
				setProperty(propertyName, properties[propertyName]);
			
			return this;
		}
		
		public function getProperty(propertyName : String) : Object
		{
			return _values[propertyName];
		}
		
		public function getPropertyName(index : uint) : String
		{
			return _properties[index];
		}
		
		public function addProperty(propertyName 	: String,
									source			: IDataProvider,
									key				: Object	= null) : DataBindings
		{
			var bindingTable : Object = _bindings[source] as Object;
			
			if (!bindingTable)
			{
				_bindings[source] = bindingTable = {};
				source.changed.add(propertyChangedHandler);
			}
			
			if (key === null)
				key = NO_KEY;
			
			bindingTable[key] = propertyName;
			
			setProperty(propertyName, key !== NO_KEY ? source[key] : source);
			
			return this;
		}
		
		public function removeProperty(propertyName : String) : DataBindings
		{
			var numSources	: int	= 0;
			
			for (var source : Object in _bindings)
			{
				var bindingTable 	: Object 	= _bindings[source];
				var numKeys		 	: int		= 0;
				var numDeletedKeys	: int		= 0;
				
				for (var key : String in bindingTable)
				{
					++numKeys;
					
					if (bindingTable[key] == propertyName)
					{
						++numDeletedKeys;
						delete bindingTable[key];
					}
				}
				
				if (numKeys == numDeletedKeys)
				{
					var dataProvider : IDataProvider = source as IDataProvider;
					
					dataProvider.changed.remove(
						propertyChangedHandler
					);
					
					if (dataProvider is IDynamicDataProvider)
					{
						var dynamicProvider : IDynamicDataProvider = dataProvider
							as IDynamicDataProvider;
						
						dynamicProvider.propertyAdded.remove(
							dynamicPropertyAddedHandler
						);
						dynamicProvider.propertyRemoved.remove(
							dynamicPropertyRemovedHandler
						);
					}
					
					delete _bindings[source];
				}
			}
			
			var numProperties	: int	= _properties.length - 1;
			
			_properties[_properties.indexOf(propertyName)] = _properties[numProperties];
			_properties.length = numProperties;
			
			var oldValue : Object = _values[propertyName];
			
			delete _values[propertyName];
			
			getPropertyChangedSignal(propertyName).execute(
				this, propertyName, oldValue, null
			);
			
			return this;
		}
		
		public function clear() : DataBindings
		{
			for (var source : Object in _bindings)
			{
				var bindingTable 	: Object 	= _bindings[source];
				
				for (var key : String in bindingTable)
					removeProperty(bindingTable[key]);
			}
			
			return this;
		}
		
		private function dataProviderChangedHandler(source : IDataProvider, key : Object) : void
		{
			var bindingTable 	: Object = _bindings[source] as Object;
			var propertyName 	: String = null;
			
			if (key == 'dataDescriptor')
			{
				// the dataDescriptor have changed!
				// we have to map new properties, and unbind the old ones.
				
				
			}
			else if (key && source.dataDescriptor[key] != undefined)
			{
				// a single property has changed
				propertyName = bindingTable[key] as String;
				
				if (!propertyName)
					addProperty(source.dataDescriptor[key], source, key);
				else
					setProperty(propertyName, key !== NO_KEY ? source[key] : source);
			}
			else
			{
				// "some" properties have changed (ie. DataProvider.invalidate() was called)
				for (var key : Object in source.dataDescriptor)
				{
					propertyName = bindingTable[key];
					
					if (!propertyName)
						addProperty(source.dataDescriptor[key], source, key);
					else
						setProperty(propertyName, key !== NO_KEY ? source[key] : source);	
				}
			}
		}
		
		private function propertyChangedHandler(source : IDataProvider, key : Object) : void
		{
			key ||= NO_KEY;
			
			var bindingTable 	: Object = _bindings[source] as Object;
			var propertyName 	: String = bindingTable[key] as String;
			
			if (propertyName)
				setProperty(propertyName, key !== NO_KEY ? source[key] : source);
		}
		
		private function dynamicPropertyAddedHandler(source 	: IDynamicDataProvider,
													 property	: String) : void
		{
			addProperty(property, source, source.dataDescriptor[property]);
		}
		
		private function dynamicPropertyRemovedHandler(source 	: IDynamicDataProvider,
													   property	: String) : void
		{
			removeProperty(property);
		}
	}
}