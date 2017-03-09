//
//  ExampleDataLoaderType.swift
//  LibraryShowcase
//
//  Created by Andrew Rahn on 3/9/17.
//  Copyright © 2017 Rahn Family. All rights reserved.
//

import PromiseKit


protocol ExampleDataLoaderType {
	func loadThemes() -> Promise<[Theme]>
}
