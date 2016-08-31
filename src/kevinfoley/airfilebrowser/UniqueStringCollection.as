// =================================================================================================
//
//	AIR File Browser
//	Copyright Kevin Foley. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package kevinfoley.airfilebrowser {
	
	/**
	 * ...
	 * @author Kevin Foley
	 */
	public class UniqueStringCollection {
		
		private var collection:Vector.<String>;
		
		public function UniqueStringCollection() {
			collection = new Vector.<String>();
		}
		
		public function clear():void {
			collection.length = 0;
		}
		
		public function add(string:String):void {
			if (collection.indexOf(string) < 0) {
				collection.push(string);
			}
		}
		
		public function addMultiple(strings:Vector.<String>):void {
			for each (var string:String in strings) {
				if (collection.indexOf(string) < 0) {
					collection.push(string);
				}
			}
		}
		
		public function remove(string:String):void {
			var index:int = collection.indexOf(string);
			if (index >= 0) {
				collection.removeAt(index);
			}
		}
		
		public function contains(string:String):Boolean {
			return (collection.indexOf(string) >= 0);
		}
		
		/**
		 * Get all of the strings contained in this collection
		 * @return	A Vector of strings
		 */
		public function getAll():Vector.<String> {
			var vectorClone:Vector.<String> = new Vector.<String>();
			var len:int = collection.length;
			
			for (var i:int = 0; i < collection.length; i++) {
				vectorClone.push(collection[i]);
			}
			return vectorClone;
		}
		
		/**
		 * Get a deep copy of this UniqueStringCollection
		 * @return	A new UniqueStringCollection with identical values to the instance being cloned
		 */
		public function clone():UniqueStringCollection {
			var contents:Vector.<String> = getAll();
			var copy:UniqueStringCollection = new UniqueStringCollection();
			copy.collection = contents;
			return copy;
		}
		
		public function get size():int {
			return collection.length;
		}
	}

}