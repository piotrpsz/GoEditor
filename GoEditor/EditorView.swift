//
//  Editor.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 29/05/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

final class EditorView: NSTextView {
	static fileprivate let keyWords = "break|default|func|interface|select|case|defer|go|map|struct|chan|else|goto|package|switch|const|fallthrough|if|range|type|continue|for|import|return|var"
	static fileprivate let keyWordsRegex = try! NSRegularExpression(pattern: "\\b(\(EditorView.keyWords))\\b", options: [])
	
	fileprivate var currentFontColor = NSColor.white
	fileprivate var filePath: String?
	
	override var backgroundColor: NSColor {
		get {
			return NSColor(calibratedWhite: 0.2, alpha: 1.0)
		}
		set {
			
		}
	}

    required init(frame frameRect: NSRect, filePath: String? = nil) {
        let textContainer = NSTextContainer(containerSize: frameRect.size)
        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = true
        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        self.filePath = filePath
        
        super.init(frame: frameRect, textContainer: textContainer)
        
        autoresizingMask = [.width, .height]
        autoresizesSubviews = true
        insertionPointColor = NSColor.white
        isEditable = true
        isSelectable = true
        isRichText = true

        maxSize = NSSize(width: CGFloat(Float.greatestFiniteMagnitude), height: CGFloat(Float.greatestFiniteMagnitude))
        delegate = self
    
        if let fpath = filePath {
            if let string = try? String(contentsOfFile: fpath) {
                self.textStorage?.append(NSAttributedString(string: string))
            }
        }
        // ustawienie koloru tekstu i fontu musi być po(!) dodaniu tekstu
        textColor = currentFontColor
        font = NSFont.systemFont(ofSize: 12.0)
        
        self.textStorage?.delegate = self
        updateGeometry()
        coloredSyntax(self.textStorage!)
        

<<<<<<< HEAD
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func updateGeometry() {
        frame.size.height = textStorage!.size().height + font!.pointSize
    }
    
    func openFile(fpath: String) {
        guard let string = try? String(contentsOfFile: fpath) else {
            return
        }
        textStorage!.replaceCharacters(in: NSRange(location: 0, length: textStorage!.characters.count), with: NSAttributedString(string: string))
        updateGeometry()
        textColor = currentFontColor
        font = NSFont.systemFont(ofSize: 12.0)
        coloredSyntax(self.textStorage!)
        filePath = fpath
    }
    
    func save() {
        guard let fpath = filePath else {
            return
        }
        
        do {
            try textStorage?.string.write(toFile: fpath, atomically: true, encoding: .utf8)
        }
        catch let error as NSError {
            Swift.print("\(error)")
            // dialog with information
        }
    }
}

extension EditorView: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        updateGeometry()
    }
=======
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	fileprivate func updateGeometry() {
		frame.size.height = textStorage!.size().height + font!.pointSize
	}
	
	func openFile(fpath: String) {
		guard let string = try? String(contentsOfFile: fpath) else {
			return
		}
        setNewContent(string: string)
		filePath = fpath
	}

    fileprivate func setNewContent(string: String) {
        after(0.1) {
            self.textStorage!.replaceCharacters(in: NSRange(location: 0, length: self.textStorage!.characters.count), with: NSAttributedString(string: string))
            self.updateGeometry()
            self.textColor = self.currentFontColor
            self.font = NSFont.systemFont(ofSize: 12.0)
            self.coloredSyntax(self.textStorage!)
        }
    }
    
	func save() {
		guard let fpath = filePath else {
			return
		}
		
		do {
			try textStorage?.string.write(toFile: fpath, atomically: true, encoding: .utf8)
		}
		catch let error as NSError {
			Swift.print("\(error)")
			// dialog with information
		}
	}
}

extension EditorView: NSTextViewDelegate {
	func textDidChange(_ notification: Notification) {
        try? self.textStorage!.string.write(toFile: filePath!, atomically: true, encoding: .utf8)
		updateGeometry()
        let (status, string) = GoTool.fmt(fpath: filePath!)
        if status == 0 {
            if let string = string {
                try? string.write(toFile: filePath!, atomically: true, encoding: .utf8)
                setNewContent(string: string)
            }
        }
        else {
            Swift.print("\(string)")
        }
//        Swift.print("Status: \(status)")
//        Swift.print("String: \(string)")
	}
>>>>>>> cb14d0c886f2f327d9866e67d589e779c017ed08
}

extension EditorView: NSTextStorageDelegate {
    func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        
    }
    
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        self.coloredSyntax(textStorage)
    }
    
    fileprivate func coloredSyntax(_ textStorage: NSTextStorage) {
        let string = textStorage.string
        
        textStorage.beginEditing()
        textStorage.addAttributes([NSAttributedStringKey.foregroundColor:currentFontColor], range: NSMakeRange(0, string.characters.count))
        
        let matches = EditorView.keyWordsRegex.matches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.characters.count))
        for match in matches {
            textStorage.addAttributes([NSAttributedStringKey.foregroundColor:NSColor.red], range: match.range)
        }
        textStorage.endEditing()
    }
}
