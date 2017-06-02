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
	case mainDirectoryDidSelect
	case filesToOpenDidSelect
	case runDidFinish
	
	func dispatch(_ info: [String:AnyObject]? = nil) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: self.rawValue), object: nil, userInfo: info)
	}
}
