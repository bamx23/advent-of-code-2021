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

// MARK: - Day 04

extension TaskInput {
    func task04() -> ([Int], [[[Int]]]) {
        let lines = readInput("04").split(separator: "\n")
        let nums = lines.first!.split(separator: ",").compactMap { Int($0) }
        var boards = [[[Int]]]()
        for b_idx in 0..<((lines.count - 1) / 5) {
            boards.append(
                lines[(1 + b_idx * 5)..<(1 + (b_idx + 1) * 5)]
                    .map { l in l.split(separator: " ").compactMap { Int($0) } }
            )
        }
        return (nums, boards)
    }
}

func task04_1(_ input: TaskInput) {
    var (nums, boards) = input.task04()

    var (bestIdx, bestSum, bestNum) = (Int.max, 0, 0)

//    print("\(boards)")

    for b in boards.indices {
        var cols = [Int](repeating: 0, count: 5)
        var rows = [Int](repeating: 0, count: 5)
        for (idx, num) in nums.enumerated() {
            if idx > bestIdx { break }
            for y in 0..<5 {
                for x in 0..<5 {
                    if boards[b][y][x] == num {
                        cols[x] += 1
                        rows[y] += 1
                        boards[b][y][x] *= -1
                    }
                }
            }
            if cols.contains(5) || rows.contains(5) {
                let sum = boards[b].map { r in r.filter({ $0 > 0 }).reduce(0, +) }.reduce(0, +)
                bestIdx = idx
                bestNum = num
                bestSum = sum
//                print("\(b) \(idx) \(num) \(sum)")
            }
        }
    }
    print("T04_1: \(bestSum) * \(bestNum) = \(bestNum * bestSum)")
}

func task04_2(_ input: TaskInput) {
    var (nums, boards) = input.task04()

    var (bestIdx, bestSum, bestNum) = (0, 0, 0)

//    print("\(boards)")

    for b in boards.indices {
        var cols = [Int](repeating: 0, count: 5)
        var rows = [Int](repeating: 0, count: 5)
        for (idx, num) in nums.enumerated() {
            for y in 0..<5 {
                for x in 0..<5 {
                    if boards[b][y][x] == num {
                        cols[x] += 1
                        rows[y] += 1
                        boards[b][y][x] *= -1
                    }
                }
            }
            if cols.contains(5) || rows.contains(5) {
//                print("\(b) \(idx) \(num)")
                if idx < bestIdx { break }
                let sum = boards[b].map { r in r.filter({ $0 > 0 }).reduce(0, +) }.reduce(0, +)
                bestIdx = idx
                bestNum = num
                bestSum = sum
                break
//                print("\(b) \(idx) \(num) \(sum)")
            }
        }
    }
    print("T04_2: \(bestSum) * \(bestNum) = \(bestNum * bestSum)")
}

// MARK: - Day 05

extension TaskInput {
    struct Point {
        var x: Int
        var y: Int
    }
    func task05() -> [(Point, Point)] {
        readInput("05")
            .split(separator: "\n")
            .map { l -> (Point, Point) in
                let pair = l.split(separator: ">")
                let aa = pair[0].dropLast(2).split(separator: ",").map { Int($0)! }
                let bb = pair[1].dropFirst().split(separator: ",").map { Int($0)! }
                return (.init(x: aa[0], y: aa[1]), .init(x: bb[0], y: bb[1]))
            }
    }
}

func task05_1(_ input: TaskInput) {
    let lines = input.task05()
    let size = 1000
    var field = [[Int]](repeating: [Int](repeating: 0, count: size), count: size)
    for (a, b) in lines {
        if a.y == b.y {
            for x in min(a.x, b.x)...max(a.x, b.x) {
                field[a.y][x] += 1
            }
        } else if a.x == b.x {
            for y in min(a.y, b.y)...max(a.y, b.y) {
                field[y][a.x] += 1
            }
        }
    }
    let count = field.map { l in l.map { $0 >= 2 ? 1 : 0 }.reduce(0, +) }.reduce(0, +)
//    for y in 0..<10 {
//        print(field[y][..<10].map { "\($0)" }.joined())
//    }
    print("T05_1: \(count)")
}

func task05_2(_ input: TaskInput) {
    let lines = input.task05()
    let size = 1000
    var field = [[Int]](repeating: [Int](repeating: 0, count: size), count: size)
    for (a, b) in lines {
        if a.y == b.y {
            for x in min(a.x, b.x)...max(a.x, b.x) {
                field[a.y][x] += 1
            }
        } else if a.x == b.x {
            for y in min(a.y, b.y)...max(a.y, b.y) {
                field[y][a.x] += 1
            }
        } else if abs(a.x - b.x) == abs(a.y - b.y) {
            let dx = (b.x - a.x)/abs(b.x - a.x)
            let dy = (b.y - a.y)/abs(b.y - a.y)
            for idx in 0...abs(b.x - a.x) {
                field[a.y + dy * idx][a.x + dx * idx] += 1
            }
        }
    }
    let count = field.map { l in l.map { $0 >= 2 ? 1 : 0 }.reduce(0, +) }.reduce(0, +)
//    for y in 0..<10 {
//        print(field[y][..<10].map { $0 > 0 ? "\($0)" : "." }.joined())
//    }
    print("T05_2: \(count)")
}

// MARK: - Day 06

extension TaskInput {
    func task06() -> [Int] {
        readInput("06")
            .split(separator: "\n")
            .first!
            .split(separator: ",")
            .map { Int($0)! }
    }
}

func task06_1(_ input: TaskInput) {
    var fishes = input.task06()
    for _ in 0..<80 {
        let count = fishes.count
        for idx in 0..<count {
            fishes[idx] -= 1
            if fishes[idx] < 0 {
                fishes[idx] = 6
                fishes.append(8)
            }
        }
    }
    print("T06_1: \(fishes.count)")
}

func task06_2(_ input: TaskInput) {
    let fishes = input.task06()
    let days = 256
    var data = [[Int]](repeating: [Int](repeating: -1, count: 10), count: days + 1)

    func count(fish: Int, days: Int, data: inout [[Int]]) -> Int {
        if data[days][fish] != -1 { return data[days][fish] }
        var total = 1
        var daysLeft = days - fish
        while daysLeft > 0 {
            total += count(fish: 9, days: daysLeft, data: &data)
            daysLeft -= 7
        }
        data[days][fish] = total
        return total
    }

    let count = fishes.map { count(fish: $0, days: days, data: &data) }.reduce(0, +)
    print("T06_2: \(count)")
}

// MARK: - Main

let inputs = [
    TaskInput(prefix: "sample"),
    TaskInput(),
]

for input in inputs {
    print("Run for \(input.prefix)")
//    task01_1(input)
//    task01_2(input)
//
//    task02_1(input)
//    task02_2(input)
//
//    task03_1(input)
//    task03_2(input)
//
//    task04_1(input)
//    task04_2(input)
//
//    task05_1(input)
//    task05_2(input)

    task06_1(input)
    task06_2(input)
}
