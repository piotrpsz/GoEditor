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
	case openMainPackageDirectoryRequest, mainPackageDirectoryDidChange
	case filesToOpenRequest, newFileRequest
	case runDidFinish
	case saveRequest, saveAsRequest, saveAllRequest
	case editorsContainerContentDidChange, editorStateDidChange, currentEditor
	case userDidSelectEditor
	case contentForConsole
	case runRequest, buildRequest
	
	func dispatch(_ info: [String:Any]? = nil) {
		DispatchQueue.main.async {
			NotificationCenter.default.post(name: Notification.Name(rawValue: self.rawValue), object: nil, userInfo: info)
		}
	}
}
