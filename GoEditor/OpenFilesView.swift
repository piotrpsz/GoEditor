//
//  OpenFilesView.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 09/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

class OpenFilesView: NSView, TableViewDelegate, EventObserver {
	private let backgroundColor = NSColor(calibratedWhite: 0.2, alpha: 1.0)
	private let scrollView: NSScrollView = {
		let sv = NSScrollView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
		sv.hasHorizontalScroller = true
		sv.hasVerticalScroller = true
		sv.autoresizingMask = [.width, .height]
		sv.autoresizesSubviews = true
		sv.drawsBackground = false
		sv.focusRingType = .none
		return sv
	}()
	private let tableView = OpenFilesTableView(frame: CGRect.zero)
	var observers: [NSObjectProtocol] = []
	
	override var isFlipped: Bool {
		return true
	}
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		tr.In(self); defer { tr.Out(self) }
		
		autoresizingMask = [.width, .height]
		autoresizesSubviews = true
		tableView.tableViewDelegate = self
		scrollView.documentView = tableView
		addSubview(scrollView)
		registerObservers()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		tr.In(self)
		defer { tr.Out(self) }
		
		removeObservers()
	}
	
	func registerObservers() {
		registerEvent(Event.editorsContainerContentDidChange) { note in
//			tr.In(self)
//			defer { tr.Out(self) }
//			tr.Info(self, info: "event: \(Event.editorsContainerContentDidChange)")
			
			self.tableView.reloadData()
		}
		
		registerEvent(Event.editorStateDidChange) { note in
//			tr.In(self)
//			defer { tr.Out(self) }
//			tr.Info(self, info: "event: \(Event.editorStateDidChange)")
			
			self.tableView.reloadData()
		}
		
		registerEvent(Event.currentEditor) { note in
//			tr.In(self)
//			defer { tr.Out(self) }
//			tr.Info(self, info: "event: \(Event.currentEditor)")
			
			if let editor = note.userInfo?["editor"] as? TextEditor {
				var index: Int?
				EditorsContainer.mutex.sync {
					index = EditorsContainer.editors.index { $0 === editor }
				}
				self.tableView.selectRow(at: index)
			}
		}
	}
	
	func menuAt(rowIndex: Int?) -> NSMenu? {
		if let rowIndex = rowIndex {
			if let editor = EditorsContainer.editors[rowIndex].editor {
				let menu = NSMenu()
				if editor.isChanged {
					menu.addItem(withTitle: "Save", action: #selector(saveDidSelectInContextMenu(_:)), keyEquivalent: "")
				}
				menu.addItem(withTitle: "Close", action: #selector(closeDidSelectInContextMenu(_:)), keyEquivalent: "")
				menu.addItem(withTitle: "Rename", action: #selector(renameDidSelectInContextMenu(_:)), keyEquivalent: "")
				menu.addItem(withTitle: "Delete", action: #selector(deleteDidSelectInContextMenu(_:)), keyEquivalent: "")
				return menu
			}
		}
		return nil
	}
	
	@objc func saveDidSelectInContextMenu(_ sender: Any?) {
		
	}
	
	@objc func closeDidSelectInContextMenu(_ sender: Any?) {
		
	}
	
	@objc func renameDidSelectInContextMenu(_ sender: Any?) {

	}

	@objc func deleteDidSelectInContextMenu(_ sender: Any?) {

	}

}

