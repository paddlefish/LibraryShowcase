//
//  GraphDatabaseViewController.swift
//  LibraryShowcase
//
//  Created by Andrew Rahn on 3/9/17.
//  Copyright © 2017 Rahn Family. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Charts

final class Launch: Object {
    dynamic var text = ""
	dynamic var when: TimeInterval = 0
    dynamic var completed = false
}


class GraphDatabaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var barChart: BarChartView!
	var items = List<Launch>()
	var notificationToken: NotificationToken!
	var realm: Realm!

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "My Launches"
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		tableView.delegate = self
		tableView.dataSource = self

		let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
		self.realm = try! Realm(configuration: configuration)
		// Show initial tasks
		func updateList() {
			if self.items.realm == nil {
				let list = self.realm.objects(Launch.self)
				self.items = List(list)
			}
			self.tableView.reloadData()
			var dataEntries: [BarChartDataEntry] = []
			let maxValue: TimeInterval = TimeInterval(Int.max)
			let min:TimeInterval = self.items.reduce(maxValue) { (theMin: TimeInterval, launch: Launch) -> TimeInterval in
				return TimeInterval.minimum(theMin, launch.when)
			}
			let max:TimeInterval = self.items.reduce(0) { (theMin: TimeInterval, launch: Launch) -> TimeInterval in
				return TimeInterval.maximum(theMin, launch.when)
			}
			let numBins = 24
			for i in 0..<numBins {
				let start = min + (max - min) * Double(i) / Double(numBins)
				let end = min + (max - min) * Double(i + 1) / Double(numBins)
				let count = self.items.reduce(0) { (count: TimeInterval, launch: Launch) -> TimeInterval in
					if launch.when >= start && launch.when < end {
						return count + 1
					}
					return count
				}
				let dataEntry = BarChartDataEntry(x: Double(i), y: Double(count))
				dataEntries.append(dataEntry)
			}
			let chartDataSet = BarChartDataSet(values: dataEntries, label: "Launches")
			let chartData = BarChartData(dataSet: chartDataSet)
			barChart.data = chartData
		}
		updateList()

		// Notify us when Realm changes
		self.notificationToken = self.realm.addNotificationBlock { _ in
			updateList()
		}
		self.addItem()
		
		tabBarItem = UITabBarItem(title: "Launches", image: UIImage(named: "01")?.imageScaled(to: CGSize(width: 32, height: 32)), selectedImage: nil)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.addItem()
	}

	func addItem() {
		let formatter = DateFormatter()
		formatter.dateStyle = .long
		formatter.timeStyle = .medium

		let date = Date()
		let dateString = formatter.string(from: date)
 		let launch = Launch(value: ["text": dateString, "when": date.timeIntervalSinceReferenceDate])
		do {
			try realm.write {
				realm.add(launch)
			}
		} catch(let e) {
			print("Uh oh: \(e)")
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let item = items[indexPath.row]
		cell.textLabel?.text = item.text
		cell.textLabel?.alpha = item.completed ? 0.5 : 1
		return cell
	}
}
