//
//  AlamoFireDataLoader.swift
//  LibraryShowcase
//
//  Created by Andrew Rahn on 3/9/17.
//  Copyright © 2017 Rahn Family. All rights reserved.
//

import UIKit
import Foundation
import Siesta
import PromiseKit

class SiestaDataLoader: ExampleDataLoaderType {

	let siestaService = Service(
			baseURL: AppDelegate.SERVICE_URL,
			useDefaultTransformers: true,
			networking: URLSessionConfiguration.ephemeral
		)

	init() {
		siestaService.configureTransformer(AppDelegate.THEME_PATH) {
			(input: Entity<[Any]>) throws -> [Theme]? in
			let rawThemes = input.content
			let result:[Theme] = rawThemes.flatMap {
				if let entry = $0 as? [String:Any],
						let name = entry["name"] as? String,
						let hex = entry["hex"] as? String {
					return Theme(color: UIColor(hexString: hex)!, name: name)
				}
				return nil
			}
			return result
		}
	}
	
	func loadThemes() -> Promise<[Theme]> {
		return siestaService.resource(AppDelegate.THEME_PATH).toPromise()
	}
}

enum SiestaErrors: Error {
	case malformedData
	case unknownError
}

class ThemeObserver<T: Any>: ResourceObserver {
	let promise: Promise<T>
	let resultCallback: ((T) -> Void)
	let errorCallback: ((Error) -> Void)
	let resource: Resource
	var memoryKey = "ThemeObserver.memoryKey"
	var fulfilled = false {
		didSet {
			if fulfilled {
				resource.removeObservers(ownedBy: self)
				objc_removeAssociatedObjects(promise)
			}
		}
	}
	
	init(resource: Resource) {
		self.resource = resource
		(promise: promise, fulfill: resultCallback, reject: errorCallback) = Promise<T>.pending()
		resource.addObserver(self)
		resource.load()
		objc_setAssociatedObject(promise, &memoryKey, self, .OBJC_ASSOCIATION_RETAIN)
	}
	
	func resourceChanged(_ resource: Resource, event: ResourceEvent) {
		if fulfilled {
			return
		}
		switch event {
			case .newData:
				if let content: T = resource.typedContent() {
					resultCallback(content)
					fulfilled = true
				}
			case .error:
				errorCallback(resource.latestError ?? SiestaErrors.unknownError)
				fulfilled = true
			default:
				break
		}
	}
}

extension Resource {
	

	func toPromise<T>() -> Promise<T> {
		return ThemeObserver(resource: self).promise
	}
}
