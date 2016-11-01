//
//  HistoryItemView.swift
//  SimpleCalc
//
//  Created by Keegs on 11/1/16.
//  Copyright © 2016 Keegan Farley. All rights reserved.
//

import UIKit

class HistoryItemView: UIView {

    @IBOutlet weak var textLabel: UILabel!

    public func setText(_ text: String) {
        self.textLabel.text = text
    }

    public static func create() -> HistoryItemView? {
        let container = UIViewController()
        let nibName = String(describing: self)
        let nibItems = Bundle.main.loadNibNamed(nibName, owner: container, options: nil)

        return nibItems?[0] as? HistoryItemView
    }
}
