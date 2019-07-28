//
//  IconButton.swift
//  SensePad
//
//  Created by Jorge on 5/1/16.
//  Copyright © 2016 Jorge. All rights reserved.
//

import Cocoa

class IconButton: NSButton {
	var appName: String? {
		didSet {
			self.setAccessibilityLabel(self.appName!)
		}
	}
	//var appPath: String = ""

	func openApp() {
		if let app = self.appName {
			NSWorkspace.sharedWorkspace().launchApplication(app)
		}
	}
    
}
