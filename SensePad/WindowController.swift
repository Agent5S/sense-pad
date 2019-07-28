//
//  WindowController.swift
//  SensePad
//
//  Created by Jorge on 4/28/16.
//  Copyright © 2016 Jorge. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController, NSWindowDelegate {

	override func windowDidLoad() {
		// Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        super.windowDidLoad()
		self.window?.delegate = self
		
		
		let viewController = self.window?.contentViewController as? ViewController
		viewController?.focusView = nil
	}
	
	func windowDidResize(notification: NSNotification) {
		let viewController = self.window?.contentViewController as? ViewController
		viewController?.resizeView(toSize: self.window!.frame.size)
	}

}
