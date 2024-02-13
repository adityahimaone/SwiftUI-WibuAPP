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
}
