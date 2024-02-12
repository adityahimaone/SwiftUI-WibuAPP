//
//  GridView.swift
//  Wibu App
//
//  Created by Aditya Himawan on 11/02/24.
//

import SwiftUI

struct GridView: View {
    @StateObject private var waifuVM = WaifuVM()
    @State private var searchText: String = ""
    @State private var showDeleteConfirmation = false
    @State private var waifuToDelete: Waifu?
    
    private let gridItemLayout = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    private var filteredWaifus: [Waifu] {
        guard !searchText.isEmpty else {
            return waifuVM.waifus
        }
        return waifuVM.waifus.filter { waifu in
            waifu.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    private func deleteWaifu(_ waifu: Waifu) {
        if let index = waifuVM.waifus.firstIndex(where: { $0.id == waifu.id }) {
            waifuVM.waifus.remove(at: index)
            showDeleteConfirmation = false
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: gridItemLayout, spacing: 10) {
                    ForEach(filteredWaifus, id: \.id) { waifu in
                        Group {
                            VStack(alignment: .leading) {
                                asyncImage(for: waifu)
                                
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
                        .sheet(isPresented: $waifuVM.showOptions) {
                            Group {
                                let defaultText = "You are about to share this items"
                                
                                if let imageToShare = waifuVM.imageToShare {
                                    ActivityView(activityItems: [defaultText, imageToShare])
                                } else {
                                    ActivityView(activityItems: [defaultText])
                                }
                            }
                            .presentationDetents([.medium, .large])
                        }
                        .contextMenu {
                            // Delete
                            Button {
                                waifuToDelete = waifu
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            // Share
                            Button {
                                Task {
                                    await waifuVM.prepareImageAndShowSheet(from: waifu.image)
                                }
                                
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Wibu App")
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "e.g Yor Briar")
            .refreshable {
                await waifuVM.fetchWaifu()
            }
        }
        .task {
            await waifuVM.fetchWaifu()
        }
        .actionSheet(isPresented: $showDeleteConfirmation) {
            ActionSheet(
                title: Text("Are you sure you want to delete this item?"),
                message: Text("This action cannot be undone!"),
                buttons: [
                    .destructive(Text("Yes, sure!")) {
                        if let waifuToDelete = waifuToDelete {
                            deleteWaifu(waifuToDelete)
                        }
                    },
                    .cancel()
                ]
            )
        }
    }
    
    // View for async image
    func asyncImage(for waifu: Waifu) -> some View {
        Group {
            if let url = URL(string: waifu.image) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable()
                            .scaledToFill()
                    case .failure(let error):
                        Text(error.localizedDescription)
                    @unknown default:
                        fatalError()
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Text("Invalid URL")
            }
        }
    }
}

#Preview {
    GridView()
}
