//
//  HistoryViewController.swift
//  SimpleCalc
//
//  Created by Keegs on 11/1/16.
//  Copyright © 2016 Keegan Farley. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    typealias HistoryItemViewType = HistoryItemView

    static var calculationHistory: [String] = (1...34).map({ "sample \($0)" })

    /// UI
    @IBOutlet weak var historyItemContainer: UIStackView!

    //------------------------------------------------------------
    // UIViewController Overrides
    //------------------------------------------------------------

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        for (index, itemText) in HistoryViewController.calculationHistory.enumerated() {
            self.addHistoryItem(atPosition: index, with: itemText)
        }
    }

    private func addHistoryItem(atPosition position: Int, with text: String) {
        let historyItemNibName = String(describing: HistoryItemViewType.self)

        if let historyItemView = HistoryItemViewType.create() {
            // set properties
            historyItemView.setText(text)

            // add to view hierarchy
            self.historyItemContainer.addArrangedSubview(historyItemView)


//            print("HIV \(position)")
//            print("- \(historyItemView)")
//            print(" - subview: \(historyItemView.subviews[0])")
        }
    }
}
