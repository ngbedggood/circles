//
//  MoodCircles.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 07/08/2025.
//

import Foundation
import SwiftUI

let moodCircles: [MoodCircle] = [
    .init(
        color: .gray, fill: .gray, offsetY: 240, expandedSize: 120, defaultSize: 80, index: 4),
    .init(
        color: .orange, fill: .orange, offsetY: 110, expandedSize: 100, defaultSize: 80,
        index: 3),
    .init(
        color: .yellow, fill: .yellow, offsetY: 0, expandedSize: 80, defaultSize: 80, index: 2),
    .init(
        color: .green, fill: .green, offsetY: -110, expandedSize: 100, defaultSize: 80, index: 1
    ),
    .init(
        color: .teal, fill: .teal, offsetY: -240, expandedSize: 120, defaultSize: 80, index: 0),
]

