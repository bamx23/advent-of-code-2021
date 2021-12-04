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

// MARK: - Day 03

extension TaskInput {
    func task03() -> [[Bool]] {
        readInput("03")
            .split(separator: "\n")
            .map { line in line.map { $0 == "1" } }
    }
}

func task03_1(_ input: TaskInput) {
    let lines = input.task03()

    var nums = [Int](repeating: 0, count: lines.first!.count)
    for line in lines {
        for (idx, val) in line.enumerated() {
            nums[idx] += val ? 1 : 0
        }
    }
    let domination = lines.count / 2
    var gamma = 0
    var epsilon = 0
    for val in nums {
        if val > domination {
            gamma = gamma * 2 + 1
            epsilon = epsilon * 2
        } else {
            gamma = gamma * 2
            epsilon = epsilon * 2 + 1
        }
    }
    print("T03_1: \(gamma)*\(epsilon)=\(gamma * epsilon)")
}

func task03_2(_ input: TaskInput) {
    let lines = input.task03()

    func filter(_ values: [[Bool]], idx: Int = 0, flag: Bool) -> [[Bool]] {
        let count = values.map({ $0[idx] ? 1 : 0 }).reduce(0, +)
        let expected = (values.count % 2 == 0 && count == values.count / 2)
            ? flag
            : flag ? (count > values.count / 2) : (count <= values.count / 2)
//        print("\(count)/\(values.count) : \(expected)")
        return values.filter { $0[idx] == expected }
    }

    func calc(_ values: [[Bool]], flag: Bool) -> Int {
        var result = values
        for idx in 0..<(values.first!.count) {
            result = filter(result, idx: idx, flag: flag)
//            print("\(result.map { l in l.map { $0 ? "1": "0" }.joined() })")
            if result.count == 1 {
                var num = 0
                for val in result.first! {
                    num *= 2
                    if val {
                        num += 1
                    }
                }
                return num
            }
        }
        assertionFailure("Whops!")
        return 0
    }

    let o2 = calc(lines, flag: true)
//    print("-")
    let co2 = calc(lines, flag: false)
    print("T03_2: \(o2) * \(co2) = \(o2 * co2)")
}

// MARK: - Main

let inputs = [
    TaskInput(prefix: "sample"),
    TaskInput(),
]

for input in inputs {
    print("Run for \(input.prefix)")
    task01_1(input)
    task01_2(input)

    task02_1(input)
    task02_2(input)

    task03_1(input)
    task03_2(input)
}
