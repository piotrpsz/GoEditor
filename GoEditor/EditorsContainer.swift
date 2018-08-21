//
//  EditorsContainer.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 12/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

final class EditorsContainer: NSView, EventObserver {
	var observers: [NSObjectProtocol] = []
	static private (set) var mutex = Mutex(name: "editors_mutex")
	static private (set) var editors: [TextEditor] = []
	private var currentEditor: TextEditor? {
		willSet {
			currentEditor?.isHidden = true
		}
		didSet {
			if let editor = currentEditor {
				Event.currentEditor.dispatch(["editor":currentEditor as Any])
				editor.isHidden = false
				window?.makeFirstResponder(editor)
			}
		}
	}
	
	required init() {
		super.init(frame: CGRect.zero)
		autoresizingMask = [.width, .height]
		autoresizesSubviews = true
		registerObservers()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		removeObservers()
	}
	
	func registerObservers() {
		registerEvent(Event.userDidSelectEditor) { note in
			if let editor = note.userInfo?["editor"] as? TextEditor {
				self.currentEditor = editor
			}
		}
		
		registerEvent(Event.filesToOpenRequest) { note in
            if let files = note.userInfo?["files"] as? [String] {
                for fpath in files {
					EditorsContainer.mutex.sync {
						let editor = TextEditor(fpath: fpath)
						//------------------------------------------
						let parser = Parser(fpath: fpath)
						parser.run()
						for item in parser.tokens {
							print(item.name)
						}
						exit(0)
						//-----------------------------------
						self.addSubview(editor)
						EditorsContainer.editors.append(editor)
					}
                }
            }
			Event.editorsContainerContentDidChange.dispatch()
			self.currentEditor = self.subviews.last as? TextEditor
		}
		
		registerEvent(Event.newFileRequest) { note in
			self.newEditor()
		}
		
		// save the current visible editor
		registerEvent(Event.saveRequest) { _ in
			self.currentEditor?.editor.save()
		}
		
		// save all wditors
		registerEvent(Event.saveAllRequest) { note in
			EditorsContainer.editors.forEach {
				$0.editor.save()
			}
		}
	}
	
	func newEditor() {
		let editor = TextEditor()
		self.addSubview(editor)
		EditorsContainer.mutex.sync {
			EditorsContainer.editors.append(editor)
		}
		Event.editorsContainerContentDidChange.dispatch()
		self.currentEditor = editor
	}		
}
