//
//  AppDelegate.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 09/04/2017.
//  Copyright Â© 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

let tr = Tracer()
//let sqlm = SQLite.shared

enum OpenIndex: Int {
	case openMainPackageDirectory, openFile
}

enum ActionIndex: Int {
	case run, build, kill
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, EventObserver {
    @IBOutlet weak var window: NSWindow!
	@IBOutlet weak var openSegmentedControl: NSSegmentedControl!
	@IBOutlet weak var actionSegmentedControl: NSSegmentedControl!
	@IBOutlet weak var pathOfTheFile: NSTextField!
	private var viewController: NSViewController!
	var observers: [NSObjectProtocol] = []

    deinit {
        removeObservers()
    }
    
	func applicationWillFinishLaunching(_ notification: Notification) {
		let txt = "ABCx"
		let c = txt[txt.index(before: txt.endIndex)]
		print(c)
		
		
		Shared.lastOpenedFileDirectory = UserDefaults.standard.string(forKey: "LastOpenedFileDirectory")
		
//        _ = Shared.environment()
//		GoTool.installedPackages()
		
		let rect = window.contentView!.frame
		let mainSplitView = MainSplitView(frame: rect)
		viewController = WindowViewController()
		viewController.view = mainSplitView
		window.contentViewController = viewController
		window.makeKeyAndOrderFront(self)
		
		if let frame = windowFrameRect() {
			window.setFrame(frame, display: true)
		}
	}
	
    func applicationDidFinishLaunching(_ aNotification: Notification) {
		registerObservers()
    }

    func registerObservers() {
        registerEvent(Event.mainPackageDirectoryDidChange) { note in
            let isKnown = Shared.mainPackageDirectory != nil
            self.actionSegmentedControl.setEnabled(isKnown, forSegment: 0)
            self.actionSegmentedControl.setEnabled(isKnown, forSegment: 1)
        }
		
		registerEvent(Event.currentEditor) { note in
			if let editor = note.userInfo?["editor"] as? TextEditor {
				self.pathOfTheFile.stringValue = editor.editor.filePath
			}
		}
		
		registerEvent(Event.openMainPackageDirectoryRequest) { note in
			self.openMainDirectory()
		}
    }
    
	func applicationDidBecomeActive(_ notification: Notification) {
	}
	
    func applicationWillTerminate(_ aNotification: Notification) {
    }

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}

	func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
		return .terminateNow
	}
	
	private func windowFrameRect() -> NSRect? {
		if let screenRect = NSScreen.main?.frame {
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
		} else {
			panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory())
		}
		
		panel.begin { retv in
			if retv.rawValue == NSFileHandlingPanelOKButton {
				if let path = panel.urls.first?.path {
					Shared.mainPackageDirectory = path
				}
			}
		}
	}
	
	///
	/// Open selected file.
	///
	@IBAction func openFile(_ sender: Any? = nil) {
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
			if retv.rawValue == NSFileHandlingPanelOKButton {
				let urls = panel.urls
				if urls.count > 0 {
					let files = urls.map { $0.path }
					
					Shared.lastOpenedFileDirectory = files[0].withoutLastPathComponent()
					Event.filesToOpenRequest.dispatch(["files":files as AnyObject])
				}
			}
		}
	}
	
	@IBAction func newFile(_ sender: Any? = nil) {
		Event.newFileRequest.dispatch()
	}
	
	private func run() {
		guard let dir = Shared.mainPackageDirectory else {
			return
		}
		
		Event.runRequest.dispatch()
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
