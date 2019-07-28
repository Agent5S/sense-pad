//
//  ViewController.swift
//  SensePad
//
//  Created by Jorge on 4/28/16.
//  Copyright © 2016 Jorge. All rights reserved.
//

import Cocoa
import CoreGraphics

class ViewController: NSViewController {
	let synthesizer = NSSpeechSynthesizer()
	var initialTouches: Set<NSTouch> = Set()
	var currentTouches: Set<NSTouch> = Set()
	var focus: (Int, Int) = (-1, -1)
	var previousFocus: (Int, Int) = (-1, -1)
	var usesParentStackView: Bool = false
	
	override var representedObject: AnyObject? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	var focusView: NSView? {
		didSet {
			if let view = self.focusView {
				var text: String = String()
				if self.focus != self.previousFocus {
					if self.focus.0 != self.previousFocus.0 {
						text.appendContentsOf("Row \(self.focus.0 + 1),")
					}
					self.previousFocus = self.focus
				}
				text.appendContentsOf("\(view.accessibilityLabel()!)")
				self.synthesizer.stopSpeaking()
				self.synthesizer.startSpeakingString(text)
			}
			self.view.window?.makeFirstResponder(self.focusView)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.acceptsTouchEvents = true
		// Do any additional setup after loading the view.
	}
	
	override func touchesBeganWithEvent(event: NSEvent) {
		self.initialTouches = event.touchesMatchingPhase(.Touching, inView: self.view)
	}
	
	override func touchesMovedWithEvent(event: NSEvent) {
		self.currentTouches = event.touchesMatchingPhase(.Moved, inView: self.view)
		
		if self.currentTouches.count == 2  {
			if let motion = self.getTocuhesMovement() {
				let horizontal = CGFloat.abs(motion.dx) > CGFloat.abs(motion.dy)
				
				if changeFocus(horizontal ? motion.dx : motion.dy, isHorizontal: horizontal) {
					self.initialTouches = self.currentTouches
				}
			}
		}
	}
	
	override func touchesEndedWithEvent(event: NSEvent) {
		var i = 0
		for touch in event.touchesMatchingPhase(.Ended, inView: self.view) {
			self.initialTouches.remove(touch)
			self.currentTouches.remove(touch)
			i += 1
		}
	}
	
	override func rightMouseDown(theEvent: NSEvent) {
		if theEvent.subtype == .NSTouchEventSubtype {
			let focus = self.focusView as? NSButton
			focus?.highlighted = true
		}
	}
	
	override func rightMouseUp(theEvent: NSEvent) {
		if theEvent.subtype == .NSTouchEventSubtype {
			let focus = self.focusView as? NSButton
			focus?.performClick(nil)
			focus?.highlighted = false
		}
	}
	
	func getTocuhesMovement() -> CGVector? {
		let prevTouches: [NSTouch] = Array(self.initialTouches)
		let actualTouches: [NSTouch] = Array(self.currentTouches)
		
		if prevTouches[0].identity.isEqual(actualTouches[0].identity) &&
			prevTouches[1].identity.isEqual(actualTouches[1].identity) {
			var motion = CGVector()
			
			var touch1_motion = CGVector()
			touch1_motion.dx = actualTouches[0].normalizedPosition.x - prevTouches[0].normalizedPosition.x
			touch1_motion.dy = actualTouches[0].normalizedPosition.y - prevTouches[0].normalizedPosition.y
			
			var touch2_motion = CGVector()
			touch2_motion.dx = actualTouches[1].normalizedPosition.x - prevTouches[1].normalizedPosition.x
			touch2_motion.dy = actualTouches[1].normalizedPosition.y - prevTouches[1].normalizedPosition.y
			
			let deviceSize = prevTouches[0].deviceSize
			
			if touch1_motion.dx > 0 && touch2_motion.dx > 0 ||
				touch1_motion.dx < 0 && touch2_motion.dx < 0 {
				motion.dx = (CGFloat.abs(touch1_motion.dx) < CGFloat.abs(touch2_motion.dx) ?
					touch1_motion.dx : touch2_motion.dx) * deviceSize.width
			}
			if touch1_motion.dy > 0 && touch2_motion.dy > 0 ||
				touch1_motion.dy < 0 && touch2_motion.dy < 0 {
				motion.dy = (CGFloat.abs(touch1_motion.dy) < CGFloat.abs(touch2_motion.dy) ?
					touch1_motion.dy : touch2_motion.dy) * deviceSize.height
			}
			
			return motion
		}
		
		return nil
	}
	
	func getView(atPosition position: (Int, Int)) -> NSView? {
		if position.0 >= 0 && position.1 >= 0 {
			var stacks: [NSStackView] = Array()
			var parentView: NSView = self.view
			if usesParentStackView {
				for view in self.view.subviews {
					if view.identifier == "MainStack" {
						parentView = view
					}
				}
			}
			for view in parentView.subviews {
				if let stack = view as? NSStackView {
					stacks.append(stack)
				}
			}
			if stacks.count > position.0 {
				if stacks[position.0].arrangedSubviews.count > position.1 {
					return stacks[position.0].arrangedSubviews[position.1]
				} else if self.previousFocus.0 != position.0{
					let lastIndex = stacks[position.0].arrangedSubviews.count - 1
					self.focus = (position.0, lastIndex)
					return stacks[position.0].arrangedSubviews[lastIndex]
				}
			}
		}
		
		return nil
	}
	
	func changeFocus(motion: CGFloat, isHorizontal: Bool) -> Bool {
		if CGFloat.abs(motion) > 30 {
			let direction = motion > 0 ? 1 : -1
			
			if(self.focus == (-1, -1)) {
				self.focus = (0, 0)
			} else {
				self.focus.0 -= isHorizontal ? 0 : direction
				self.focus.1 += isHorizontal ? direction : 0
			}
			
			if let view = self.getView(atPosition: self.focus) {
				self.focusView = view
				
				NSHapticFeedbackManager.defaultPerformer().performFeedbackPattern(NSHapticFeedbackPattern.Generic, performanceTime: .Default)
			} else {
				self.focus = self.previousFocus
			}
			return true
		}
		return false
	}
	
	func resizeView(toSize size: CGSize) {
		self.view.frame = CGRect(origin: CGPoint.zero, size: size)
	}
}

