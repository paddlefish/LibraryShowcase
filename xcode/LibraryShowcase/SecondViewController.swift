//
//  SecondViewController.swift
//  LibraryShowcase
//
//  Created by Andrew Rahn on 3/8/17.
//  Copyright © 2017 Rahn Family. All rights reserved.
//

import UIKit
import Hero

class SecondViewController: UIViewController {
	@IBOutlet weak var arrghh: UIImageView!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		arrghh.heroID = "arrghh"
		isHeroEnabled = true
	}
}

