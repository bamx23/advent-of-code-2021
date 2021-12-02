//
//  main.swift
//  AdventOfCode2021
//
//  Created by Nikolay Valasatau on 1.12.21.
//

import Foundation

struct TaskInput {
    var prefix: String = "task"

    func readInput(_ num: String) -> String {
        let name = "\(prefix)\(num)"
        guard let url = Bundle.main.url(forResource: name, withExtension: "txt", subdirectory: "input")
        else {
            fatalError("Not found: input/\(name).txt")

        }
        return try! String(contentsOf: url)
    }
}

// MARK: - Day 01

extension TaskInput {
    func task01() -> [Int] {
        readInput("01")
            .split(separator: "\n")
            .map { Int($0)! }
    }
}

func task01_1(_ input: TaskInput) {
    let numbers = input.task01()
    let count = zip(numbers.dropLast(), numbers.dropFirst()).map { $0 < $1 ? 1 : 0 }.reduce(0, +)
    print("T01_1: \(count)")
}

func task01_2(_ input: TaskInput) {
    let numbers = input.task01()
    let count = zip(numbers.dropLast(3), numbers.dropFirst(3)).map { $0 < $1 ? 1 : 0 }.reduce(0, +)
    print("T01_2: \(count)")
}

// MARK: - Day 02

extension TaskInput {
    enum Direction: String {
        case forward
        case up
        case down
    }
    func task02() -> [(Direction, Int)] {
        readInput("02")
            .split(separator: "\n")
            .map { line -> (Direction, Int) in
                let pair = line.split(separator: " ")
                return (.init(rawValue: String(pair[0]))!, Int(pair[1])!)
            }
    }
}

func task02_1(_ input: TaskInput) {
    let instructions = input.task02()
    var (x, y) = (0, 0)
    for (direction, dist) in instructions {
        switch direction {
        case .forward:
            x += dist
        case .up:
            y -= dist
        case .down:
            y += dist
        }
    }
    print("T02_1: \(x)*\(y) = \(x * y)")
}

func task02_2(_ input: TaskInput) {
    let instructions = input.task02()
    var (x, y, aim) = (0, 0, 0)
    for (direction, dist) in instructions {
        switch direction {
        case .forward:
            x += dist
            y += dist * aim
        case .up:
            aim -= dist
        case .down:
            aim += dist
        }
    }
    print("T02_2: \(x)*\(y) = \(x * y)")
}

let inputs = [
    TaskInput(),
    TaskInput(prefix: "sample"),
]

for input in inputs {
    print("Run for \(input.prefix)")
    task01_1(input)
    task01_2(input)

    task02_1(input)
    task02_2(input)
}
