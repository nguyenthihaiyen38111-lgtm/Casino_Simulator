// Path: Shared/SlotMath.swift

import Foundation
import UIKit

enum SlotSymbol: CaseIterable, Codable, Hashable {
    case strawberry, cherry, watermelon, grape, bell, three

    var imageName: String {
        switch self {
        case .strawberry: return "strawberry"
        case .cherry: return "cherry"
        case .watermelon: return "watermelon"
        case .grape: return "grape"
        case .bell: return "bell"
        case .three: return "three"
        }
    }
                                        
    static let availableCases: [SlotSymbol] = {
        let all = SlotSymbol.allCases
        let available = all.filter { UIImage(named: $0.imageName) != nil }
        return available.isEmpty ? all : available
    }()

    static func safeDefaultWindow(rows: Int) -> [SlotSymbol] {
        let pool = availableCases
        return (0..<max(1, rows)).map { _ in pool.randomElement() ?? .watermelon }
    }
}

enum SlotMath {
    struct Rolled: Equatable {
        let multiplier: Double
        let payout: Int
        let net: Int
        let finalWindow: [SlotSymbol]
        let winRow: Int?
    }

    static func rollOutcome(bet: Int, rows: Int = 4) -> Rolled {
        let r = max(1, rows)
        let outcome = pickWeightedOutcome()

        let winRow: Int? = {
            switch outcome.kind {
            case .x50, .x10, .x3:
                return Int.random(in: 0..<r)
            case .smallWin, .breakEven:
                return Int.random(in: 0..<r)
            case .smallLoss, .none:
                return nil
            }
        }()

        let window = buildFinalWindow(rows: r, outcome: outcome, winRow: winRow)
        let payout = max(0, Int((Double(bet) * outcome.multiplier).rounded()))
        return Rolled(multiplier: outcome.multiplier, payout: payout, net: payout - bet, finalWindow: window, winRow: winRow)
    }

    private struct Outcome {
        let multiplier: Double
        let kind: Kind

        enum Kind { case none, smallLoss, breakEven, smallWin, x3, x10, x50 }
    }

    // БОЛЬШЕ бонусов/выигрышей:
    // x50: 1% | x10: 4% | x3: 15% | smallWin: 25% | breakEven: 15% | smallLoss: 20% | none: 20%
    private static func pickWeightedOutcome() -> Outcome {
        let r = Int.random(in: 0..<10_000)
        switch r {
        case 0..<100:
            return Outcome(multiplier: 50.0, kind: .x50)
        case 100..<500:
            return Outcome(multiplier: 10.0, kind: .x10)
        case 500..<2_000:
            return Outcome(multiplier: 3.0, kind: .x3)
        case 2_000..<4_500:
            return Outcome(multiplier: 1.6, kind: .smallWin)
        case 4_500..<6_000:
            return Outcome(multiplier: 1.0, kind: .breakEven)
        case 6_000..<8_000:
            return Outcome(multiplier: 0.5, kind: .smallLoss)
        default:
            return Outcome(multiplier: 0.0, kind: .none)
        }
    }

    private static func buildFinalWindow(rows: Int, outcome: Outcome, winRow: Int?) -> [SlotSymbol] {
        let r = max(1, rows)
        var window = SlotSymbol.safeDefaultWindow(rows: r * 3)

        let pool = SlotSymbol.availableCases
        let fruitPool = pool.filter { $0 != .three && $0 != .bell }
        let anyFruit = fruitPool.randomElement() ?? (pool.randomElement() ?? .watermelon)

        func setRow(_ row: Int, _ a: SlotSymbol, _ b: SlotSymbol, _ c: SlotSymbol) {
            let rr = min(max(0, row), r - 1)
            window[(0 * r) + rr] = a
            window[(1 * r) + rr] = b
            window[(2 * r) + rr] = c
        }

        guard let row = winRow else { return window }

        switch outcome.kind {
        case .x50:
            setRow(row, .three, .three, .three)

        case .x10:
            setRow(row, .bell, .bell, .bell)

        case .x3:
            let sym = fruitPool.randomElement() ?? anyFruit
            setRow(row, sym, sym, sym)

        case .smallWin:
            let sym = fruitPool.randomElement() ?? anyFruit
            let other = (fruitPool.filter { $0 != sym }.randomElement()) ?? anyFruit
            if Bool.random() {
                setRow(row, sym, sym, other)
            } else {
                setRow(row, sym, other, sym)
            }

        case .breakEven:
            let a = fruitPool.randomElement() ?? anyFruit
            let b = (fruitPool.filter { $0 != a }.randomElement()) ?? anyFruit
            let c = (fruitPool.filter { $0 != a && $0 != b }.randomElement()) ?? b
            setRow(row, a, b, c)

        case .smallLoss, .none:
            break
        }

        return window
    }
}
