//
//  Waifu.swift
//  Wibu App
//
//  Created by Aditya Himawan on 11/02/24.
//

import Foundation

struct Waifu: Identifiable, Codable {
    var id: UUID = UUID() // Providing a default value
    var image: String
    var anime: String
    var name: String
    
    // Custom initializer to set unique id
    init(image: String, anime: String, name: String) {
        self.image = image
        self.anime = anime
        self.name = name
    }
}
