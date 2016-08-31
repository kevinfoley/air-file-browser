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
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Kevin Foley
	 */
	public class FileNavigationEvent extends Event {
		
		public static const DIRECTORY_CHANGED:String = "directoryChanged";
		
		public function FileNavigationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event { 
			return new FileNavigationEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("FileNavigationEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}