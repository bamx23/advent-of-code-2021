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
    struct Point: Hashable {
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

// MARK: - Day 11

extension TaskInput {
    func task11() -> [[Int]] {
        readInput("11")
            .split(separator: "\n")
            .map { l in l.map { Int(String($0))! } }
    }
}

func task11_1(_ input: TaskInput) {
    var map = input.task11()
    let (h, w) = (map.count, map.first!.count)
    var total = 0
    let steps = 100
    for _ in 0..<steps {
        var flashes = [(Int, Int)]()
        for y in 0..<h {
            for x in 0..<w {
                map[y][x] += 1
                guard map[y][x] == 10 else { continue }
                flashes.append((x, y))
            }
        }
        while flashes.isEmpty == false {
            let (x, y) = flashes.removeLast()
            total += 1
            for dy in -1...1 {
                for dx in -1...1 {
                    let (nx, ny) = (x + dx, y + dy)
                    guard 0 <= nx && nx < w && 0 <= ny && ny < h && (dx != 0 || dy != 0) else { continue }
                    map[ny][nx] += 1
                    guard map[ny][nx] == 10 else { continue }
                    flashes.append((nx, ny))
                }
            }
        }
        for y in 0..<h {
            for x in 0..<w {
                guard map[y][x] >= 10 else { continue }
                map[y][x] = 0
            }
        }
    }
    print("T11_1: \(total)")
}

func task11_2(_ input: TaskInput) {
    var map = input.task11()
    let (h, w) = (map.count, map.first!.count)
    var step = 0
    while true {
        step += 1
        var flashes = [(Int, Int)]()
        for y in 0..<h {
            for x in 0..<w {
                map[y][x] += 1
                guard map[y][x] == 10 else { continue }
                flashes.append((x, y))
            }
        }
        while flashes.isEmpty == false {
            let (x, y) = flashes.removeLast()
            for dy in -1...1 {
                for dx in -1...1 {
                    let (nx, ny) = (x + dx, y + dy)
                    guard 0 <= nx && nx < w && 0 <= ny && ny < h && (dx != 0 || dy != 0) else { continue }
                    map[ny][nx] += 1
                    guard map[ny][nx] == 10 else { continue }
                    flashes.append((nx, ny))
                }
            }
        }
        var isFinal = true
        for y in 0..<h {
            for x in 0..<w {
                guard map[y][x] >= 10 else {
                    isFinal = false
                    continue
                }
                map[y][x] = 0
            }
        }
        if isFinal { break }
    }
    print("T11_2: \(step)")
}

// MARK: - Day 12

extension TaskInput {
    func task12() -> [(String, String)] {
        readInput("12")
            .split(separator: "\n")
            .map { (String($0.split(separator: "-")[0]), String($0.split(separator: "-")[1])) }
    }
}

func task12_1(_ input: TaskInput) {
    let pairs = input.task12()
    let nbs = Dictionary(grouping: pairs + pairs.map { ($0.1, $0.0) }, by: { $0.0 }).mapValues { $0.map(\.1) }

    var paths = Set<[String]>()
    var path = [String]()
    var visited = Dictionary(uniqueKeysWithValues: nbs.keys.map { ($0, 0) })

    func dfs(node: String) {
        guard let nnbs = nbs[node], (node != node.lowercased() || visited[node]! == 0) else { return }
        visited[node, default: 0] += 1

        for n in nnbs {
            guard n != "start" else { continue }
            guard n != "end" else {
                paths.insert(path)
                continue
            }
            path.append(n)
            dfs(node: n)
            path.removeLast()
        }

        visited[node, default: 0] -= 1
    }

    dfs(node: "start")
//    print(paths.map{ $0.joined(separator: ",")}.sorted().joined(separator: "\n"))

    print("T12_1: \(paths.count)")
}

func task12_2(_ input: TaskInput) {
    let pairs = input.task12()
    let nbs = Dictionary(grouping: pairs + pairs.map { ($0.1, $0.0) }, by: { $0.0 }).mapValues { $0.map(\.1) }

    var paths = Set<[String]>()
    var path = [String]()
    var visited = Dictionary(uniqueKeysWithValues: nbs.keys.map { ($0, 0) })
    var extraNode: String?

    func dfs(node: String) {
        guard let nnbs = nbs[node],
              (node != node.lowercased() || visited[node]! == 0 || (node == extraNode && visited[node]! == 1))
        else { return }
        visited[node, default: 0] += 1

        for n in nnbs {
            guard n != "start" else { continue }
            guard n != "end" else {
                paths.insert(path)
                continue
            }
            path.append(n)
            dfs(node: n)
            path.removeLast()
        }

        if node == node.lowercased() && extraNode == nil {
            extraNode = node

            for n in nnbs {
                guard n != "start" else { continue }
                guard n != "end" else {
                    paths.insert(path)
                    continue
                }
                path.append(n)
                dfs(node: n)
                path.removeLast()
            }

            extraNode = nil
        }

        visited[node, default: 0] -= 1
    }

    dfs(node: "start")
//    print(paths.map{ $0.joined(separator: ",")}.sorted().joined(separator: "\n"))

    print("T12_1: \(paths.count)")
}

// MARK: - Day 13

extension TaskInput {

    func task13() -> ([Point], [Point]) {
        let lines = readInput("13").split(separator: "\n")
        var idx = 0
        var coords = [Point]()
        while lines[idx].starts(with: "fold") == false {
            let pair = lines[idx].split(separator: ",")
            coords.append(.init(x: Int(pair[0])!, y: Int(pair[1])!))
            idx += 1
        }
        var folds = [Point]()
        while idx < lines.count {
            let pair = lines[idx].split(separator: " ").last!.split(separator: "=")
            if pair[0] == "x" {
                folds.append(.init(x: Int(pair[1])!, y:0))
            } else {
                folds.append(.init(x: 0, y: Int(pair[1])!))
            }
            idx += 1
        }
        return (coords, folds)
    }
}

func task13_1(_ input: TaskInput) {
    let (_coords, folds) = input.task13()
    var coords = Set(_coords)
    let fold = folds.first!
    if fold.x == 0 {
        for c in Array(coords) {
            if c.y > fold.y {
                coords.remove(c)
                coords.insert(.init(x: c.x, y: c.y - (c.y - fold.y) * 2))
            }
        }
    } else {
        for c in Array(coords) {
            if c.x > fold.x {
                coords.remove(c)
                coords.insert(.init(x: c.x - (c.x - fold.x) * 2, y: c.y))
            }
        }
    }
    print("T13_1: \(coords.count)")
}

func task13_2(_ input: TaskInput) {
    let (_coords, folds) = input.task13()
    var coords = Set(_coords)
    for fold in folds {
        if fold.x == 0 {
            for c in Array(coords) {
                if c.y > fold.y {
                    coords.remove(c)
                    coords.insert(.init(x: c.x, y: c.y - (c.y - fold.y) * 2))
                }
            }
        } else {
            for c in Array(coords) {
                if c.x > fold.x {
                    coords.remove(c)
                    coords.insert(.init(x: c.x - (c.x - fold.x) * 2, y: c.y))
                }
            }
        }
    }

    let (w, h) = (coords.map(\.x).max()! + 1, coords.map(\.y).max()! + 1)
    var map = [[Bool]](repeating: [Bool](repeating: false, count: w), count: h)
    for c in coords {
        map[c.y][c.x] = true
    }
    let snap = map.map { l in l.map { $0 ? "@" : " " }.joined() }.joined(separator: "\n")

    print("T13_2:\n\(snap)")
}

// MARK: - Day 14

extension TaskInput {

    func task14() -> ([Character], [String: Character]) {
        let lines = readInput("14").split(separator: "\n")
        return (
            Array(lines.first!),
            Dictionary(uniqueKeysWithValues: lines.dropFirst().map { line in
                let ar = Array(line)
                return (String([ar[0], ar[1]]), ar[6])
            })
        )
    }
}

enum T14 {
    static func task14(_ input: TaskInput, sub: Int, steps: Int) {
        let (line, moves) = input.task14()
        var counts = [String: Int]()
        for (a, b) in zip(line.dropLast(), line.dropFirst()) {
            counts[String([a, b]), default: 0] += 1
        }
        var lCounts = Dictionary(grouping: line, by: { $0 }).mapValues { $0.count }
        for _ in 0..<steps {
            var nextCounts = counts
            for (key, count) in counts {
                if let next = moves[key] {
                    nextCounts[key, default: 0] -= count
                    nextCounts[String([key.first!, next]), default: 0] += count
                    nextCounts[String([next, key.last!]), default: 0] += count
                    lCounts[next, default: 0] += count
                }
            }
            counts = nextCounts
    //        print("S \(idx): \(counts.map { "\($0.key)->\($0.value)" }.joined(separator: ", "))")
        }
        let mostCommon = lCounts.max(by: { $0.value < $1.value })!
        let leastCommon = lCounts.min(by: { $0.value < $1.value })!
        print("T14_\(sub): \(mostCommon.key) -> \(mostCommon.value), \(leastCommon.key) -> \(leastCommon.value), \(mostCommon.value - leastCommon.value)")
    }
}

func task14_1(_ input: TaskInput) {
    T14.task14(input, sub: 1, steps: 10)
}

func task14_2(_ input: TaskInput) {
    T14.task14(input, sub: 1, steps: 40)
}

// MARK: - Day 15

extension TaskInput {
    func task15() -> [[Int]] {
        readInput("15").split(separator: "\n").map { l in l.map { Int(String($0))! }}
    }
}

enum T15 {
    static func task15(map: [[Int]], sub: Int) {
        let (w, h) = (map.count, map.first!.count)
        var score = [[Int]](repeating: [Int](repeating: Int.max, count: w), count: h)
        score[0][0] = 0

        var queue = [(0, 0)]
        while queue.isEmpty == false {
            let (x, y) = queue.removeFirst()
            for (dx, dy) in [(0, 1), (0, -1), (-1, 0), (1, 0)] {
                let (nx, ny) = (x + dx, y + dy)
                guard 0 <= nx && nx < w && 0 <= ny && ny < h else { continue }
                let s = score[y][x] + map[ny][nx]
                guard s < score[ny][nx] else { continue }
                score[ny][nx] = s
                queue.append((nx, ny))
            }
        }
        print("T15_\(sub): \(score.last!.last!)")
    }
}

func task15_1(_ input: TaskInput) {
    let map = input.task15()
    T15.task15(map: map, sub: 1)
}

func task15_2(_ input: TaskInput) {
    let tile = input.task15()
    let (tw, th) = (tile.count, tile.first!.count)
    var map = [[Int]](repeating: [Int](repeating: 0, count: tw * 5), count: th * 5)
    let (w, h) = (map.count, map.first!.count)
    for y in 0..<h {
        for x in 0..<w {
            let val = tile[y % th][x % tw] + (y / th) + (x / tw)
            map[y][x] = val > 9 ? val - 9 : val
        }
    }
    T15.task15(map: map, sub: 2)
}

// MARK: - Day 16

extension TaskInput {
    final class BitsReader {
        private static let hexMap: [Character: [Int]] = [
            "0": [0,0,0,0],
            "1": [0,0,0,1],
            "2": [0,0,1,0],
            "3": [0,0,1,1],
            "4": [0,1,0,0],
            "5": [0,1,0,1],
            "6": [0,1,1,0],
            "7": [0,1,1,1],
            "8": [1,0,0,0],
            "9": [1,0,0,1],
            "A": [1,0,1,0],
            "B": [1,0,1,1],
            "C": [1,1,0,0],
            "D": [1,1,0,1],
            "E": [1,1,1,0],
            "F": [1,1,1,1],
        ]

        private(set) var idx = 0;
        private let hex: [Character]

        init<T: Collection>(hex: T) where T.Element == Character {
            self.hex = .init(hex)
        }

        func nextInt(_ k: Int) -> Int {
            var result = 0
            for _ in 0..<k {
                result = (result << 1) | Self.hexMap[hex[idx / 4]]![idx % 4]
                idx += 1
            }
            return result;
        }
    }
    func task16() -> [BitsReader] {
        readInput("16").split(separator: "\n").map(BitsReader.init(hex:))
    }
}

enum T16 {
    struct Packet {
        enum Operator: Int {
            case sum = 0
            case product = 1
            case minimum = 2
            case maximum = 3
            case gt = 5
            case lt = 6
            case eq = 7
        }

        enum Payload {
            case literal(Int)
            case `operator`(Operator, [Packet])
        }

        var version: Int
        var payload: Payload
    }

    static func parsePacket(_ reader: TaskInput.BitsReader) -> Packet {
        let version = reader.nextInt(3)
        let type = reader.nextInt(3)
        let payload: Packet.Payload
        switch type {
        case 4:
            var literal = 0
            var isLast = false
            while isLast == false {
                isLast = reader.nextInt(1) == 0
                let batch = reader.nextInt(4)
                literal = (literal << 4) | batch
            }
            payload = .literal(literal)
        default:
            let lengthType = reader.nextInt(1)
            var subpackets = [Packet]()
            if lengthType == 0 {
                let length = reader.nextInt(15)
                let start = reader.idx
                while reader.idx < start + length {
                    subpackets.append(parsePacket(reader))
                }
            } else {
                let count = reader.nextInt(11)
                for _ in 0..<count {
                    subpackets.append(parsePacket(reader))
                }
            }
            payload = .operator(.init(rawValue: type)!, subpackets)
        }
        return .init(version: version, payload: payload)
    }
}

func task16_1(_ input: TaskInput) {
    let readers = input.task16()
    for (idx, reader) in readers.enumerated() {
        let packet = T16.parsePacket(reader)

        func sumVersions(_ packet: T16.Packet) -> Int {
            var result = packet.version
            switch packet.payload {
            case .literal:
                break
            case .operator(_, let subs):
                result += subs.map(sumVersions).reduce(0, +)
            }
            return result
        }

        print("T16_1_\(idx): \(sumVersions(packet))")
    }
}

func task16_2(_ input: TaskInput) {
    let readers = input.task16()
    for (idx, reader) in readers.enumerated() {
        let packet = T16.parsePacket(reader)

        func calc(_ packet: T16.Packet) -> Int {
            switch packet.payload {
            case .literal(let val):
                return val
            case .operator(let type, let subs):
                let subVals = subs.map(calc)
                switch type {
                case .sum:
                    return subVals.reduce(0, +)
                case .product:
                    return subVals.reduce(0, *)
                case .minimum:
                    return subVals.min()!
                case .maximum:
                    return subVals.max()!
                case .gt:
                    return subVals[0] > subVals[1] ? 1 : 0
                case .lt:
                    return subVals[0] < subVals[1] ? 1 : 0
                case .eq:
                    return subVals[0] == subVals[1] ? 1 : 0
                }
            }
        }

        print("T16_2_\(idx): \(calc(packet))")
    }
}

// MARK: - Day 17

extension TaskInput {
    func task17() -> (x: ClosedRange<Int>, y: ClosedRange<Int>) {
        let line = readInput("17").split(separator: "\n").first!
        let coords = line
            .split(separator: ":")[1]
            .split(separator: ",")
            .map { $0.dropFirst(3) }
            .flatMap { $0.split(separator: ".") }
            .map { Int($0)! }
        return (x: coords[0]...coords[1], y: coords[2]...coords[3])
    }
}

func task17_1(_ input: TaskInput) {
    let ranges = input.task17()

    var score = Int.min
    for _vx in 0...ranges.x.upperBound {
        for _vy in -ranges.y.upperBound...(4 * ranges.y.count + 1) {
            var (x, y) = (0, 0)
            var (vx, vy) = (_vx, _vy)
            var maxY = Int.min
            while x <= ranges.x.upperBound && y >= ranges.y.lowerBound {
                maxY = max(maxY, y)
                if ranges.x.contains(x) && ranges.y.contains(y) {
                    score = max(score, maxY)
//                    print("Match: \(_vx) \(_vy) -> \(score)")
                    break
                }
                if maxY < score && vy < 0 {
                    break
                }
                x += vx
                y += vy
                if vx != 0 {
                    vx -= vx / abs(vx)
                }
                vy -= 1
            }
        }
    }
    print("T17_1: \(score)")
}

func task17_2(_ input: TaskInput) {
    let ranges = input.task17()

    var count = 0
    for _vx in 0...ranges.x.upperBound {
        for _vy in (2 * ranges.y.upperBound)...(10 * ranges.y.count + 1) {
            var (x, y) = (0, 0)
            var (vx, vy) = (_vx, _vy)
            var maxY = Int.min
            while x <= ranges.x.upperBound && y >= ranges.y.lowerBound {
                maxY = max(maxY, y)
                if ranges.x.contains(x) && ranges.y.contains(y) {
                    count += 1
                    break
                }
                x += vx
                y += vy
                if vx != 0 {
                    vx -= vx / abs(vx)
                }
                vy -= 1
            }
        }
    }
    print("T17_2: \(count)")
}

// MARK: - Day 18

extension TaskInput {
    func task18() -> [T18.TreeNode] {
        readInput("18").split(separator: "\n").map(T18.TreeNode.parse)
    }
}

enum T18 {
    final class TreeNode {
        var val: Int?

        var left: TreeNode?
        var right: TreeNode?

        init(val: Int?, left: TreeNode?, right: TreeNode?) {
            self.val = val
            self.left = left
            self.right = right
        }

        static func parse<T: StringProtocol>(_ str: T) -> TreeNode {
            let result = parse(str, idx: str.startIndex).0
            result.reduce()
            return result
        }

        private static func parse<T: StringProtocol>(_ str: T, idx: T.Index) -> (TreeNode, T.Index) {
            var val: Int?
            var left: TreeNode?
            var right: TreeNode?
            var nextIdx = idx
            if str[idx] == "[" {
                nextIdx = str.index(after: nextIdx)
                (left, nextIdx) = parse(str, idx: nextIdx)
                nextIdx = str.index(after: nextIdx)
                (right, nextIdx) = parse(str, idx: nextIdx)
                nextIdx = str.index(after: nextIdx)
            } else {
                while str[nextIdx].isNumber {
                    nextIdx = str.index(after: nextIdx)
                }
                val = Int(str[idx..<nextIdx])!
            }
            return (.init(val: val, left: left, right: right), nextIdx)
        }

        private func reduce() {
            var shouldContinue = true
            while shouldContinue {
                shouldContinue = explodeIfNeeded() != nil || splitIfNeeded()
            }
        }

        private func explodeIfNeeded(_ level: Int = 0) -> (Int?, Int?)? {
            if val != nil { return nil }
            if level == 4 {
                let result = (left!.val!, right!.val!)
                val = 0
                left = nil
                right = nil
                return result
            }
            if let (l, r) = left!.explodeIfNeeded(level + 1) {
                if let r = r {
                    right!.addLeft(r)
                }
                return (l, nil)
            } else if let (l, r) = right!.explodeIfNeeded(level + 1) {
                if let l = l {
                    left!.addRight(l)
                }
                return (nil, r)
            } else {
                return nil
            }
        }

        private func addLeft(_ val: Int) {
            if self.val != nil {
                self.val! += val
            } else {
                left!.addLeft(val)
            }
        }

        private func addRight(_ val: Int) {
            if self.val != nil {
                self.val! += val
            } else {
                right!.addRight(val)
            }
        }

        private func splitIfNeeded() -> Bool {
            if let val = val {
                if val < 10 { return false }
                left = .init(val: val / 2, left: nil, right: nil)
                right = .init(val: val - left!.val!, left: nil, right: nil)
                self.val = nil
                return true
            }
            return left!.splitIfNeeded() || right!.splitIfNeeded()
        }

        func magnitude() -> Int {
            if let val = val { return val }
            return 3 * left!.magnitude() + 2 * right!.magnitude()
        }

        func copy() -> TreeNode {
            return TreeNode(val: val, left: left?.copy(), right: right?.copy())
        }

        static func +(_ lhs: TreeNode, _ rhs: TreeNode) -> TreeNode {
            let result = TreeNode(val: nil, left: lhs.copy(), right: rhs.copy())
            result.reduce()
            return result
        }
    }
}

func task18_1(_ input: TaskInput) {
    let nums = input.task18()
    let result = nums.dropFirst().reduce(nums.first!, +)
    print("T18_1: \(result.magnitude())")
}

func task18_2(_ input: TaskInput) {
    let nums = input.task18()
    var maxMagnitude = Int.min
    for (i1, n1) in nums.enumerated() {
        for (i2, n2) in nums.enumerated() {
            if i1 == i2 { continue }
            maxMagnitude = max(maxMagnitude, (n1 + n2).magnitude())
        }
    }
    print("T18_2: \(maxMagnitude)")
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
//
//    task10_1(input)
//    task10_2(input)
//
//    task11_1(input)
//    task11_2(input)
//
//    task12_1(input)
//    task12_2(input)
//
//    task13_1(input)
//    task13_2(input)
//
//    task14_1(input)
//    task14_2(input)
//
//    task15_1(input)
//    task15_2(input)
//
//    task16_1(input)
//    task16_2(input)
//
//    task17_1(input)
//    task17_2(input)

    task18_1(input)
    task18_2(input)
}
