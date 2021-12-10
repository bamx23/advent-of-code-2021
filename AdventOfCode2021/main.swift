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
    var cache = [[Int]](repeating: [Int](repeating: -1, count: 10), count: days + 1)

    func count(fish: Int, days: Int) -> Int {
        if cache[days][fish] != -1 { return cache[days][fish] }
        var total = 1
        var daysLeft = days - fish
        while daysLeft > 0 {
            total += count(fish: 9, days: daysLeft)
            daysLeft -= 7
        }
        cache[days][fish] = total
        return total
    }

    let count = fishes.map { count(fish: $0, days: days) }.reduce(0, +)
    print("T06_2: \(count)")
}

// MARK: - Day 07

extension TaskInput {
    func task07() -> [Int] {
        readInput("07")
            .split(separator: "\n")
            .first!
            .split(separator: ",")
            .map { Int($0)! }
    }
}

func task07_1(_ input: TaskInput) {
    let crabs = input.task07()
//    let mean = crabs.reduce(0, +) / crabs.count
    var minFuel = Int.max
    for pos in crabs.min()!...crabs.max()! { //(mean-1)...(mean+1) {
        minFuel = min(minFuel, crabs.map{ abs($0 - pos) }.reduce(0, +))
    }
    print("T07_1: \(minFuel)")
}

func task07_2(_ input: TaskInput) {
    let crabs = input.task07()

    var cache = [Int](repeating: 0, count: crabs.max()! - crabs.min()! + 1)
    for idx in 1..<cache.count {
        cache[idx] = cache[idx - 1] + idx
    }

    var minFuel = Int.max
    for pos in crabs.min()!...crabs.max()! { //(mean-1)...(mean+1) {
        minFuel = min(minFuel, crabs.map{ cache[abs($0 - pos)] }.reduce(0, +))
    }
    print("T07_2: \(minFuel)")
}

// MARK: - Day 08

let asciA = "a".first!.asciiValue!

extension TaskInput {
    private func toSignals<T: StringProtocol>(_ str: T) -> [Set<Int>] {
        str
            .split(separator: " ")
            .map { v in Set(v.map { Int($0.asciiValue! - asciA) }) }
    }

    func task08() -> [(Set<Set<Int>>, [Set<Int>])] {
        readInput("08")
            .split(separator: "\n")
            .map { line -> (Set<Set<Int>>, [Set<Int>]) in
                let pair = line.split(separator: "|")
                let signals = Set(toSignals(pair[0]))
                let digits = toSignals(pair[1])
                return (signals, digits)
            }
    }
}

func task08_1(_ input: TaskInput) {
    let lines = input.task08()
    let count = lines.map(\.1).flatMap { $0 }.filter { [2,3,4,7].contains($0.count) }.count
    print("T08_1: \(count)")
}

func task08_2(_ input: TaskInput) {
    let lines = input.task08()

    let digitMapping = [
        0: "abcefg",
        1: "cf",
        2: "acdeg",
        3: "acdfg",
        4: "bcdf",
        5: "abdfg",
        6: "abdefg",
        7: "acf",
        8: "abcdefg",
        9: "abcdfg",
    ].mapValues { v in v.map { Int($0.asciiValue! - asciA) } }
    let allChars = Set<Int>(digitMapping.flatMap({ $0.value }))

    func bf(signals: Set<Set<Int>>, map: inout [Int], leftChars: inout Set<Int>) -> [Set<Int>: Int]? {
        guard map.count == 7 else {
            for ch in leftChars.map({$0}) {
                map.append(ch)
                leftChars.remove(ch)
                if let result = bf(signals: signals, map: &map, leftChars: &leftChars) {
                    return result
                }
                leftChars.insert(ch)
                map.removeLast()
            }
            return nil
        }

        let mapping = digitMapping.mapValues { v in Set(v.map { map[$0] }) }
        if Set(mapping.values) == signals {
            return Dictionary(uniqueKeysWithValues: mapping.map { ($1, $0) })
        } else {
            return nil
        }
    }

    let sum = lines.map { (signals, digits) in
        var map = [Int]()
        var leftChars = Set(allChars)
        let mapping = bf(signals: signals, map: &map, leftChars: &leftChars)
        let val = digits.map { mapping![$0]! }.reduce(0, { $0 * 10 + $1 })
        return val
    }.reduce(0, +)

    print("T08_2: \(sum)")
}

// MARK: - Day 09

extension TaskInput {
    func task09() -> [[Int]] {
        readInput("09")
            .split(separator: "\n")
            .map { l in l.map { Int(String($0))! } }
    }
}

public struct DSU {
    private var parent: [Int] = []
    private var sz: [Int] = []

    public init(length: Int) {
        let arange = (0..<length).map { $0 }
        parent = arange
        sz = arange
    }

    mutating public func findParent(of u: Int) -> Int {
        var u = u
        while parent[u] != u {
            (u, parent[u]) = (parent[u], parent[parent[u]])
        }
        return u
    }

    mutating public func unionSets(_ u: Int, _ v: Int) {
        var u = findParent(of: u)
        var v = findParent(of: v)
        guard u != v else { return }

        if (sz[u] < sz[v]) {
            (u, v) = (v, u)
        }
        parent[v] = u
        sz[u] += sz[v]
    }
}

func task09_1(_ input: TaskInput) {
    let map = input.task09()
    let (h, w) = (map.count, map.first!.count)

    var total = 0
    for y in 0..<h {
        for x in 0..<w {
            var isLowest = true
            for (dy, dx) in [(0, 1), (0, -1), (1, 0), (-1, 0)] {
                let (ny, nx) = (y + dy, x + dx)
                guard 0 <= ny && ny < h && 0 <= nx && nx < w else { continue }
                if map[ny][nx] <= map[y][x] {
                    isLowest = false
                    break
                }
            }
            if isLowest {
                total += (map[y][x] + 1)
            }
        }
    }

    print("T09_1: \(total)")
}

func task09_2(_ input: TaskInput) {
    let map = input.task09()
    let (h, w) = (map.count, map.first!.count)

    var dsu = DSU(length: h * w)
    for y in 0..<h {
        for x in 0..<w {
            guard map[y][x] != 9 else { continue }
            for (dy, dx) in [(0, -1), (-1, 0)] {
                let (ny, nx) = (y + dy, x + dx)
                guard 0 <= ny && ny < h && 0 <= nx && nx < w else { continue }
                guard map[ny][nx] != 9 else { continue }
                dsu.unionSets(y * w + x, ny * w + nx)
            }
        }
    }

    var sizes: [Int: Int] = [:]
    for y in 0..<h {
//        var line = [Int]()
        for x in 0..<w {
            let p = dsu.findParent(of: y * w + x)
//            line.append(p)
            guard map[y][x] != 9 else { continue }
            sizes[p, default: 0] += 1
        }
//        print(line.map { String(format: "%02d", $0) }.joined(separator: " "))
    }

    let greaterSizes = sizes.values.sorted().reversed()[0..<3]
    let total = greaterSizes.reduce(1, *)

    print("T09_2: \(greaterSizes) -> \(total)")
}

// MARK: - Day 10

extension TaskInput {
    func task10() -> [[Character]] {
        readInput("10")
            .split(separator: "\n")
            .map([Character].init)
    }
}

enum T10 {
    static let closers: [Character: Character] = [
        "{": "}",
        "[": "]",
        "(": ")",
        "<": ">",
    ]
    static let score: [Character: Int] = [
        ")": 3,
        "]": 57,
        "}": 1197,
        ">": 25137,
    ]
    static let cScore: [Character: Int] = [
        ")": 1,
        "]": 2,
        "}": 3,
        ">": 4,
    ]
}

func task10_1(_ input: TaskInput) {
    let lines = input.task10()
    var total = 0
    for line in lines {
        var stack = [Character]()
        var done = false
        for ch in line {
            switch ch {
            case "{", "[", "(", "<":
                stack.append(ch)
            default:
                if stack.isEmpty || T10.closers[stack.removeLast()]! != ch {
                    total += T10.score[ch]!
                    done = true
                    break
                }
            }
            if done { break }
        }
    }
    print("T10_1: \(total)")
}

func task10_2(_ input: TaskInput) {
    let lines = input.task10()
    var totals = [Int]()
    for line in lines {
        var stack = [Character]()
        var done = false
        for ch in line {
            switch ch {
            case "{", "[", "(", "<":
                stack.append(ch)
            default:
                if stack.isEmpty || T10.closers[stack.removeLast()]! != ch {
                    done = true
                    break
                }
            }
            if done { break }
        }
        if done { continue }
        totals.append(
            stack.reversed().map { T10.cScore[T10.closers[$0]!]! }.reduce(0, { $0 * 5 + $1 })
        )
    }
    totals.sort()
    let mid = totals[totals.count / 2]
    print("T10_2: \(mid)")
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
//
//    task06_1(input)
//    task06_2(input)
//
//    task07_1(input)
//    task07_2(input)
//
//    task08_1(input)
//    task08_2(input)
//
//    task09_1(input)
//    task09_2(input)

    task10_1(input)
    task10_2(input)
}
