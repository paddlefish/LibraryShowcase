//
//  FirstViewController.swift
//  LibraryShowcase
//
//  Created by Andrew Rahn on 3/8/17.
//  Copyright © 2017 Rahn Family. All rights reserved.
//

import UIKit
import Alamofire
import ChameleonFramework
import DZNEmptyDataSet
import BonMot
import MGSwipeTableCell

public class MyCell: MGSwipeTableCell {
	override public var reuseIdentifier: String? {
		return "FirstViewController.MyCell"
	}
}

public class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
	@IBOutlet var tableView: UITableView!
	@IBOutlet var templateCell: MyCell!
	@IBOutlet weak var arrghh: UIImageView!
	
	struct Theme {
		let color: UIColor
		let name: String
	}
	var themes: [Theme] = [] {
		didSet {
			tableView?.reloadData()
		}
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(reusable: templateCell)

		// A little trick for removing the cell separators
		self.tableView.tableFooterView = UIView()
		arrghh.heroID = "arrghh"
		isHeroEnabled = true
		navigationController?.isHeroEnabled = true
	}
	
	func loadData() {
		Alamofire
			.request("https://paddlefish.net/mock_api/v1/themes/")
			.responseJSON { [weak self] response in
				guard let sself = self, let rawThemes = response.result.value as? [Any] else {
					return
				}
				sself.themes = rawThemes.flatMap {
					if let entry = $0 as? [String:Any],
							let name = entry["name"] as? String,
							let hex = entry["hex"] as? String {
						return FirstViewController.Theme(color: UIColor(hexString: hex)!.flatten(), name: name)
					}
					return nil
				}
			}
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return themes.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeue(reusable: templateCell, for: indexPath) as! MyCell
		let theme = themes[indexPath.row]
		cell.textLabel?.text = theme.name
		cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: theme.color, isFlat: true)
		cell.backgroundColor = theme.color
		
		let contrast = UIColor(complementaryFlatColorOf: theme.color)
		let image = UIImage(named:"01")?.imageScaled(to: CGSize(width: 32, height: 32))
		let button = MGSwipeButton(title: "Arrghh", icon: image, backgroundColor: contrast)
		button.callback = { [weak self] (cell: MGSwipeTableCell) -> Bool in
			Chameleon.setGlobalThemeUsingPrimaryColor(theme.color, with: .light)
			if let sself = self {
				let window = sself.view.window
				window?.rootViewController = Storyboards.Main.instantiateInitialViewController()
			}
			return true
		}
		cell.leftButtons = [button]
		cell.leftSwipeSettings.transition = .rotate3D
		
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
		navigationController?.pushViewController(Storyboards.Main.instantiateSecondViewController(), animated: true)
	}
	
	public func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
		let template = "Do <b>it</b>."
		
		let bold = StringStyle(.font(BONFont.boldSystemFont(ofSize: 22)))
		let style = StringStyle(
			.font(BONFont.systemFont(ofSize: 22)),
			.color(UIColor.flatGreen),
			.alignment(.center),
			.xmlRules([
				.style("b", bold)
			])
		)
		
		return template.styled(with: style)
	}
	
	public func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
		let template = "Get Ready for <b>fun</b>."
		
		let bold = StringStyle(.font(BONFont.boldSystemFont(ofSize: 16)))
		let style = StringStyle(
			.font(BONFont.systemFont(ofSize: 16)),
			.color(UIColor.flatGray),
			.alignment(.center),
			.xmlRules([
				.style("b", bold)
			])
		)
		
		return template.styled(with: style)
	}

	public func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
		loadData()
	}
}

