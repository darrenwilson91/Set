//
//  Set.swift
//  Set
//
//  Created by Darren Wilson on 17/06/2018.
//  Copyright © 2018 Darren Wilson. All rights reserved.
//

import Foundation

class SetGame {
    private(set) var cardsInPlay = [Card]()
    private var cardDeck = [Card]()
    private(set) var score = 0
    private(set) var selectedCards = [Card]()
    private(set) var matchedCards = [Card]()
    
    private var completeShuffledCardDeck: [Card] {
        var deck = [Card]()
        for symbol in 0..<3 {
            for multiple in 1...3 {
                for shading in 0..<3 {
                    for color in 0..<3 {
                        deck.append(Card(symbol: symbol, symbolCount: multiple, shading: shading, color: color))
                    }
                }
            }
        }
        
        return deck.sorted{ _, _ in arc4random_uniform(2) == 0}
    }
    
    init() {
        startNewGame()
    }
    
    func startNewGame() {
        cardsInPlay = []
        selectedCards = []
        cardDeck = completeShuffledCardDeck
        dealCards(numberOfCards: 12)
        score = 0
    }
    
    private func dealCards(numberOfCards: Int) {
        if selectedCardsAreASet {
            cardsInPlay = cardsInPlay.filter { !selectedCards.contains($0) }
            
            matchedCards.append(contentsOf: selectedCards)
            selectedCards.removeAll()
        }
        
        for _ in 0..<numberOfCards {
            if let card = cardDeck.popLast() {
                cardsInPlay.append(card)
            }
        }
    }
    
    func dealThreeMoreCards() {
        dealCards(numberOfCards: 3)
    }
    
    func selectCard(card: Card) {
        if cardsInPlay.contains(card) && !selectedCards.contains(card)  {
            if selectedCards.count < 3 {
                selectedCards.append(card)
            } else if selectedCards.count == 3 && selectedCardsAreASet {
                dealThreeMoreCards()
                selectedCards.append(card)
            } else if selectedCards.count == 3 && !selectedCardsAreASet {
                deselectAllCards()
                selectedCards.append(card)
            }
            
            calculateScoreForSelectedCards()
        }
    }
    
    func deselectCard(card: Card) {
        if selectedCards.count > 0 {
            selectedCards = selectedCards.filter { $0 != card }
        }
    }
    
    func deselectAllCards() {
        for selectedCard in selectedCards {
            deselectCard(card: selectedCard)
        }
    }
    
    func cardIsPartOfValidSetSelection(card: Card) -> Bool {
        return selectedCardsAreASet && selectedCards.contains(card) ? true : false
    }
    
    func cardIsPartOfInvalidSetSelection(card: Card) -> Bool {
        return !selectedCardsAreASet && selectedCards.count == 3 && selectedCards.contains(card) ? true : false
    }
    
    func cardIsSelected(card: Card) -> Bool {
        return selectedCards.contains(card)
    }
    
    private func calculateScoreForSelectedCards() {
        if selectedCards.count == 3 {
            if selectedCardsAreASet {
                score = score + 5
            } else {
                score = score - 1
            }
        }
    }
    
    var cardsLeftInDeck: Bool {
        return cardDeck.count != 0
    }
    
    var selectedCardsAreASet: Bool {
        if selectedCards.count != 3 {
            return false
        }
        
        let uniqueOrIdentical = {(n0: Int, n1: Int, n2: Int) -> Bool in (n0==n1 && n0==n2 && n1==n2) || (n0 != n1 && n0 != n2 && n1 != n2)}
        
        let colors = [selectedCards[0].color, selectedCards[1].color, selectedCards[2].color]
        let shadings = [selectedCards[0].shading, selectedCards[1].shading, selectedCards[2].shading]
        let symbols = [selectedCards[0].symbol, selectedCards[1].symbol, selectedCards[2].symbol]
        let symbolCounts = [selectedCards[0].symbolCount, selectedCards[1].symbolCount, selectedCards[2].symbolCount]
        
        if colors.checkConditionOnThreeElements(functionToRun: uniqueOrIdentical) &&
            shadings.checkConditionOnThreeElements(functionToRun: uniqueOrIdentical) &&
            symbols.checkConditionOnThreeElements(functionToRun: uniqueOrIdentical) &&
            symbolCounts.checkConditionOnThreeElements(functionToRun: uniqueOrIdentical) {
            return true
        } else {
            return false
        }
    }
}

extension Int {
    var arc4random: Int {
        return Int(arc4random_uniform(UInt32(self)))
    }
}

extension Array where Element == Int {
    func checkConditionOnThreeElements(functionToRun: ((Int, Int, Int) -> Bool)) -> Bool {
        return functionToRun(self[0], self[1], self[2])
    }
}
