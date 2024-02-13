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
    
    // grid grid 3
    private let gridItemLayout = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    // Seearch filter waifu
    private var filteredWaifus: [Waifu] {
        guard !searchText.isEmpty else {
            return waifuVM.waifus
        }
        return waifuVM.waifus.filter { waifu in
            waifu.name.lowercased().contains(searchText.lowercased())
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
                                let defaultText = "Just watching anime \(waifu.anime)"
                                
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
                                showDeleteConfirmation.toggle()
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
        .confirmationDialog("Are you sure you want to delete this item?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Yes, sure!", role: .destructive) {
                if let waifuToDelete = waifuToDelete {
                    waifuVM.deletedWaifu(waifuToDelete)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone!")
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
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                                .foregroundStyle(.red)
                            Image(systemName: "xmark.octagon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.white)
                        }
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
