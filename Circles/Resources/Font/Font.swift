//
//  Font.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 26/07/2025.
//

import Foundation
import SwiftUI

struct SatoshiFont {
    static func font(for textStyle: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        let size = sizeFor(textStyle: textStyle)
        return .custom("Satoshi Variable", size: size)  // Single font name for variable font
            .weight(weight)  // Apply the variable weight
    }
    
    // You can also create a version that accepts numeric weights
    static func font(for textStyle: Font.TextStyle, weight: CGFloat) -> Font {
        let size = sizeFor(textStyle: textStyle)
        return .custom("Satoshi Variable", size: size)
            .weight(Font.Weight(weight))
    }
    
    static func font(for textStyle: Font.TextStyle, size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .custom("Satoshi Variable", size: size)
            .weight(weight)
    }
    
    private static func sizeFor(textStyle: Font.TextStyle) -> CGFloat {
        switch textStyle {
        case .largeTitle: return 34
        case .title: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline: return 17
        case .body: return 17
        case .callout: return 16
        case .subheadline: return 15
        case .footnote: return 13
        case .caption: return 12
        case .caption2: return 11
        @unknown default: return 17
        }
    }
}

// Extensions for easy use
extension Font {
    static func satoshi(_ textStyle: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        SatoshiFont.font(for: textStyle, weight: weight)
    }
    
    // For precise weight control (100-900)
    static func satoshi(_ textStyle: Font.TextStyle, weight: CGFloat) -> Font {
        SatoshiFont.font(for: textStyle, weight: weight)
    }
    
    static func satoshi(_ textStyle: Font.TextStyle, size: CGFloat, weight: Font.Weight = .regular) -> Font {
        SatoshiFont.font(for: textStyle, size: size, weight: weight)
    }
    
    // Add this missing overload
    static func satoshi(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .custom("Satoshi Variable", size: size).weight(weight)
    }
}

extension Font.Weight {
    init(_ value: CGFloat) {
        switch value {
        case ...200: self = .ultraLight
        case 201...300: self = .light
        case 301...400: self = .regular
        case 401...500: self = .medium
        case 501...600: self = .semibold
        case 601...700: self = .bold
        case 701...800: self = .heavy
        case 801...: self = .black
        default: self = .regular
        }
    }
    
    // Get numeric value from Font.Weight
    var numericValue: CGFloat {
        switch self {
        case .ultraLight: return 100
        case .thin: return 200
        case .light: return 300
        case .regular: return 400
        case .medium: return 500
        case .semibold: return 600
        case .bold: return 700
        case .heavy: return 800
        case .black: return 900
        default: return 400
        }
    }
}


