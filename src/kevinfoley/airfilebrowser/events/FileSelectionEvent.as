// =================================================================================================
//
//	AIR File Browser
//	Copyright Kevin Foley. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package kevinfoley.airfilebrowser.events {
	import flash.filesystem.File;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author Kevin Foley
	 */
	public class FileSelectionEvent extends Event {
		
		public static const SELECTED_FILE:String = "selectedFile";
		
		public var file:File;
		
		public function FileSelectionEvent(type:String, file:File, bubbles:Boolean=false, data:Object=null) {
			super(type, bubbles, data);
			this.file = file;
			
		}
		
	}

}