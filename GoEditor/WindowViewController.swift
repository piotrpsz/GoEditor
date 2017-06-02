//
//  WindowViewController.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 01/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

final class WindowViewController: NSViewController {
	private var viewDidAppearFirstTime = true
	
	override func viewDidAppear() {
		if viewDidAppearFirstTime {
			Event.applicationStarted.dispatch()
			viewDidAppearFirstTime = false
		}
	}
}
