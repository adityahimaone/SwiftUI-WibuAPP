//
//  GridView.swift
//  Wibu App
//
//  Created by Aditya Himawan on 11/02/24.
//

import SwiftUI

struct GridView: View {
    @StateObject private var waifuVM = WaifuVM()
    
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 100), spacing: 10)
    ]
    
    let gridItemLayout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: gridItemLayout) {
                    ForEach(waifuVM.waifus) { waifu in
                        VStack(alignment: .leading) {
                            Group {
                                let urlImg = URL(string: waifu.image)
                                
                                AsyncImage(url: urlImg) { phase in
                                    switch phase {
                                    case .empty:
                                        VStack {
                                            ProgressView()
                                            Text("loading...")
                                        }
                                        
                                    case .success(let image):
                                        image.resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                        
                                    case .failure(let error):
                                        Text(error.localizedDescription)
                                        
                                    @unknown default:
                                        fatalError()
                                    }
                                }
                            }
                            .frame(width: 100, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            Text(waifu.name)
                                .font(.callout)
                                .fontWeight(.semibold)
                                .lineLimit(3, reservesSpace: true)
                            Text(waifu.anime)
                                .font(.callout)
                                .lineLimit(1)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Wibu App")
        }
        .task {
            await waifuVM.fetchWaifu()
        }

    }
}

#Preview {
    GridView()
}
