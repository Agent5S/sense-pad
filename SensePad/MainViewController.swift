//
//  MainViewController.swift
//  SensePad
//
//  Created by Jorge on 4/29/16.
//  Copyright © 2016 Jorge. All rights reserved.
//

import Cocoa

class MainViewController: ViewController {
	var apps: [String] = Array()
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		self.usesParentStackView = true
    }
	
	override func resizeView(toSize size: CGSize) {
		super.resizeView(toSize: size)
		
		let folder = NSSearchPathForDirectoriesInDomains(.ApplicationDirectory, .LocalDomainMask, true)[0]
		
		let contentSize = CGSize(width: size.width - 40, height: size.height - 40)
		let apps = self.getApps(inFolder: folder)
		
		let x = self.getMaxButtons(Int(contentSize.width), size: 75, offset: 16)
		let y = self.getMaxButtons(Int(contentSize.height), size: 75, offset: 16)
		var n = 0
		
		var stop = false
		while !stop /*n < apps.count && n <  x * y*/ {
			var buttons: [NSButton] = Array()
			for _ in 0..<x {
				let image = NSWorkspace.sharedWorkspace().iconForFile("\(folder)/\(apps[n]).app")
				image.size = NSSize(width: 75, height: 75)
				
				let button = IconButton()
				button.image = image
				button.bordered = false
				button.appName = apps[n]
				button.action = #selector(button.openApp)
				
				buttons.append(button)
				
				n += 1
				stop = n >= apps.count || n >= x * y
				if stop {
					break
				}
			}
			let row = NSStackView(views: buttons)
			for view in self.view.subviews {
				if let stackView = view as? NSStackView where view.identifier == "MainStack" {
					stackView.addArrangedSubview(row)
				}
			}
		}
	}
	
	func getMaxButtons(maxLength: Int, size: Int, offset: Int) -> Int {
		var i = 0
		var length = 0
		while length < maxLength {
			i += 1
			length = (i * size) + ((i - 1) * offset)
		}
		
		return i - 1
	}
	
	func getApps(inFolder folder: String) -> [String] {
		var apps: [String] = Array()
		
		do {
			let applications = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(folder)
			
			for file in applications {
				if file.hasSuffix(".app") {
					apps.append((file as NSString).stringByDeletingPathExtension)
				}
			}
		} catch let error as NSError {
			let alert = NSAlert(error: error)
			alert.alertStyle = .InformationalAlertStyle
			alert.addButtonWithTitle("Quit")
			if alert.runModal() == NSAlertFirstButtonReturn {
				NSApplication.sharedApplication().stopModal()
				NSApplication.sharedApplication().terminate(self)
			}
		}
		
		return apps
	}
}
