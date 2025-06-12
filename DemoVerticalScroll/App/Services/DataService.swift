//
//  Models.swift
//  DemoVerticalScroll
//
//  Created by Prajeet Shrestha on 12/06/2025.
//

import Foundation

func loadFilteredResponse() -> FilteredResponse? {
    guard let url = Bundle.main.url(forResource: "data", withExtension: "json") else {
        print("bata.json not found in bundle.")
        return nil
    }
    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let response = try decoder.decode(FilteredResponse.self, from: data)
        return response
    } catch {
        print("Failed to load or decode data.json: \(error)")
        return nil
    }
}
