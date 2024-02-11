//
//  WaifuVM.swift
//  Wibu App
//
//  Created by Aditya Himawan on 11/02/24.
//

import Foundation

class WaifuVM: ObservableObject {
    @Published var waifus: [Waifu] = []
    
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
}
