//
//  Shared.swift
//  GoEditor
//
//  Created by Piotr Pszczolkowski on 02/06/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Foundation

final class Shared {
    static var mainPackageDirectory: String? {
        didSet {
            Event.mainDirectoryDidChange.dispatch()
        }
    }
	static var lastOpenedFileDirectory: String?
}
