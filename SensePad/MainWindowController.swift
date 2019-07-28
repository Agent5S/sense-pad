//
//  MainWindowController.swift
//  SensePad
//
//  Created by Jorge on 4/29/16.
//  Copyright © 2016 Jorge. All rights reserved.
//

import Cocoa

class MainWindowController: WindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
		self.window?.toggleFullScreen(nil)
		(self.window?.contentViewController as? ViewController)?.focusView = nil
    }
}
