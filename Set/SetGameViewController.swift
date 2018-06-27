//
//  SetGameViewController.swift
//  Set
//
//  Created by Darren Wilson on 17/06/2018.
//  Copyright © 2018 Darren Wilson. All rights reserved.
//

import UIKit

class SetGameViewController: UIViewController {
    
    var setGame = SetGame()
    var cardViewMap = [SetCardView: Card]() {
        didSet {
            for cardView in cardViewMap.keys.filter({!oldValue.keys.contains($0)}) {
                let cardTap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
                cardTap.numberOfTapsRequired = 1
                cardTap.numberOfTouchesRequired = 1
                cardView.addGestureRecognizer(cardTap)
                
                gridView.addCardView(cardView: cardView)
            }
            
            for removedCardView in oldValue.keys.filter({!cardViewMap.keys.contains($0)}) {
                gridView.removeCardView(cardView: removedCardView)
            }
            
        }
    }
    var theme = Theme.normal {
        didSet {
            updateViewFromModel()
        }
    }

    @IBOutlet weak var gridView: GridView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
            swipe.direction = .down
            gridView.addGestureRecognizer(swipe)
            
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))
            gridView.addGestureRecognizer(rotate)
        }
    }
    
    @IBOutlet weak var scoreLabel: UILabel! {
        didSet { scoreLabel.text = "Score: \(setGame.score)" }
    }
    @IBOutlet var cardViews: [SetCardView]! {
        didSet {
            //TODO: Probably assign multi touch listeners here
        }
    }
    @IBOutlet weak var dealThreeMoreButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*@IBAction func cardPressed(_ sender: UIButton) {
        if setGame.selectedCards.contains(cardButtonMap[sender]!) {
            setGame.deselectCard(card: cardButtonMap[sender]!)
        } else {
            setGame.selectCard(card: cardButtonMap[sender]!)
        }
        updateViewFromModel()
    }*/
    
    @IBAction func newGameButtonPressed(_ sender: UIButton) {
        setGame.startNewGame()
        cardViewMap.removeAll()
        updateViewFromModel()
    }
    
    @IBAction func dealThreeButtonPressed(_ sender: UIButton) {
        setGame.dealThreeMoreCards()
        updateViewFromModel()
    }
    
    private func updateViewFromModel() {
        if gridView != nil, scoreLabel != nil {
            // Remove any cardButtonMappings for Cards that have been removed from play
            cardViewMap = cardViewMap.filter { setGame.cardsInPlay.contains($0.value) }
            
            for card in setGame.cardsInPlay {
                if !cardViewMap.values.contains(card) {
                    cardViewMap[cardViewForCard(card: card)] = card
                }
            }
            
            if !setGame.cardsLeftInDeck {
                dealThreeMoreButton.isHidden = true
            } else {
                dealThreeMoreButton.isHidden = false
            }
            
            scoreLabel.text = "Score: \(setGame.score)"
            
            drawCardViews()
        }
    }
    
    func drawCardViews() {
        for cardView in cardViewMap.keys {
            let card = cardViewMap[cardView]!
            
            setCardViewProperties(cardView: cardView, card: card)
            
            let cardBorderColor: CGColor = setGame.selectedCards.contains(card) ? #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cardView.borderColor = cardBorderColor
            
            if setGame.cardIsPartOfValidSetSelection(card: card) {
                cardView.backgroundColor = #colorLiteral(red: 0.7570295457, green: 0.9813225865, blue: 0.8112249367, alpha: 1)
            } else if setGame.cardIsPartOfInvalidSetSelection(card: card) {
                cardView.backgroundColor = #colorLiteral(red: 0.9813225865, green: 0.6666741573, blue: 0.7235357409, alpha: 1)
            } else {
                cardView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
            
            cardView.setNeedsDisplay()
        }
        
        gridView.setNeedsLayout()
        gridView.setNeedsDisplay()
    }
    
    func setCardViewProperties(cardView: SetCardView, card: Card) {
        switch card.symbol {
        case 0:
            cardView.symbol = SetCardView.CardSymbol.diamond
        case 1:
            cardView.symbol = SetCardView.CardSymbol.oblong
        case 2:
            cardView.symbol = SetCardView.CardSymbol.squiggle
        default:
            cardView.symbol = SetCardView.CardSymbol.unknown
        }
        
        cardView.symbolCount = card.symbolCount
        
        switch card.shading {
        case 0:
            cardView.shading = SetCardView.CardShading.fill
        case 1:
            cardView.shading = SetCardView.CardShading.outline
        case 2:
            cardView.shading = SetCardView.CardShading.hash
        default:
            cardView.shading = SetCardView.CardShading.unknown
        }
        
        cardView.symbolColor = theme.cardColors[card.color]
        cardView.backgroundColor = theme.cardBackgroundColor
    }
    
    func cardViewForCard(card: Card) -> SetCardView {
        let cardView = SetCardView()
        
        setCardViewProperties(cardView: cardView, card: card)
        
        return cardView
    }
    
    @objc
    func handleCardTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended, let cardView = sender.view as? SetCardView {
            if let card = cardViewMap[cardView] {
                if !setGame.selectedCards.contains(card) {
                    setGame.selectCard(card: card)
                } else {
                    setGame.deselectCard(card: card)
                }
                
            }
        }
        
        updateViewFromModel()
    }
    
    @objc
    func handleSwipeDown(sender: UISwipeGestureRecognizer) {
        setGame.dealThreeMoreCards()
        updateViewFromModel()
    }
    
    @objc
    func handleRotation(sender: UIRotationGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.ended {
            let cardViewKeys = Array(cardViewMap.keys)
            
            if cardViewKeys.count >= 3 {
                for _ in 1...100 {
                    let firstRandomKey = cardViewKeys[cardViewKeys.count.arc4random]
                    let secondRandomKey = cardViewKeys[cardViewKeys.count.arc4random]
                    
                    if firstRandomKey != secondRandomKey {
                        let tempCard = cardViewMap[firstRandomKey]
                        
                        cardViewMap[firstRandomKey] = cardViewMap[secondRandomKey]
                        cardViewMap[secondRandomKey] = tempCard
                    }
                }
                
                updateViewFromModel()
                gridView.setNeedsDisplay()
                gridView.setNeedsLayout()
            }
        }
    }
    
    /*
    func drawCardButtons() {
        for cardButton in cardButtons {
            if let card = cardButtonMap[cardButton] {
                var cardSymbol = ""
                switch card.symbol {
                case 0:
                    cardSymbol = "▲"
                case 1:
                    cardSymbol = "●"
                case 2:
                    cardSymbol = "■"
                default:
                    cardSymbol = "?"
                }
                
                var cardString = ""
                for _ in 0..<card.symbolCount {
                    cardString = cardString + cardSymbol
                }
                
                var stringAttributes = [NSAttributedStringKey: Any]()
                
                var cardColor = theme.cardColors[card.color]
                
                switch card.shading {
                case 0:
                    cardColor = cardColor.withAlphaComponent(0.15)
                case 1:
                    stringAttributes[NSAttributedStringKey.strokeWidth] = 5
                case 2:
                    cardColor = cardColor.withAlphaComponent(1.0)
                default:
                    cardColor = cardColor.withAlphaComponent(1.0)
                }
                
                stringAttributes[NSAttributedStringKey.foregroundColor] = cardColor
                
                cardButton.setAttributedTitle(NSAttributedString(string: cardString, attributes: stringAttributes), for: UIControlState.normal)
                
                let buttonBorderColor: CGColor = setGame.selectedCards.contains(card) ? #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                cardButton.layer.borderColor = buttonBorderColor
                
                if setGame.cardIsPartOfValidSetSelection(card: card) {
                    cardButton.backgroundColor = #colorLiteral(red: 0.7570295457, green: 0.9813225865, blue: 0.8112249367, alpha: 1)
                } else if setGame.cardIsPartOfInvalidSetSelection(card: card) {
                    cardButton.backgroundColor = #colorLiteral(red: 0.9813225865, green: 0.6666741573, blue: 0.7235357409, alpha: 1)
                } else {
                    cardButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                }
                
                cardButton.isHidden = false
                
            } else {
                cardButton.isHidden = true
            }
        }
    }
 */
    
}

enum Theme {
    case normal
    case spooky
    
    var cardColors: [UIColor] {
        switch self {
        case .normal: return [#colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)]
        case .spooky: return [#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)]
        }
    }
    
    var cardBackgroundColor: UIColor {
        switch self {
        case .normal: return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .spooky: return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
}
