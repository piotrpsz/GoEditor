//
//  AppDelegate.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 09/04/2017.
//  Copyright Â© 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

enum OpenIndex: Int {
	case openMainPackageDirectory, openFile
}

enum ActionIndex: Int {
	case run, build, kill
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
	@IBOutlet weak var openSegmentedControl: NSSegmentedControl!
	@IBOutlet weak var actionSegmentedControl: NSSegmentedControl!
	private var viewController: NSViewController!
	

	func applicationWillFinishLaunching(_ notification: Notification) {
		let mainSplitView = MainSplitView(frame: window.contentView!.frame)
		viewController = WindowViewController()
		viewController.view = mainSplitView
		window.contentViewController = viewController
		window.makeKeyAndOrderFront(self)
		
		if let frame = windowFrameRect() {
			window.setFrame(frame, display: true)
		}
	}
	
    func applicationDidFinishLaunching(_ aNotification: Notification) {
//		let data = ProcessInfo.processInfo.environment
//		data.forEach {
//			Swift.print("\($0)")
//		}
		
    }

	func applicationDidBecomeActive(_ notification: Notification) {
	}
	
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}

	func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
		return .terminateNow
	}
	
	private func windowFrameRect() -> NSRect? {
		if let screenRect = NSScreen.main()?.frame {
			var frame = NSZeroRect
			frame.size.width = screenRect.size.width * 0.7
			frame.size.height = screenRect.size.height * 0.8
			frame.origin.x = (screenRect.size.width - frame.size.width) / 2.0
			frame.origin.y = (screenRect.size.height - frame.size.height) / 2.0
			return frame
		}
		return nil
	}
	
	@IBAction func openSegmentedControlDidClick(_ sender: Any) {
		guard let index = OpenIndex(rawValue: openSegmentedControl.selectedSegment) else {
			return
		}
		switch index {
		case .openMainPackageDirectory:
			openMainDirectory()
		case .openFile:
			openFile()
		}
	}

	@IBAction func actionSegmentedControlDidClick(_ sender: Any) {
		guard let index = ActionIndex(rawValue: actionSegmentedControl.selectedSegment) else {
			return
		}
		switch index {
		case .run:
			run()
		case .build:
			build()
		case .kill:
			kill()
		}
		
	}

	private func openMainDirectory() {
		let panel = NSOpenPanel()
		panel.canChooseFiles = false
		panel.canChooseDirectories = true
		panel.allowsMultipleSelection = false
		panel.resolvesAliases = true
		panel.title = "Select main package directory"
		panel.canCreateDirectories = true
		panel.showsHiddenFiles = false
		panel.isExtensionHidden = false
		if let path = Shared.mainPackageDirectory {
			panel.directoryURL = URL(fileURLWithPath: path.withoutLastPathComponent())
		}
		else {
			panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory())
		}
		
		panel.begin { retv in
			if retv == NSFileHandlingPanelOKButton {
				if let path = panel.urls.first?.path {
					Shared.mainPackageDirectory = path
					Event.mainDirectoryDidSelect.dispatch()
				}
			}
		}
	}
	
	private func openFile() {
		let panel = NSOpenPanel()
		panel.canChooseFiles = true
		panel.canChooseDirectories = false
		panel.allowsMultipleSelection = true
		panel.resolvesAliases = true
		panel.title = "Open file(s)"
		panel.canCreateDirectories = true
		panel.showsHiddenFiles = false
		panel.isExtensionHidden = false
		if let path = Shared.lastOpenedFileDirectory {
			panel.directoryURL = URL(fileURLWithPath: path)
		}
		else {
			panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory())
		}
		
		panel.begin { retv in
			if retv == NSFileHandlingPanelOKButton {
				let urls = panel.urls
				if urls.isNotEmpty {
					let files = urls.map { $0.path }
					Shared.lastOpenedFileDirectory = files[0].withoutLastPathComponent().withoutLastPathComponent()
					Event.filesToOpenDidSelect.dispatch(["files":files as AnyObject])
				}
			}
		}
	}
	
	private func run() {
		guard let dir = Shared.mainPackageDirectory else {
			return
		}
		
		let url = URL(fileURLWithPath: dir)
		let fm = FileManager.default
		
		if let content = try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) {
			var array: [String] = []
			for item in content {
				if item.pathExtension == "go" {
					array.append(item.path)
				}
			}
			if let result = GoTool.run(dir: url.path, files: array) {
				Event.runDidFinish.dispatch(["text":result as AnyObject])
			}
		}
	}
	
	private func build() {
	}
	
	private func kill() {
		
	}
	
	//****************************************************************
	//*                                                              *
	//*                  M E N U   A C T I O N S                     *
	//*                                                              *
	//****************************************************************
	
	@IBAction func saveDidSelect(_ sender: AnyObject) {
		Event.saveRequest.dispatch()
	}
}

extension AppDelegate: NSWindowDelegate {
	
}
