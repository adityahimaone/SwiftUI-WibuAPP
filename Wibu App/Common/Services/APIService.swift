//
//  APIService.swift
//  Wibu App
//
//  Created by Aditya Himawan on 11/02/24.
//

import Foundation

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    func fetchWaifuServices() async throws -> [Waifu] {
        let urlString = URL(string: Constants.wibuAPI)
        
        guard let url = urlString else {
            print("😡 ERROR: Could not convert \(urlString?.absoluteString ?? "unknown") to a URL")
            throw URLError(.badURL)
        }
        
        print("🕸️ We are accessing the url \(url)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.init(rawValue: httpResponse.statusCode))
        }
        
        let waifuJSON = try JSONDecoder().decode([WaifuJSON].self, from: data)
        
        // Convert WaifuJSON objects to Waifu objects while setting unique ids
        let waifus = waifuJSON.map { waifuJSON in
            Waifu(image: waifuJSON.image, anime: waifuJSON.anime, name: waifuJSON.name)
        }
        
        return waifus
    }
}

struct WaifuJSON: Codable {
    var image: String
    var anime: String
    var name: String
}
