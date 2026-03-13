// Path: Shared/SeededRNG.swift
//Developer Chuong Nguyen

import Foundation

struct SeededRNG {
    private(set) var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0xA1B2C3D4E5F60789 : seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }

    mutating func nextInt(_ upperBound: Int) -> Int {
        guard upperBound > 0 else { return 0 }
        return Int(next() % UInt64(upperBound))
    }
}
