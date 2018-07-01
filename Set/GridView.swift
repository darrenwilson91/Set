//
//  GridView.swift
//  Set
//
//  Created by Darren Wilson on 21/06/2018.
//  Copyright © 2018 Darren Wilson. All rights reserved.
//

import UIKit

class GridView: UIView {
    
    lazy var grid = Grid(layout: Grid.Layout.aspectRatio(SizeRatio.cardAspectRatio), frame: frame)
    
    var cardViews = [SetCardView]() {
        didSet {
            grid.cellCount = cardViews.count
            
            for removedCardView in oldValue.filter({ !cardViews.contains($0) }) {
                removedCardView.removeFromSuperview()
            }
            
            for newCardView in cardViews.filter({ !oldValue.contains($0) }) {
                newCardView.contentMode = UIViewContentMode.redraw
                //addSubview(newCardView)
            }
            
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    func frameForCardView(cardView: SetCardView) -> CGRect? {
        if let indexOfCardView = cardViews.index(of: cardView), let cardViewBounds = grid[indexOfCardView] {
            return CGRect(x: cardViewBounds.origin.x,
                          y: cardViewBounds.origin.y,
                          width: cardViewBounds.width - horizontalMarginWidth,
                          height: cardViewBounds.height - verticalMarginHeight)
        }
        
        return nil
    }
    
    func addCardView(cardView: SetCardView) {
        cardViews.append(cardView)
    }
    
    func removeCardView(cardView: SetCardView) {
        if let indexOfCardToBeRemoved = cardViews.index(of: cardView) {
            cardViews.remove(at: indexOfCardToBeRemoved)
        }
    }
    
    func updateGridPositions() {
        grid.frame = frame
    }

}

extension GridView {
    private struct SizeRatio {
        static let horizontalMarginToWidth: CGFloat = 0.05
        static let verticalMarginToHeight: CGFloat = 0.05
        static let cardAspectRatio: CGFloat = 0.7143
    }
    
    var horizontalMarginWidth: CGFloat
    {
        return grid.cellSize.width * SizeRatio.horizontalMarginToWidth
    }
    
    var verticalMarginHeight: CGFloat {
        return grid.cellSize.height * SizeRatio.verticalMarginToHeight
    }
}
