//
//  AlamoFireDataLoader.swift
//  LibraryShowcase
//
//  Created by Andrew Rahn on 3/9/17.
//  Copyright © 2017 Rahn Family. All rights reserved.
//

import UIKit
import Foundation
import Moya
import PromiseKit

struct MockAPI: TargetType {

    /// The target's base `URL`.
    let baseURL = URL(string: AppDelegate.SERVICE_URL)!

    /// The path to be appended to `baseURL` to form the full `URL`.
    let path = AppDelegate.THEME_PATH

    /// The HTTP method used in the request.
    let method = Moya.Method.get

    /// The parameters to be incoded in the request.
    let parameters: [String: Any]? = nil

    /// The method used for parameter encoding.
    let parameterEncoding: ParameterEncoding = URLEncoding()

    /// Provides stub data for use in testing.
    let sampleData = Data(base64Encoded: "WwogICAgewogICAgICAgICJjb2xvciI6ICJyZWQiLCAKICAgICAgICAiaGV4IjogIiNmMDAiLCAKICAgICAgICAibmFtZSI6ICJSYW1idW5jdGlvdXMgUmVkIgogICAgfSwgCiAgICB7CiAgICAgICAgImNvbG9yIjogImdyZWVuIiwgCiAgICAgICAgImhleCI6ICIjMGYwIiwgCiAgICAgICAgIm5hbWUiOiAiR2xvcmlvdXMgR3JlZW4iCiAgICB9LCAKICAgIHsKICAgICAgICAiY29sb3IiOiAiYmx1ZSIsIAogICAgICAgICJoZXgiOiAiIzAwZiIsIAogICAgICAgICJuYW1lIjogIkJyaWxsaWFudCBCbHVlIgogICAgfSwgCiAgICB7CiAgICAgICAgImNvbG9yIjogImN5YW4iLCAKICAgICAgICAiaGV4IjogIiMwZmYiLCAKICAgICAgICAibmFtZSI6ICJDeW5pY2FsIEN5YW4iCiAgICB9LCAKICAgIHsKICAgICAgICAiY29sb3IiOiAibWFnZW50YSIsIAogICAgICAgICJoZXgiOiAiI2YwZiIsIAogICAgICAgICJuYW1lIjogIk1vb2R5IE1hZ2VudGEiCiAgICB9LCAKICAgIHsKICAgICAgICAiY29sb3IiOiAieWVsbG93IiwgCiAgICAgICAgImhleCI6ICIjZmYwIiwgCiAgICAgICAgIm5hbWUiOiAiWWUgb2xkZSBZZWxsb3ciCiAgICB9LCAKICAgIHsKICAgICAgICAiY29sb3IiOiAiYmxhY2siLCAKICAgICAgICAiaGV4IjogIiMwMDAiLCAKICAgICAgICAibmFtZSI6ICJCdW1ibGluZyBCbGFjayIKICAgIH0KXQo=")!

    /// The type of HTTP task to be performed.
    let task = Task.request

    /// Whether or not to perform Alamofire validation. Defaults to `false`.
    let validate = true

}

class MoyaDataLoader: ExampleDataLoaderType {
	let provider = MoyaProvider<MockAPI>()
	
    func getThemes(
        success successCallBack: @escaping ([Theme]) -> Void,
        error errorCallback: @escaping (_ error: Moya.Error) -> Void
        ) {
        provider.request(MockAPI()) { response in
			let themes = response.map({ response -> [Theme] in
				do {
					if let entries = try response.mapJSON() as? [Any] {
						return entries.flatMap{ inEntry -> Theme? in
							if let entry = inEntry as? [String:Any],
									let name = entry["name"] as? String,
									let hex = entry["hex"] as? String {
								return Theme(color: UIColor(hexString: hex)!, name: name)
							}
							return nil
						}
					}
					return []
				} catch {
					return []
				}
			})
			successCallBack(themes.value!)
		}
    }

	func loadThemes() -> Promise<[Theme]> {
        return Promise { fulfill, reject in
            self.getThemes(
                success: { place in
                    _ = fulfill(place)
                }, error: { error in
                    _ = reject(error)
            })
        }
    }
}
