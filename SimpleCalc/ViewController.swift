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

    /// Errors
    enum EvaluationError: Error {
        case wrongNumberOfOperands
    }

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
        let operatorExpression: Operator = definedOperators[sender.currentTitle!]!

        if currentNumberExists() {
            let numberExpression: Number = Number(currentNumber)

            if operatorExpression.operatesImmediately {
                // do the operation now

                if let result = try? perform(operatorExpression, on: [numberExpression.getValue()]) {
                    currentNumber = "\(result)"
                } else {
                    print("Failed to perform \(operatorExpression) on \(numberExpression.getValue())")
                }
            } else {
                // add number and operator to queue

                expressionQueue += [numberExpression, operatorExpression] as [Expression]

                resetCurrentNumber()
            }
        } else if !expressionQueue.isEmpty {
            // replace last expression in queue

            expressionQueue.removeLast()
            expressionQueue.append(operatorExpression)
        }
    }

    @IBAction func backspaceSelected(_ sender: UIButton) {
        if currentNumberExists() {
            currentNumber.dropLastCharacter()
        }
    }

    @IBAction func equalsSelected(_ sender: UIButton) {
        if let result = evaluateExpressionQueue() {
            resetExpressionQueue()
            currentNumber = "\(result)"
        }
    }

    //------------------------------------------------------------
    // Abstracting Helper Methods
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

    //------------------------------------------------------------
    // Evaluation Helper Methods
    //------------------------------------------------------------

    // Attempts to perform the given operation on the given operands,
    // throwing an exception on invalid operand count.
    // Returns a single number
    private func perform(_ op: Operator, on numberQueue: [NumberType]) throws -> NumberType {
        print("performing \(op) on \(numberQueue)")

        if op.isValidOperandCount(numberQueue.count) {
            // assume operate consumes entire number queue
            // and returns a single number
            return op.operate(numberQueue)
        } else {
            throw EvaluationError.wrongNumberOfOperands
        }
    }

    private func getSanitizedListOfExpressions() -> [Expression]? {
        var sanitizedExpressions: [Expression] = expressionQueue

        // add current number if it exists
        if currentNumberExists() {
            sanitizedExpressions.append(Number(currentNumber))
        }

        guard !sanitizedExpressions.isEmpty else {
            return nil
        }

        // ignore unfinished operators
//        if sanitizedExpressions.last! is Operator {
//            sanitizedExpressions.removeLast()
//        }

        print("sanizited expr: \(sanitizedExpressions)")

        return sanitizedExpressions
    }

    private func evaluateExpressionQueue() -> NumberType? {
        guard let sanitizedExpressions = getSanitizedListOfExpressions() else {
            return nil
        }

        var numberQueue: [NumberType] = []

        // extracts one more operand before evaluation
        // i.e. 2 + 3 requires 3 where 4! can be performed immediately
        var delayedOperator: Operator?

        do {
            try sanitizedExpressions.forEach({ expression in
                if let number = expression as? Number {

                    numberQueue.append(number.getValue())

                    if let op = delayedOperator {
                        // assume operate consumes entire number queue
                        // and returns a single number
                        numberQueue = [try perform(op, on: numberQueue)]
                        delayedOperator = nil
                    }

                } else if let op = expression as? Operator {

                    guard op.operatesImmediately else {
                        delayedOperator = op
                        return
                    }

                    // assume operate consumes entire number queue
                    // and returns a single number
                    numberQueue = [try perform(op, on: numberQueue)]
                }
            })

            // unfinished operator
            guard delayedOperator == nil else {
                return nil
            }

            return numberQueue.first!
        } catch {
            return nil
        }
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
    var isValidOperandCount: (Int) -> Bool { get }
    var operate: OperatorFunction { get }
    var operatesImmediately: Bool { get }
}

class UnaryOperator : Operator {
    let description: String
    let isValidOperandCount: (Int) -> Bool = { $0 == 1 }
    let operate: OperatorFunction
    var operatesImmediately = true

    init(_ symbol: String, _ operation: @escaping (NumberType) -> NumberType) {
        self.description = symbol
        self.operate = {
            return operation( $0[$0.count - 1] )
        }
    }
}

class BinaryOperator : Operator {
    let description: String
    let isValidOperandCount: (Int) -> Bool = { $0 == 2 }
    let operate: OperatorFunction
    var operatesImmediately = false

    required init(_ symbol: String, _ operation: @escaping (NumberType, NumberType) -> NumberType) {
        self.description = symbol
        self.operate = {
            return operation( $0[$0.count - 2], $0[$0.count - 1] )
        }
    }
}

class MultaryOperator : Operator {
    let description: String
    let isValidOperandCount: (Int) -> Bool = { $0 >= 2 }
    let operate: OperatorFunction
    var operatesImmediately = false

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


//------------------------------------------------------------
// Extensions
//------------------------------------------------------------

extension String {
    mutating func dropLastCharacter() {
        self.remove(at: self.index(before: self.endIndex))
    }
}
