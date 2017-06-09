//
//  Constants.swift
//  Kadry
//
//  Created by Piotr Pszczolkowski on 02/09/16.
//  Copyright © 2016 Piotr Pszczolkowski. All rights reserved.
//

import Foundation


enum Event: String {
	case applicationStarted
	case mainDirectoryDidChange
	case filesToOpenDidSelect
	case runDidFinish
	case saveRequest
	case contentForConsole
	
	func dispatch(_ info: [String:Any]? = nil) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: self.rawValue), object: nil, userInfo: info)
	}
}
