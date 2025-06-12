//
//  PageTracker.swift
//  DemoVerticalScroll
//
//  Created by Prajeet Shrestha on 12/06/2025.
//

import Foundation
import Combine

@MainActor
class PageTracker: ObservableObject {
    static let shared = PageTracker()
    
    @Published var currentPage: (verticalIndex: Int, horizontalIndex: Int) = (0, 0)
    
    private init() {}
    
    func updatePage(verticalIndex: Int, horizontalIndex: Int) {
        currentPage = (verticalIndex, horizontalIndex)
    }
    
    func reset() {
        currentPage = (0,0)
    }
}
