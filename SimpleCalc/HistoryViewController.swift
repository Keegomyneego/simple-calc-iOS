//
//  HistoryViewController.swift
//  SimpleCalc
//
//  Created by Keegs on 11/1/16.
//  Copyright © 2016 Keegan Farley. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    static var calculationHistory: [String] = []

    /// UI
    @IBOutlet weak var scrollView: UIScrollView!

    //------------------------------------------------------------
    // UIViewController Overrides
    //------------------------------------------------------------

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)


    }
}
