//
//  AlamoFireDataLoader.swift
//  LibraryShowcase
//
//  Created by Andrew Rahn on 3/9/17.
//  Copyright © 2017 Rahn Family. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import PromiseKit

class AlamoFireDataLoader: ExampleDataLoaderType {
	enum AlamoFireErrors: Error {
		case malformedData
	}
	func loadThemes() -> Promise<[Theme]> {
		let result = Promise<[Theme]> { (resultCallback, errorCallback) in
			Alamofire
				.request(AppDelegate.SERVICE_URL + AppDelegate.THEME_PATH)
				.responseJSON { response in
					guard let rawThemes = response.result.value as? [Any] else {
						errorCallback(AlamoFireErrors.malformedData)
						return
					}
					let result:[Theme] = rawThemes.flatMap {
						if let entry = $0 as? [String:Any],
								let name = entry["name"] as? String,
								let hex = entry["hex"] as? String {
							return Theme(color: UIColor(hexString: hex)!, name: name)
						}
						return nil
					}
					resultCallback(result)
				}
		}
		return result
	}
}
