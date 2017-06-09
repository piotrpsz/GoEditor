//
//  ConsoleView.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 29/05/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

class ConsoleView: NSTextView, EventObserver {
    override var backgroundColor: NSColor {
        get {
            return NSColor(calibratedWhite: 0.2, alpha: 1.0)
        }
        set {
            
        }
    }
    var observers: [NSObjectProtocol] = []
    
    override init(frame frameRect: NSRect) {
        let textContainer = NSTextContainer(containerSize: frameRect.size)
        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = true
        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)

        super.init(frame: frameRect, textContainer: textContainer)
        
        autoresizingMask = [.width, .height]
        autoresizesSubviews = true
        insertionPointColor = NSColor.white
        isEditable = false
        isSelectable = true
        isRichText = true
        textContainerInset = CGSize(width: 2.0, height: 10.0)

        registerObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObservers()
    }
    
    func registerObservers() {
        registerEvent(Event.runDidFinish) { note in
            if let text = note.userInfo?["text"] as? String {
                self.textStorage?.append(NSAttributedString(string: text))
                self.updateGeometry()
                self.textColor = NSColor.white
                self.font = NSFont.systemFont(ofSize: 12.0)

            }
        }
		
		registerEvent(Event.contentForConsole) { note in
			if let text = note.userInfo?["text"] as? String {
				self.setNewContent(string: text)
			}
		}
    }

    fileprivate func updateGeometry() {
        frame.size.height = textStorage!.size().height + font!.pointSize
    }
	
	private func setNewContent(string: String) {
		self.textStorage!.replaceCharacters(in: NSRange(location: 0, length: self.textStorage!.characters.count), with: NSAttributedString(string: string))
		self.updateGeometry()
		self.textColor = NSColor.white
		self.font = NSFont.systemFont(ofSize: 12.0)
	}
	
//    override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
//
//        // Drawing code here.
//    }
    
}
