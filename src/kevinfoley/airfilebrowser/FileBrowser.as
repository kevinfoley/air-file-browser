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
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import kevinfoley.airfilebrowser.events.FileNavigationEvent;
	
	/**
	 * Dispatched when the current directory changes.
	 */
	[Event(name = "directoryChanged", type = "kevinfoley.filebrowser.events.FileNavigationEvent")]
	
	/**
	 * The FileBrowser class wraps a File to provide logic for navigating through folders in the file system, and
	 * viewing a listing of the current directory. A history is maintained for backward/forward navigation, and support
	 * is provided for the "up" operation (move to parent directory). Filters can be used to whitelist the file 
	 * extensions that will be returned when getting a directory listing.
	 * 
	 * @author Kevin Foley
	 */
	public class FileBrowser extends EventDispatcher {
		
		/** If this collection contains any file extensions, only files with those extensions are included in the
		 * directory listing/search results */
		protected var _whitelistedExtensions:UniqueStringCollection;
		/** TODO **/
		protected var _blacklistedExtensions:UniqueStringCollection;
		
		protected var _sortingMode:SortingMode;
		
		protected var _history:Vector.<File>;
		protected var _historyIndex:int;
		
		/** The current directory */
		protected var _currentDirectory:File;
		
		protected var fnEvt:FileNavigationEvent;
		
		/**
		 * Create a new instance of FileBrowser, pointed at the given directory path
		 * @param	startingPath	The path to a valid folder in the file system. If null, the desktop directory is used.
		 */
		public function FileBrowser(startingPath:String = null) {
			_history = new Vector.<File>();
			_historyIndex = -1;
			
			var path:File;
			
			//if starting directory provided, try to load it
			if (startingPath) {
				path = new File(startingPath);
				if (!path.exists || !path.isDirectory) {
					trace("Warning: " + startingPath + " is not a valid directory path! Using default directory.");
					path = null;
				}
			}
			//if we don't have a valid path yet, use the documents directory
			if (!path) {
				path = File.documentsDirectory;
			}
			currentDirectory = path;
			
			_sortingMode = SortingMode.FILE_NAME_ASCENDING;
			_whitelistedExtensions = new UniqueStringCollection();
			_blacklistedExtensions = new UniqueStringCollection();
		}

		/**
		 * Get a list of all folders and files in the current directory. If any filters have been set, only files with
		 * extensions in the filter list will be included in the results.
		 * @return	A Vector of File objects
		 */
		[Bindable(event = "directoryChanged")] 		
		public function getDirectoryListing():Vector.<File> {
			return search(null);
		}
		
		/**
		 * Search for the given pattern with the given parameters and return the resulting fileset
		 * 
		 * @param	pattern		A string, RegExp, or other searchable pattern
		 * 
		 * @param	recursive	If true, search through subdirectories as well. <b>Warning: Very CPU and memory 
		 * 						intensive when run from high-level directories.</b>
		 * @param	exactMatch	If true and the search pattern is a string, the search pattern must exactly match 
		 * 						the file name (with or without extension.) Searching "test" or "test.jpg" will 
		 * 						match a file named "test.jpg" but not a filed named "test1.jpg" or "mytest.jpg". 
		 * 						Case sensitivity is determined by the <i>matchCase</i> * argument.
		 * @param	matchCase	If true and the search pattern is a string, the search is case-sensitive.
		 * @return				A sorted list of files
		 * 
		 * @see #sortFiles()
		 */
		public function search(pattern:*, recursive:Boolean = false, exactMatch:Boolean = false,
			matchCase:Boolean = false):Vector.<File> 
		{
			var result:Vector.<File> = _search(_currentDirectory, pattern, recursive, exactMatch, matchCase);
			
			result.sort(sortFiles);
			
			return result;
		}
		
		/**
		 * Move back to the previous directory in the history, and return the new directory listing. If no previous
		 * directory exists, we remain in the current directory.
		 * @return	A filtered listing of the new directory
		 */
		public function back():Vector.<File> {
			if (!isBackAvailable) {
				return getDirectoryListing();
			}
			_currentDirectory = _history[--_historyIndex];
			dispatchEvent(new Event(FileNavigationEvent.DIRECTORY_CHANGED));
			return getDirectoryListing();
		}
		
		/**
		 * Move forward to the next directory in the history, and return the new directory listing. If no next directory 
		 * exists, we remain in the current directory.
		 * @return	A filtered listing of the new directory
		 */
		public function forward():Vector.<File> {
			if (!isForwardAvailable) {
				return getDirectoryListing();
			}
			_currentDirectory = _history[++_historyIndex];
			dispatchEvent(new Event(FileNavigationEvent.DIRECTORY_CHANGED));
			return getDirectoryListing();
		}
		
		/**
		 * Move up one directory and return the new directory listing. If no parent directory exists, we remain in the
		 * current directory.
		 * @return	A filtered listing of the new directory
		 */
		public function up():Vector.<File> {
			if (_currentDirectory.parent) {
				currentDirectory = _currentDirectory.parent;
			}
			
			return getDirectoryListing();
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//////////////////////                   FILE EXTENSION WHITELIST                   ////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Clear the file extension whitelist
		 */
		public function clearExtensionWhitelist():void {
			_whitelistedExtensions.clear();
		}
		
		/**
		 * Add the given file extension to the whitelist
		 * @param	extension	A file extension <i>without period</i>, such as "txt"
		 */
		public function addExtensionToWhitelist(extension:String):void {
			_whitelistedExtensions.add(extension.toLowerCase());
		}
		
		/**
		 * Add the given list of file extensions to the whitelist
		 * @param	value	A Vector of file extensions as strings ("exe", "txt", etc)
		 */
		public function addExtensionsToWhitelist(value:Vector.<String>):void {
			var len:int = value.length;
			for (var i:int = 0; i < len; i++) {
				value[i] = value[i].toLowerCase();
			}
			_whitelistedExtensions.addMultiple(value);
		}
		
		/**
		 * A whitelist of file extensions that will be returned with the directory listing. For example, if the 
		 * whitelist contains "txt" and "exe", only files with those extensions will be included (folders are always 
		 * included)
		 */
		public function get whitelistedExtensions():Vector.<String> {
			return _whitelistedExtensions.getAll();
		}
		public function set whitelistedExtensions(value:Vector.<String>):void {
			clearExtensionWhitelist();
			addExtensionsToWhitelist(value);
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//////////////////////                          PROPERTIES                          ////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * The current directory that the FileBrowser is pointed at
		 */
		public function get currentDirectory():File {
			return _currentDirectory.clone();
		}
		[Bindable(event = "directoryChanged")]
		public function set currentDirectory(value:File):void {
			if (!value.isDirectory) {
				throw new IllegalOperationError("Error: " + value.nativePath + " does not point to a folder!");
			}
			
			if (_historyIndex < _history.length - 1) {
				_history.splice(_historyIndex + 1, int.MAX_VALUE);
			}
			
			if (_historyIndex == _history.length - 1) {
				_historyIndex++;
			}
			
			_currentDirectory = value;
			_history.push(_currentDirectory);
			
			//fnEvt = new FileNavigationEvent(FileNavigationEvent.DIRECTORY_CHANGED);
			//dispatchEvent(fnEvt);
			dispatchEvent(new Event(FileNavigationEvent.DIRECTORY_CHANGED));
		}
		
		[Bindable(event = "directoryChanged")] 
		public function get isBackAvailable():Boolean {
			return (_historyIndex > 0);
		}
		
		[Bindable(event = "directoryChanged")] 
		public function get isForwardAvailable():Boolean {
			return (_historyIndex < _history.length - 1);
		}
		
		[Bindable(event = "directoryChanged")] 
		public function get isUpAvailable():Boolean {
			return (_currentDirectory.parent != null);
		}
		
		/**
		 * The SortingMode used for sorting directory listings and searches
		 */
		public function get sortingMode():SortingMode {
			return _sortingMode;
		}
		public function set sortingMode(value:SortingMode):void {
			if (!value) {
				throw new ArgumentError("Error: sortingMode must not be null!");
			}
			_sortingMode = value;
			dispatchEvent(new Event(FileNavigationEvent.DIRECTORY_CHANGED));
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//////////////////////                           HELPERS                            ////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Returns true if the given File is a directory, or has a whitelisted extension, or if the extension whitelist
		 * is empty
		 * @param	file
		 * @return
		 */
		private function inExtensionWhitelist(file:File):Boolean {
			if (file.isDirectory || _whitelistedExtensions.size == 0) {
				return true;
			}
			if (file.extension && _whitelistedExtensions.contains(file.extension.toLowerCase())) {
				return true;
			}
			return false;
		}
		
		/**
		 * Check if the given File has a blacklisted extension
		 * @param	file
		 * @return	True if the File has a blacklisted extension, false if it is a folder or does not have a blacklisted
		 * 			extension
		 */
		private function inExtensionBlacklist(file:File):Boolean {
			if (file.isDirectory) {
				return false;
			}
			if (file.extension && _blacklistedExtensions.contains(file.extension.toLowerCase())) {
				return true;
			} else {
				return false;
			}
		}
		
		/**
		 * @see #search()
		 */
		private function _search(folder:File, pattern:*, recursive:Boolean = false, exactMatch:Boolean = false, 
			matchCase:Boolean = false):Vector.<File> 
		{
			var result:Vector.<File> = new Vector.<File>();
			var array:Array = folder.getDirectoryListing();
			
			if (pattern is String) {
				if (pattern.length == 0) {
					pattern = null;
				} else if (!matchCase) {
					pattern = pattern.toLowerCase();
				}
			}
			
			//iterate through each file in the current directory and add it to the result if it fits the search params
			for each (var file:File in array) {
				if (inExtensionBlacklist(file)) {
					continue;
				}
				if (!inExtensionWhitelist(file)) {
					continue;
				}
				
				//if recursive search is active and this File is a subdirectory, look through files in the subdirectory
				if (recursive && file.isDirectory) {
					var files:Vector.<File> = _search(file, pattern, recursive, exactMatch, matchCase);
					for each (var recursiveFile:File in files) {
						result.push(recursiveFile);
					}
				}
				
				if (pattern) { //if we provided a search string
					var name:String = file.name;
					var extension:String = file.extension;
					if (!extension) extension = "";
					if (!matchCase) {
						name = name.toLowerCase();
						extension = extension.toLowerCase();
					}
					var fullName:String = name + "." + extension;
					
					if (exactMatch && pattern is String && name == pattern) {
						result.push(file);
					} else if (!exactMatch && name.search(pattern) >= 0) {
						result.push(file);
					} else if (exactMatch && pattern is String && fullName == pattern) {
						result.push(file);
					} else if (!exactMatch && fullName.search(pattern) >= 0) {
						result.push(file);
					}
					
				} else { //no search string
					result.push(file);
				}
			}
			
			return result;
		}
		
		/**
		 * Used to alphabetically sort a Vector of Files
		 * @param	a
		 * @param	b
		 * @return
		 * 
		 * @see #set sortingMode()
		 */
		private function sortFiles(a:File, b:File):Number {
			var aScore:Number;
			var bScore:Number;
			var separateDirectories:Boolean = true;;
			
			if (_sortingMode == SortingMode.EXTENSION_ASCENDING || _sortingMode == SortingMode.EXTENSION_DESCENDING) {
				
				if (a.extension) {
					aScore = a.extension.toLowerCase().charCodeAt(0);
				} else {
					aScore = a.name.toLowerCase().charCodeAt(0);
				}
				
				if (b.extension) {
					bScore = b.extension.toLowerCase().charCodeAt(0);
				} else {
					bScore = b.name.toLowerCase().charCodeAt(0);
				}
				
			} else if (_sortingMode == SortingMode.DATE_ASCENDING || _sortingMode == SortingMode.DATE_DESCENDING) {
				aScore = a.modificationDate.time;
				bScore = b.modificationDate.time;
				separateDirectories = false;
			} else { //sorted by file name
				aScore = a.name.toLowerCase().charCodeAt(0);
				bScore = b.name.toLowerCase().charCodeAt(0);
			}
			
			if (separateDirectories) {
				//sort directories first in ascending or last in descending
				if (b.isDirectory) bScore -= 1000; 
				if (a.isDirectory) aScore -= 1000;
			}
			
			if (_sortingMode.ascending) {
				return aScore - bScore;
			} else {
				return bScore - aScore;
			}
		}
	}

}