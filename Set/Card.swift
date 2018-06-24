//
//  Card.swift
//  Set
//
//  Created by Darren Wilson on 17/06/2018.
//  Copyright © 2018 Darren Wilson. All rights reserved.
//

import Foundation

struct Card: Hashable {
    
    let symbol: Int
    let symbolCount: Int
    let shading: Int
    let color: Int
    let partOfASet = false
    
    init(symbol: Int, symbolCount: Int, shading: Int, color: Int) {
        self.symbol = symbol
        self.symbolCount = symbolCount
        self.shading = shading
        self.color = color
    }
    
    var hashValue: Int {
        return (symbol * 10) + (symbolCount * 100) + (shading * 1000) + (color * 10000)
    }
    
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
