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

// MARK: - Day 19

extension TaskInput {
    struct Point3D: Hashable {
        var x: Int
        var y: Int
        var z: Int
        var isScanner: Bool = false
    }
    func task19() -> [Set<Point3D>] {
        let lines = readInput("19").split(separator: "\n")
        var result = [Set<Point3D>]()
        var scaner = Set<Point3D>()
        for line in lines {
            if line.starts(with: "---") {
                result.append(scaner)
                scaner.removeAll()
                scaner.insert(Point3D(x: 0, y: 0, z: 0, isScanner: true))
            } else {
                let ints = line.split(separator: ",").map { Int($0)! }
                scaner.insert(.init(x: ints[0], y: ints[1], z: ints[2]))
            }
        }
        result.append(scaner)
        return Array(result.dropFirst())
    }
}

extension Set where Element == TaskInput.Point3D {
    private static let maps: [(Int, Int, Int) -> (Int, Int, Int)] = [
        { (x, y, z) in (x, y, z) },
        { (x, y, z) in (x, z, -y) },
        { (x, y, z) in (x, -y, -z) },
        { (x, y, z) in (x, -z, y) },

        { (x, y, z) in (-x, y, z) },
        { (x, y, z) in (-x, z, -y) },
        { (x, y, z) in (-x, -y, -z) },
        { (x, y, z) in (-x, -z, y) },

        { (x, y, z) in (-z, y, x) },
        { (x, y, z) in (-x, y, -z) },
        { (x, y, z) in (z, y, -x) },

        { (x, y, z) in (x, -y, z) },
        { (x, y, z) in (-z, -y, x) },
        { (x, y, z) in (-x, -y, -z) },
        { (x, y, z) in (z, -y, -x) },

        { (x, y, z) in (-y, x, z) },
        { (x, y, z) in (-x, -y, z) },
        { (x, y, z) in (-y, x, z) },

        { (x, y, z) in (x, y, -z) },
        { (x, y, z) in (-y, x, -z) },
        { (x, y, z) in (-x, -y, -z) },
        { (x, y, z) in (-y, x, -z) },
    ]

    func rotations() -> [Set<TaskInput.Point3D>] {
        Self.maps.map { m -> Set<TaskInput.Point3D> in
            Set(self.map { p -> TaskInput.Point3D in
                let (x, y, z) = m(p.x, p.y, p.z)
                return TaskInput.Point3D(x: x, y: y, z: z, isScanner: p.isScanner)
            })
        }
    }

    func transpose(_ point: TaskInput.Point3D) -> Set<TaskInput.Point3D> {
        Set(self.map { p in .init(x: p.x - point.x, y: p.y - point.y, z: p.z - point.z, isScanner: p.isScanner) })
    }

    func allVariants() -> [Set<TaskInput.Point3D>] {
        rotations().flatMap { r in r.map { r.transpose($0) } }
    }
}

enum T19 {
    static func match(_ scanners: [Set<TaskInput.Point3D>]) -> (Int, Int, Set<TaskInput.Point3D>) {
        let allVariants = scanners.enumerated()
            .flatMap { (idx, s) in s.allVariants().map { (idx, $0) } }
            .shuffled()
        for (idx1, s1) in allVariants {
            for (idx2, s2) in allVariants {
                guard idx2 > idx1 else { continue }
                if s1.intersection(s2).count >= 12 {
                    return (idx1, idx2, s1.union(s2))
                }
            }
        }
        fatalError()
    }
}

func task19_1(_ input: TaskInput) {
    var scanners = input.task19()
    while scanners.count != 1 {
        let (i1, i2, ns) = T19.match(scanners)
        scanners.remove(at: i1)
        scanners[i2 - 1] = ns
    }
    print("T19_1: \(scanners.first!.filter { $0.isScanner == false }.count)")

    let sPoints = scanners.first!.filter { $0.isScanner }
    var maxDist = Int.min
    for (idx, p1) in sPoints.enumerated() {
        for p2 in sPoints.dropFirst(idx + 1) {
            maxDist = max(maxDist, abs(p1.x - p2.x) + abs(p1.y - p2.y) + abs(p1.z - p2.z))
        }
    }
    print("T19_2: \(maxDist)")
}

func task19_2(_ input: TaskInput) {
    // In _1
}

// MARK: - Day 20

extension TaskInput {
    func task20() -> ([Bool], [[Bool]]) {
        let lines = readInput("20").split(separator: "\n")
        let alg = lines.first!.map { $0 == "#" }
        let img = lines.dropFirst().map { l in l.map { $0 == "#" } }
        return (alg, img)
    }
}

enum T20 {
    static func processStep(_ img: [[Bool]], alg: [Bool], step: Int) -> [[Bool]] {
        let (h, w) = (img.count, img.first!.count)
        var result = [[Bool]](repeating: [Bool](repeating: false, count: w + 2), count: h + 2)
        for y in 0..<(h + 2) {
            for x in 0..<(w + 2) {
                var val = 0
                for dy in -1...1 {
                    for dx in -1...1 {
                        let (px, py) = (x + dx - 1, y + dy - 1)
                        val <<= 1
                        if 0 <= px && px < w && 0 <= py && py < h {
                            val += img[py][px] ? 1 : 0
                        } else {
                            val += (step % 2 == 0) ? 0 : (alg[0] ? 1 : 0)
                        }
                    }
                }
                result[y][x] = alg[val]
            }
        }
        return result
    }
}

func task20_1(_ input: TaskInput) {
    let (alg, img) = input.task20()
    var result = img
    for idx in 0..<2 {
        result = T20.processStep(result, alg: alg, step: idx)
    }
//    print(result.map { l in l.map { $0 ? "#" : "." }.joined()}.joined(separator: "\n"))
    let count = result.flatMap { l in l.map { $0 ? 1 : 0 } }.reduce(0, +)
    print("T20_1: \(count)")
}

func task20_2(_ input: TaskInput) {
    let (alg, img) = input.task20()
    var result = img
    for idx in 0..<50 {
        result = T20.processStep(result, alg: alg, step: idx)
    }
    let count = result.flatMap { l in l.map { $0 ? 1 : 0 } }.reduce(0, +)
    print("T20_2: \(count)")
}

// MARK: - Day 21

extension TaskInput {
    func task21() -> (Int, Int) {
        let p = readInput("21").split(separator: "\n").map { l in Int(l.split(separator: " ").last!)! }
        return (p[0], p[1])
    }
}

enum T21 {
}

func task21_1(_ input: TaskInput) {
    var (a, b) = input.task21()
    (a, b) = (a - 1, b - 1)
    var roll = 1
    var (sA, sB) = (0, 0)
    var count = 0
    while max(sA, sB) < 1000 {
        for _ in 0..<3 {
            a = (a + roll) % 10
            if roll == 100 { roll = 1 } else { roll += 1 }
            count += 1
        }
        sA += (a + 1)
        (a, b) = (b, a)
        (sA, sB) = (sB, sA)
    }
    let other = min(sA, sB)
    print("T21_1: \(count), \(other) -> \(count * other)")
}

func task21_2(_ input: TaskInput) {
    let (a, b) = input.task21()

    struct State: Hashable {
        var a: Int
        var b: Int
        var sA: Int = 0
        var sB: Int = 0
        var turnA: Bool = true
    }

    let winScore = 21
    var cache = [State: (Int, Int)]()
    func solve(_ state: State) -> (Int, Int) {
        if state.sA >= winScore { return (1, 0) }
        if state.sB >= winScore { return (0, 1) }
        if let result = cache[state] { return result }

        var (wA, wB) = (0, 0)
        for r1 in 1...3 {
            for r2 in 1...3 {
                for r3 in 1...3 {
                    var state = state
                    if state.turnA {
                        state.a = (state.a + r1 + r2 + r3) % 10
                        state.sA += (state.a + 1)
                    } else {
                        state.b = (state.b + r1 + r2 + r3) % 10
                        state.sB += (state.b + 1)
                    }
                    state.turnA.toggle()
                    let (rA, rB) = solve(state)
                    wA += rA
                    wB += rB
                }
            }
        }

        cache[state] = (wA, wB)
        return (wA, wB)
    }

    let (wA, wB) = solve(.init(a: a - 1, b: b - 1))
    print("T21_2: \(wA), \(wB) -> \(max(wA, wB))")
}

// MARK: - Day 22

extension TaskInput {
    func task22() -> [(Bool, T22.RebootStep)] {
        readInput("22").split(separator: "\n").map { l in
            let p1 = l.split(separator: " ")
            let isOn = p1[0] == "on"
            let coords = p1[1].split(separator: ",").map { c in c.dropFirst(2).split(separator: ".").map { Int($0)! } }
            return (isOn, T22.RebootStep(
                x: coords[0][0]...coords[0][1],
                y: coords[1][0]...coords[1][1],
                z: coords[2][0]...coords[2][1]
            ))
        }
    }
}

enum T22 {
    struct RebootStep {
        var x: ClosedRange<Int>
        var y: ClosedRange<Int>
        var z: ClosedRange<Int>
    }
}

extension ClosedRange where Bound == Int {
    func split(_ other: Self) -> [Self] {
        if lowerBound > other.upperBound || upperBound < other.lowerBound {
            return []
        }
        if other.lowerBound <= lowerBound && upperBound <= other.upperBound {
            return [self]
        }
        if lowerBound < other.lowerBound && upperBound > other.upperBound {
            return [lowerBound...(other.lowerBound - 1), other, (other.upperBound + 1)...upperBound]
        }
        if other.lowerBound <= lowerBound  {
            return [lowerBound...other.upperBound, (other.upperBound + 1)...upperBound]
        } else {
            return [lowerBound...(other.lowerBound - 1), other.lowerBound...upperBound]
        }
    }
}

extension T22.RebootStep {
    func intersects(_ other: T22.RebootStep) -> Bool {
        x.overlaps(other.x) && y.overlaps(other.y) && z.overlaps(other.z)
    }

    func removing(_ other: T22.RebootStep) -> [T22.RebootStep] {
        let xInts = x.split(other.x)
        let yInts = y.split(other.y)
        let zInts = z.split(other.z)
        guard xInts.isEmpty == false && yInts.isEmpty == false && zInts.isEmpty == false
        else {
            return [self]
        }

        var result = [T22.RebootStep]()
        for xInt in xInts {
            for yInt in yInts {
                for zInt in zInts {
                    result.append(.init(x: xInt, y: yInt, z: zInt))
                }
            }
        }
        return result.filter { $0.intersects(other) == false }
    }

    var count: Int { x.count * y.count * z.count }
}

extension T22 {
    static func processSteps(_ steps: [(Bool, RebootStep)]) -> [RebootStep] {
        var onRegions = [RebootStep]()
        for (isOn, step) in steps {
            var nextOn = [RebootStep]()
            for region in onRegions {
                nextOn.append(contentsOf: region.removing(step))
            }
            if isOn {
                nextOn.append(step)
            }
            onRegions = nextOn
        }
        return onRegions
    }
}

func task22_1(_ input: TaskInput) {
    let steps = input.task22()
    let size = 50
    let onRegions = T22.processSteps(steps + [
        (false, T22.RebootStep(x: Int.min...(-size - 1), y: Int.min...Int.max, z: Int.min...Int.max)),
        (false, T22.RebootStep(x: (size + 1)...Int.max, y: Int.min...Int.max, z: Int.min...Int.max)),
        (false, T22.RebootStep(x: Int.min...Int.max, y: Int.min...(-size - 1), z: Int.min...Int.max)),
        (false, T22.RebootStep(x: Int.min...Int.max, y: (size + 1)...Int.max, z: Int.min...Int.max)),
        (false, T22.RebootStep(x: Int.min...Int.max, y: Int.min...Int.max, z: Int.min...(-size - 1))),
        (false, T22.RebootStep(x: Int.min...Int.max, y: Int.min...Int.max, z: (size + 1)...Int.max)),
    ])
    let count = onRegions.map(\.count).reduce(0, +)
    print("T22_1: \(count)")
}

func task22_2(_ input: TaskInput) {
    let steps = input.task22()
    let onRegions = T22.processSteps(steps)
    let count = onRegions.map(\.count).reduce(0, +)
    print("T22_2: \(count)")
}

// MARK: - Day 23

extension TaskInput {
    func task23() -> [TaskInput.Point: Int] {
        let lines = readInput("23").split(separator: "\n").dropFirst(2).dropLast()
        let aLetter = Int("A".first!.asciiValue!)
        return Dictionary(uniqueKeysWithValues: lines.enumerated().flatMap { (y, l) -> [(TaskInput.Point, Int)] in
            l.split(separator: "#").filter { $0.count == 1 }.enumerated().map { (x, g) -> (TaskInput.Point, Int) in
                (TaskInput.Point(x: 2 + x * 2, y: y + 1), (Int(g.first!.asciiValue!) - aLetter) * 2 + 2)
            }
        })
    }
}

enum T23 {
}

func task23_1(_ input: TaskInput) {
    let pods = input.task23()

    var cache = [[TaskInput.Point: Int]:Int]()
    let mult: [Int: Int] = [2: 1, 4: 10, 6: 100, 8: 1000]

    func solve(pods: [TaskInput.Point: Int]) -> Int {
        if pods.allSatisfy({ $0.key.x == $0.value }) { return 0 }
        if let score = cache[pods] { return score }

        var minScore = Int.max

//        var viz = [[String]](repeating: [String](repeating: "#", count: 13), count: 5)
//        for x in 1...11 {
//            viz[1][x] = "."
//        }
//        for x in [3,5,7,9] {
//            viz[2][x] = "."
//            viz[3][x] = "."
//        }
//        for (pos, dest) in pods {
//            viz[pos.y + 1][pos.x + 1] = [2: "A", 4: "B", 6: "C", 8: "D"][dest]!
//        }
//        print(viz.map { $0.joined() }.joined(separator: "\n"))
//        print("")

        func tryMove(pos: TaskInput.Point, dest: Int, nextPos: TaskInput.Point) {
            var nextPods = pods
            nextPods[pos] = nil
            nextPods[nextPos] = dest
            let nextScore = solve(pods: nextPods)
            if nextScore != Int.max {
                let score = nextScore + mult[dest]! * (abs(pos.x - nextPos.x) + abs(pos.y - nextPos.y))
                minScore = min(minScore, score)
            }
        }

        for (pos, dest) in pods {
            if pos.x == dest && (pos.y == 2 || pods[.init(x: dest, y: 2)] == dest) { continue }
            if pos.y == 0 {
                var possible = true
                for x in min(pos.x, dest)...max(pos.x, dest) {
                    if x == pos.x { continue }
                    if pods[.init(x: x, y: 0)] != nil {
                        possible = false
                        break
                    }
                }
                if possible {
                    let p2 = pods[.init(x: dest, y: 2)]
                    if p2 == nil {
                        tryMove(pos: pos, dest: dest, nextPos: .init(x: dest, y: 2))
                    } else if pods[.init(x: dest, y: 1)] == nil && p2 == dest {
                        tryMove(pos: pos, dest: dest, nextPos: .init(x: dest, y: 1))
                    }
                }
            } else if pos.y == 1 || (pos.y == 2 && pods[.init(x: pos.x, y: 1)] == nil) {
                for nextX in [0, 1, 3, 5, 7, 9, 10] {
                    var possible = true
                    for x in min(pos.x, nextX)...max(pos.x, nextX) {
                        if x == pos.x { continue }
                        if pods[.init(x: x, y: 0)] != nil {
                            possible = false
                            break
                        }
                    }
                    if possible {
                        tryMove(pos: pos, dest: dest, nextPos: .init(x: nextX, y: 0))
                    }
                }
            }
        }

        cache[pods] = minScore
        return minScore
    }

    let score = solve(pods: pods)
    print("T23_1: \(score)")
}

func task23_2(_ input: TaskInput) {
    var pods = input.task23()
    for x in [2,4,6,8] {
        let dest = pods[.init(x: x, y: 2)]
        pods[.init(x: x, y: 2)] = nil
        pods[.init(x: x, y: 4)] = dest
    }
    pods[.init(x: 2, y: 2)] = 8
    pods[.init(x: 2, y: 3)] = 8
    pods[.init(x: 4, y: 2)] = 6
    pods[.init(x: 4, y: 3)] = 4
    pods[.init(x: 6, y: 2)] = 4
    pods[.init(x: 6, y: 3)] = 2
    pods[.init(x: 8, y: 2)] = 2
    pods[.init(x: 8, y: 3)] = 6

    var cache = [[TaskInput.Point: Int]:Int]()
    let mult: [Int: Int] = [2: 1, 4: 10, 6: 100, 8: 1000]

    func solve(pods: [TaskInput.Point: Int], depth: Int = 0) -> Int {
        if pods.allSatisfy({ $0.key.x == $0.value }) { return 0 }
        if let score = cache[pods] { return score }

        var minScore = Int.max
        cache[pods] = minScore

//        var viz = [[String]](repeating: [String](repeating: "#", count: 13), count: 7)
//        for x in 1...11 {
//            viz[1][x] = "."
//        }
//        for x in [3,5,7,9] {
//            viz[2][x] = "."
//            viz[3][x] = "."
//            viz[4][x] = "."
//            viz[5][x] = "."
//        }
//        for (pos, dest) in pods {
//            viz[pos.y + 1][pos.x + 1] = [2: "A", 4: "B", 6: "C", 8: "D"][dest]!
//        }
//        print(viz.map { $0.joined() }.joined(separator: "\n"))
//        print("")

        func tryMove(pos: TaskInput.Point, dest: Int, nextPos: TaskInput.Point) {
            var nextPods = pods
            nextPods[pos] = nil
            nextPods[nextPos] = dest
            let nextScore = solve(pods: nextPods, depth: depth + 1)
            if nextScore != Int.max {
                let score = nextScore + mult[dest]! * (abs(pos.x - nextPos.x) + abs(pos.y - nextPos.y))
                minScore = min(minScore, score)
            }
        }

        for (pos, dest) in pods {
            if pos.x == dest && (pos.y...4).allSatisfy({ pods[.init(x: dest, y: $0)] == dest }) { continue }
            if pos.y == 0 {
                var possible = true
                for x in min(pos.x, dest)...max(pos.x, dest) {
                    if x == pos.x { continue }
                    if pods[.init(x: x, y: 0)] != nil {
                        possible = false
                        break
                    }
                }
                if possible {
                    for y in (1...4).reversed() {
                        let val = pods[.init(x: dest, y: y)]
                        if val == nil {
                            tryMove(pos: pos, dest: dest, nextPos: .init(x: dest, y: y))
                            break
                        } else if val != dest {
                            break
                        }
                    }
                }
            } else if pos.y == 1 || (1..<pos.y).allSatisfy({ pods[.init(x: pos.x, y: $0)] == nil }) {
                for nextX in [0, 1, 3, 5, 7, 9, 10] {
                    var possible = true
                    for x in min(pos.x, nextX)...max(pos.x, nextX) {
                        if x == pos.x { continue }
                        if pods[.init(x: x, y: 0)] != nil {
                            possible = false
                            break
                        }
                    }
                    if possible {
                        tryMove(pos: pos, dest: dest, nextPos: .init(x: nextX, y: 0))
                    }
                }
            }
        }

        cache[pods] = minScore
        return minScore
    }

    let score = solve(pods: pods)
    print("T23_2: \(score)")
}

// MARK: - Day 23

extension TaskInput {
    private static let wCharIdx = "w".first!.asciiValue!

    func task24() -> [T24.Op] {
        readInput("24").split(separator: "\n").map { l in
            let parts = l.split(separator: " ")
            var rhs: T24.Lit?
            if parts.count == 3 {
                if parts[2].first!.isLetter {
                    rhs = .var(Int(parts[2].first!.asciiValue! - Self.wCharIdx))
                } else {
                    rhs = .num(Int(parts[2])!)
                }
            }
            let lhs = Int(parts[1].first!.asciiValue! - Self.wCharIdx)
            switch parts[0] {
            case "inp":
                return .inp(lhs)
            case "add":
                return .add(lhs, rhs!)
            case "mul":
                return .mul(lhs, rhs!)
            case "div":
                return .div(lhs, rhs!)
            case "mod":
                return .mod(lhs, rhs!)
            case "eql":
                return .eql(lhs, rhs!)
            default:
                fatalError()
            }
        }
    }
}

enum T24 {
    typealias Var = Int
    enum Lit {
        case `var`(Var)
        case num(Int)
    }
    enum Op {
        case inp(Var)
        case add(Var, Lit)
        case mul(Var, Lit)
        case div(Var, Lit)
        case mod(Var, Lit)
        case eql(Var, Lit)
    }
}

extension T24.Op {
    var isInp: Bool {
        if case .inp = self { return true }
        return false
    }

    var lhs: T24.Var {
        switch self {
        case .inp(let v), .add(let v, _), .mul(let v, _), .div(let v, _), .mod(let v, _), .eql(let v, _):
            return v
        }
    }

    var rhs: T24.Lit {
        switch self {
        case .inp:
            return .num(0) // noop
        case .add(_, let l), .mul(_, let l), .div(_, let l), .mod(_, let l), .eql(_, let l):
            return l
        }
    }
}

extension T24 {
    struct State: Hashable {
        var idx: Int
        var d1: Int
        var d2: Int
        var d3: Int
    }

    static func stringify(ops: [Op]) -> String {
        let prefix = ["{ (inp: Int, d1: inout Int, d2: inout Int, d3: inout Int) -> Void in"]
        let postfix = ["},"]

        var result = [String]()
        for op in ops {
            let lhs = "d\(op.lhs)"
            let rhs: String
            switch op.rhs {
            case .num(let val):
                rhs = "\(val)"
            case .var(let idx):
                rhs = idx == 0 ? "inp" : "d\(idx)"
            }
            switch op {
            case .inp:
                result.append(contentsOf: postfix + prefix)
            case .add:
                result.append("    \(lhs) += \(rhs)")
            case .mul:
                result.append("    \(lhs) *= \(rhs)")
            case .div:
                result.append("    \(lhs) /= \(rhs)")
            case .mod:
                result.append("    \(lhs) %= \(rhs)")
            case .eql:
                result.append("    \(lhs) = (\(lhs) == \(rhs)) ? 1 : 0")
            }
        }
        if result.isEmpty { return "" }

        result.removeFirst(1)
        result.append(contentsOf: postfix)
        let content = result.map { "    \($0)" }.joined(separator: "\n")
        return """
static let processors: [(Int, inout Int, inout Int, inout Int) -> Void] = [
\(content)
]
"""
    }

    static let processors: [(Int, inout Int, inout Int, inout Int) -> Void] = []

    static func process(digits: [Int], cache: inout Set<State>) -> String {
        func solve(state: State) -> String? {
            guard state.idx < processors.count else { return state.d3 == 0 ? "" : nil }

            if cache.contains(state) { return nil }

            for val in digits {
                var state = state
                processors[state.idx](val, &state.d1, &state.d2, &state.d3)
                state.idx += 1
                if let result = solve(state: state) {
                    return "\(val)\(result)"
                }
            }

            cache.insert(state)
            return nil
        }
        return solve(state: .init(idx: 0, d1: 0, d2: 0, d3: 0))!
    }
    
}

func task24_1(_ input: TaskInput) {
    guard input.prefix != "sample" else {
        // No sample
        return
    }
    if T24.processors.count == 0 {
        let ops = input.task24()
        print(T24.stringify(ops: ops))
    } else {
        var cache = Set<T24.State>()
        let maxVal = T24.process(digits: (1...9).reversed(), cache: &cache)
        let minVal = T24.process(digits: Array(1...9), cache: &cache)
        print("T24_1: \(maxVal)")
        print("T24_2: \(minVal)")
    }
}

func task24_2(_ input: TaskInput) {
    // In _1
}

// MARK: - Main

let inputs = [
    TaskInput(prefix: "sample"),
    TaskInput(),
]

for input in inputs {
    print("Run for \(input.prefix)")
    let start = Date()
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
//
//    task18_1(input)
//    task18_2(input)
//
//    task19_1(input)
//    task19_2(input)
//
//    task20_1(input)
//    task20_2(input)
//
//    task21_1(input)
//    task21_2(input)
//
//    task22_1(input)
//    task22_2(input)
//
//    task23_1(input)
//    task23_2(input)

    task24_1(input)
    task24_2(input)

    print("Time: \(String(format: "%0.4f", -start.timeIntervalSinceNow))")
}
