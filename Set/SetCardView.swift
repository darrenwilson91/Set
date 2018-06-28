//
//  SetCardView.swift
//  Set
//
//  Created by Darren Wilson on 21/06/2018.
//  Copyright © 2018 Darren Wilson. All rights reserved.
//

import UIKit

class SetCardView: UIView {

    var symbol: CardSymbol = .squiggle

    //let cardBackColor: UIColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    var shading: CardShading = .fill
    var displayCardFace = false
    @IBInspectable
    var symbolCount: Int = 1
    @IBInspectable
    var symbolColor: UIColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    //var cardBackgroundColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var borderColor: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) {
        didSet {
            layer.borderColor = borderColor
        }
    }
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.borderWidth = 3
        
        if displayCardFace {
            drawCardSymbols()
        }
    }
    
    private func drawCardSymbols() {
        var symbols = [UIBezierPath]()
        
        switch symbolCount {
        case 1:
            symbols.append(buildSymbol(symbol: symbol, withCentre: CGPoint(x: bounds.midX, y: bounds.midY)))
        case 2:
            symbols.append(buildSymbol(symbol: symbol, withCentre: CGPoint(x: bounds.midX, y: bounds.midY - (symbolHeight / 2) - symbolSpacing / 2)))
            symbols.append(buildSymbol(symbol: symbol, withCentre: CGPoint(x: bounds.midX, y: bounds.midY + (symbolHeight / 2) + symbolSpacing / 2)))
        case 3:
            symbols.append(buildSymbol(symbol: symbol, withCentre: CGPoint(x: bounds.midX, y: bounds.midY - (symbolHeight) - symbolSpacing)))
            symbols.append(buildSymbol(symbol: symbol, withCentre: CGPoint(x: bounds.midX, y: bounds.midY)))
            symbols.append(buildSymbol(symbol: symbol, withCentre: CGPoint(x: bounds.midX, y: bounds.midY + (symbolHeight) + symbolSpacing)))
        default:
            symbols.append(buildSymbol(symbol: symbol, withCentre: CGPoint(x: bounds.midX, y: bounds.midY)))
        }
        
        switch shading {
        case .fill:
            for symbolToDraw in symbols {
                symbolToDraw.fill()
            }
        case .outline:
            for symbolToDraw in symbols {
                symbolToDraw.stroke()
            }
        case .hash:
            let conjoinedSymbol = UIBezierPath()
            
            for symbolToDraw in symbols {
                conjoinedSymbol.append(symbolToDraw)
            }
            
            conjoinedSymbol.stroke()
            conjoinedSymbol.addClip()
            
            let shading = UIBezierPath()
            shading.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
            for _ in 0...Int(bounds.width / 0.02) {
                shading.addLine(to: CGPoint(x: shading.currentPoint.x, y: bounds.maxY))
                shading.move(to: CGPoint(x: shading.currentPoint.x + (bounds.width * 0.02), y: bounds.minY))
            }
            
            shading.stroke()
        default:
            for symbolToDraw in symbols {
                symbolToDraw.fill()
            }
        }
        
    }
    
    private func buildSymbol(symbol: CardSymbol, withCentre centre: CGPoint) -> UIBezierPath{
        symbolColor.setStroke()
        symbolColor.setFill()
        
        let symbolToDraw: UIBezierPath
        
        switch symbol {
        case .diamond: symbolToDraw = buildDiamond(withCentre: centre)
        case .oblong: symbolToDraw = buildOblong(withCentre: centre)
        case .squiggle: symbolToDraw = buildSquiggle(withCentre: centre)
        default: symbolToDraw = buildDiamond(withCentre: centre)
        }
        
        return symbolToDraw
    }
    
    private func buildDiamond(withCentre centre: CGPoint) -> UIBezierPath {
        let diamond = UIBezierPath()
        diamond.move(to: CGPoint(x: centre.x, y: centre.y - (symbolHeight / 2)))
        diamond.addLine(to: CGPoint(x: centre.x + (symbolWidth / 2), y: centre.y))
        diamond.addLine(to: CGPoint(x: centre.x, y: centre.y + (symbolHeight / 2)))
        diamond.addLine(to: CGPoint(x: centre.x - (symbolWidth / 2), y: centre.y))
        diamond.close()
        
        return diamond
    }
    
    private func buildOblong(withCentre centre: CGPoint) -> UIBezierPath {
        let oblongArcRadius = symbolHeight / 2
        
        let oblong = UIBezierPath()
        oblong.move(to: CGPoint(x: centre.x - symbolWidth / 2 + oblongArcRadius, y: centre.y - (symbolHeight / 2)))
        oblong.addLine(to: CGPoint(x: centre.x + symbolWidth / 2 - oblongArcRadius, y: centre.y - (symbolHeight / 2)))
        oblong.addArc(withCenter: CGPoint(x: centre.x + symbolWidth / 2 - oblongArcRadius, y: centre.y), radius: oblongArcRadius, startAngle: (3 * CGFloat.pi) / 2, endAngle: CGFloat.pi / 2, clockwise: true)
        oblong.addLine(to: CGPoint(x: centre.x - symbolWidth / 2 + oblongArcRadius, y: centre.y + symbolHeight / 2))
        oblong.addArc(withCenter: CGPoint(x: centre.x - symbolWidth / 2 + oblongArcRadius, y: centre.y), radius: oblongArcRadius, startAngle: CGFloat.pi / 2, endAngle: (3 * CGFloat.pi) / 2, clockwise: true)
        
        oblong.close()
        
        return oblong
    }
    
    private func buildSquiggle(withCentre centre: CGPoint) -> UIBezierPath {
        let squiggle = UIBezierPath()
        squiggle.move(to: CGPoint(x: centre.x - (symbolWidth / 2), y: centre.y + (symbolHeight / 2)))
        squiggle.addCurve(to: CGPoint(x: centre.x + (symbolWidth / 2), y: centre.y - (symbolHeight / 2)), controlPoint1: CGPoint(x: centre.x - (symbolWidth / 6), y: centre.y - (symbolHeight * 1.5)), controlPoint2: CGPoint(x: centre.x + (symbolWidth / 6), y: centre.y + (symbolHeight / 2)))
        squiggle.addCurve(to: CGPoint(x: centre.x - (symbolWidth / 2), y: centre.y + (symbolHeight / 2)), controlPoint1: CGPoint(x: centre.x + (symbolWidth / 6), y: centre.y + (symbolHeight * 1.5)), controlPoint2: CGPoint(x: centre.x - (symbolWidth / 6), y: centre.y - (symbolHeight / 2)))
        squiggle.close()
        
        return squiggle
    }
    
    enum CardSymbol {
        case squiggle
        case diamond
        case oblong
        case unknown
    }
    
    enum CardShading {
        case outline
        case hash
        case fill
        case unknown
    }
}

extension SetCardView {
    private struct SizeRatio {
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let symbolWidthToBoundsWidth: CGFloat = 0.8
        static let symbolHeightToBoundsHeight: CGFloat = 0.2
        static let symbolSpacingForThreeSymbolsToHeight: CGFloat = 0.08
    }
    
    var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    
    var symbolWidth: CGFloat {
        return bounds.size.width * SizeRatio.symbolWidthToBoundsWidth
    }
    
    var symbolHeight: CGFloat {
        return bounds.size.height * SizeRatio.symbolHeightToBoundsHeight
    }
    
    var symbolSpacing: CGFloat {
        return bounds.size.height * SizeRatio.symbolSpacingForThreeSymbolsToHeight
    }
    
}
