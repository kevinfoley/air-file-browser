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
	 * Type-safe constants for file sorting modes
	 * @author Kevin Foley
	 */
	public final class SortingMode {
		
		public static const FILE_NAME_ASCENDING:SortingMode = new SortingMode("fileNameAscending", true);
		public static const FILE_NAME_DESCENDING:SortingMode = new SortingMode("fileNameDescending", false);
		public static const EXTENSION_ASCENDING:SortingMode = new SortingMode("extensionAscending", true);
		public static const EXTENSION_DESCENDING:SortingMode = new SortingMode("extensionDescending", false);
		public static const DATE_ASCENDING:SortingMode = new SortingMode("dateAscending", true);
		public static const DATE_DESCENDING:SortingMode = new SortingMode("dateDescending", false);
		
		private static var constructorAvailable:Boolean = true;
		
		private var name:String;
		private var _ascending:Boolean;
		
		public function SortingMode(name:String, ascending:Boolean) {
			if (!constructorAvailable) {
				throw new Error("SortingMode is an enum-type and cannot be instanced directly from your code!");
			}
			this._ascending = ascending;
			this.name = name;
			
			if (name == "dateDescending") {
				constructorAvailable = false;
			}
		}
		
		public function get ascending():Boolean {
			return _ascending;
		}
		
		public function toString():String {
			return name;
		}
		
	}

}