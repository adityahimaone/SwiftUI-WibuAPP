//
//  WaifuVM.swift
//  Wibu App
//
//  Created by Aditya Himawan on 11/02/24.
//

import SwiftUI

@MainActor
class WaifuVM: ObservableObject {
    @Published var waifus: [Waifu] = []
    @Published var imageToShare: UIImage?
    @Published var showOptions: Bool = false
    @Published var deleteImage: Bool = false
    
    func fetchWaifu() async {
        do {
            let fetchedWaifu = try await APIService.shared.fetchWaifuServices()
            DispatchQueue.main.async {
                self.waifus = fetchedWaifu
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    // Download
    func downloadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Error downloading image: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Prepare untuk muncul di sheet
    func prepareImageAndShowSheet(from urlString: String) async {
        imageToShare = await downloadImage(from: urlString)
        showOptions = true
    }
    
    // Delete image
    func deletedImage(from urlString: String) {
        deleteImage = true
    }
    
}
