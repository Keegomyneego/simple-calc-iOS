//
//  ViewController.swift
//  SimpleCalc
//
//  Created by Keegs on 10/24/16.
//  Copyright © 2016 Keegan Farley. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    /// UI
    @IBOutlet weak var expressionQueueLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!

    /// Operators
    var definedOperators: [String : Operator] = [
        "+" : BinaryOperator("+", +),
        "-" : BinaryOperator("-", -),
        "×" : BinaryOperator("x", *),
        "÷" : BinaryOperator("÷", /),
        "﹪" : BinaryOperator("%", %),
        "n!" : UnaryOperator("!", factorial),
        "#" : MultaryOperator("count", count),
        "x̅" : MultaryOperator("avg", average)
    ]

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

    // Tightly couple this with expression queue label's text.
    private var expressionQueue: [Expression] = [] {
        willSet {
            expressionQueueLabel.text = newValue
                .map({ "\($0)" })
                .joined(separator: " ")
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
        let operatorExpression: Expression = definedOperators[sender.currentTitle!]!

        if currentNumberExists() {
            // add number and operator to queue

            let numberExpression: Expression = Number(currentNumber)

            expressionQueue += [numberExpression, operatorExpression]

            resetCurrentNumber()
        } else if !expressionQueue.isEmpty {
            // replace last expression in queue

            expressionQueue.removeLast()
            expressionQueue.append(operatorExpression)
        }
    }

    @IBAction func backspaceSelected(_ sender: UIButton) {
    }

    @IBAction func equalsSelected(_ sender: UIButton) {
    }

    //------------------------------------------------------------
    // Helper Methods
    //------------------------------------------------------------

    private func currentNumberExists() -> Bool {
        return currentNumber != ""
    }

    private func resetCurrentNumber() {
        currentNumber = ""
    }

    private func resetExpressionQueue() {
        expressionQueue = []
    }
}


// Other classes I had to shove into this file because this assignment
// requires us to only modify ViewController.swift and Main.storyboard...

typealias NumberType = Int

//------------------------------------------------------------
// Expressions
//------------------------------------------------------------

protocol Expression : CustomStringConvertible {}

class Number : Expression {

    static let defaultNumberValue: NumberType = 0

    let description: String

    init(_ symbol: String) {
        self.description = symbol
    }

    func getValue() -> NumberType {
        return NumberType(self.description) ?? {
            print("Number :: Failed to convert '\(self)' to \(NumberType.self), falling back to default")
            return Number.defaultNumberValue
        }()
    }
}

//------------------------------------------------------------
// Operators
//------------------------------------------------------------

typealias OperatorFunction = ([NumberType]) -> NumberType

protocol Operator : Expression {
    var operate: OperatorFunction { get }
    var isValidOperandCount: (Int) -> Bool { get }
}

class UnaryOperator : Operator {
    let description: String
    let operate: OperatorFunction
    let isValidOperandCount: (Int) -> Bool = { $0 == 1 }

    init(_ symbol: String, _ operation: @escaping (NumberType) -> NumberType) {
        self.description = symbol
        self.operate = {
            return operation( $0[$0.count - 1] )
        }
    }
}

class BinaryOperator : Operator {
    let description: String
    let operate: OperatorFunction
    let isValidOperandCount: (Int) -> Bool = { $0 == 2 }

    required init(_ symbol: String, _ operation: @escaping (NumberType, NumberType) -> NumberType) {
        self.description = symbol
        self.operate = {
            return operation( $0[$0.count - 2], $0[$0.count - 1] )
        }
    }
}

class MultaryOperator : Operator {
    let description: String
    let operate: OperatorFunction
    let isValidOperandCount: (Int) -> Bool = { $0 >= 2 }

    required init(_ symbol: String, _ operation: @escaping ([NumberType]) -> NumberType) {
        self.description = symbol
        self.operate = operation
    }
}

//------------------------------------------------------------
// Yay global functions :/
//------------------------------------------------------------

func factorial(n: NumberType) -> NumberType {
    return n <= 1
        ? 1
        : n * factorial(n: n - 1)
}

func count(nums: [NumberType]) -> NumberType {
    return NumberType(nums.count)
}

func average(nums: [NumberType]) -> NumberType {
    // return sum / count
    return NumberType(nums.reduce(0, +)) / NumberType(nums.count)
}
