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
}
