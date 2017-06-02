//
//  EventObserver.swift
//  Kadry
//
//  Created by Piotr Pszczolkowski on 02/09/16.
//  Copyright © 2016 Piotr Pszczolkowski. All rights reserved.
//

import Foundation

protocol EventObserver: class {
	var observers: [NSObjectProtocol] { get set }
}

extension EventObserver {
	
	func registerEvent(_ name: NSNotification.Name, block: @escaping (Notification) -> Void) {
		let observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: block)
		observers.append(observer)
	}
	
	func registerEvent(_ name: String, block: @escaping (Notification) -> Void) {
		let observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: name), object: nil, queue: nil, using: block)
		observers.append(observer)
	}
	
	func registerEvent(_ event: Event, block: @escaping (Notification) -> Void) {
		let observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: event.rawValue), object: nil, queue: nil, using: block)
		observers.append(observer)
	}
	
	func removeObservers() {
		let nc = NotificationCenter.default
		observers.forEach { observer in
			nc.removeObserver(observer)
		}
		observers.removeAll()
	}
}
