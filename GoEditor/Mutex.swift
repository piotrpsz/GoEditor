//
//  Mutex.swift
//  KadryServer
//
//  Created by Piotr Pszczolkowski on 12/03/2017.
//  Copyright © 2017 Piotr Pszczolkowski. All rights reserved.
//

import Foundation

final class Mutex {
	private var mutex = pthread_mutex_t()
	private var name: String
	
	required init(name: String) {
		self.name = name
		pthread_mutex_init(&mutex, nil)
	}
	
	deinit {
		pthread_mutex_destroy(&mutex)
	}
	
	func lock() -> Bool {
		let status = pthread_mutex_lock(&mutex)
		if status != -1 {
			return true
		}
		print("Mutex.\(name): can't be locked")
		return false
	}
	
	func unlock() -> Bool {
		let status = pthread_mutex_unlock(&mutex)
		if status != -1 {
			return true
		}
		print("Mutex.\(name): can't be unlocked")
		return false
	}

	func trylock() -> Bool {
		let status = pthread_mutex_trylock(&mutex)
		if status != EBUSY {
			return true
		}
		print("Mutex.\(name): buse, can't lock")
		return false
	}

	func sync(_ block: (() -> Void)? = nil) {
		if lock() {
			defer {
				_ = unlock()
			}
			block?()
		}
	}
}
