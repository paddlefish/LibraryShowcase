//
//  Theme.swift
//  LibraryShowcase
//
//  Created by Andrew Rahn on 3/9/17.
//  Copyright © 2017 Rahn Family. All rights reserved.
//

import Foundation
import UIKit

public struct Theme {
	let color: UIColor
	let name: String
	
	public init(color: UIColor, name: String) {
		self.color = color.flatten()
		self.name = name
	}
}
