//
//  Shared.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 02/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Foundation

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
}
