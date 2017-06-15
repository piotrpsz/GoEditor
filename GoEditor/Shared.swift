//
//  Shared.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 02/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Cocoa

final class Shared {
    static private var envData: [String:String]?
	static let appName = "GoEditor"
	
	
    
    static var mainPackageDirectory: String? {
        didSet {
            Event.mainDirectoryDidChange.dispatch()
        }
    }
	static var lastOpenedFileDirectory: String?
    
    
    static func environment() -> [String:String] {
        if envData == nil {
            readEnvironment()
        }
        return envData!
    }
    
    static private func readEnvironment() {
		let data = ProcessInfo.processInfo.environment
        var dictionary: [String:String] = [:]
		data.forEach {
			dictionary[$0.key] = $0.value
		}
        if data.count > 0 {
            envData = dictionary
        }
    }
	
	static func drawSubviews(of view: NSView, level: Int = 0) {
		let filler = String(repeating: " ", count: level)
		print("\(filler)\(view)")
		for subview in view.subviews {
			drawSubviews(of: subview, level: level + 1)
		}
	}
	
	static var privateDirectory: String? {
		get {
			let path = NSHomeDirectory() + "/.GoEditor"
			let fm = Foundation.FileManager.default
			do {
				try fm.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
			}
			catch let error as NSError {
				print("Can't create applications directory: \(error.localizedDescription)")
				return nil
			}
			return path
		}
	}
	
	static func removeFile(at url: URL) -> Bool {
		let fm = FileManager.default
		do {
			if fm.fileExists(atPath: url.path) {
				try fm.removeItem(at: url)
			}
		} catch let error as NSError {
			Swift.print("\(error.localizedDescription)")
			return false
		}
		return true
	}
	
	static func alert(title: String, message: String, information: String?) {
		let alert = NSAlert()
		alert.window.title = title
		alert.messageText = message
		alert.informativeText = information ?? ""
		alert.runModal()
	}
	
	static func threadInfo() -> String {
		var number, name: String?
		let info: String = "\(Thread.current)"
		
		if let idx0 = info.range(of: "{")?.upperBound {
			if let idx1 = info.range(of: "}")?.lowerBound {
				let string = String(info[idx0..<idx1])
				let token = string.components(separatedBy: ",")
				for item in token {
					let keyAndValue = item.components(separatedBy: "=")
					if keyAndValue.count == 2 {
						let key   = keyAndValue[0].trimmingCharacters(in: CharacterSet.whitespaces)
						let value = keyAndValue[1].trimmingCharacters(in: CharacterSet.whitespaces)
						if key == "number" {
							number = value
						}
						else if key == "name" {
							name = value
						}
					}
				}
			}
		}
		let marker = (name == "main") ? "m" : ""
		return "\(number!)\(marker)"
	}
	
	
}
