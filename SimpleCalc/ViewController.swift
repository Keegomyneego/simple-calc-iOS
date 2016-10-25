//
//  ViewController.swift
//  SimpleCalc
//
//  Created by Keegs on 10/24/16.
//  Copyright © 2016 Keegan Farley. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var expressionQueueLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!

    // Tightly couple this with total label's text.
    // Conversion to number can happen at evaluation time
    private var currentNumber: String {
        get {
            return totalLabel.text!
        }
        set {
            totalLabel.text = newValue
        }
    }

    // Tightly couple this with total label's text.
    // Conversion to number can happen at evaluation time
    private var expressionQueue: [Expression] = [] {
        willSet {
            print("willSet to \(newValue)")
        }
        didSet {
            print("didSet to \(oldValue)")
        }
    }

    //------------------------------------------------------------
    // UIViewController Overrides
    //------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        resetCurrentNumber()
        resetExpressionQueue()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //------------------------------------------------------------
    // IBActions
    //------------------------------------------------------------

    @IBAction func numberSelected(_ sender: UIButton) {
        currentNumber += sender.currentTitle ?? ""
    }

    @IBAction func operatorSelected(_ sender: UIButton) {
        let numberExpression = Expression(string: currentNumber)
        let operatorExpression = Expression(string: sender.currentTitle ?? "")

        expressionQueue += [numberExpression, operatorExpression]

        resetCurrentNumber()
    }

    @IBAction func backspaceSelected(_ sender: UIButton) {
    }

    @IBAction func equalsSelected(_ sender: UIButton) {
    }

    //------------------------------------------------------------
    // Helper Methods
    //------------------------------------------------------------

    private func resetCurrentNumber() {
        currentNumber = ""
    }

    private func resetExpressionQueue() {
        expressionQueue = []
    }
}

class Expression : CustomStringConvertible {
    let description: String

    init(string: String) {
        self.description = string
    }
}

