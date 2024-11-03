//
//  Settings.swift
//  HPTrivia
//
//  Created by Apple on 30/10/24.
//

import SwiftUI

struct Settings: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            InfoBgImage()
            VStack {
                Text("Which book would you like to see questions from?")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                ScrollView {
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(0..<7){i in
                            if store.books[i] == .active || (store.books[i] == .locked && store.purchasedItemIds.contains("hp\(i+1)")){
                                ZStack(alignment: .bottomTrailing) {
                                    Image("hp\(i+1)")
                                        .resizable()
                                        .scaledToFit()
                                        .shadow(radius: 7)
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.largeTitle)
                                        .imageScale(.large)
                                        .foregroundColor(.green)
                                        .shadow(radius: 1)
                                        .padding(3)
                                }
                                .task {
                                    store.books[i] = .active
                                    store.saveStatus()
                                }
                                .onTapGesture {
                                    store.books[i] = .inactive
                                    store.saveStatus()
                                }
                            }
                            else if store.books[i] == .inactive {
                                ZStack(alignment: .bottomTrailing) {
                                    Image("hp\(i+1)")
                                        .resizable()
                                        .scaledToFit()
                                        .overlay(Rectangle().opacity(0.33))
                                        .shadow(radius: 7)
                                    
                                    Image(systemName: "circle")
                                        .font(.largeTitle)
                                        .imageScale(.large)
                                        .foregroundColor(.green.opacity(0.5))
                                        .shadow(radius: 1)
                                        .padding(3)
                                }
                                .onTapGesture {
                                    store.books[i] = .active
                                    store.saveStatus()
                                }
                            }
                            else{
                                ZStack {
                                    Image(.hp3)
                                        .resizable()
                                        .scaledToFit()
                                        .overlay(Rectangle().opacity(0.75))
                                        .shadow(radius: 7)
                                    
                                    Image(systemName: "lock.fill")
                                        .font(.largeTitle)
                                        .imageScale(.large)
                                        .shadow(color: .white.opacity(0.75),radius: 3)
                                }
                                .onTapGesture {
                                    let product = store.products[i-3]
                                    Task {
                                        await store.purchase(product)
                                    }
                                }
                            }
                        }
                    }
                }
                Button("Done") {
                    dismiss()
                }
                .doneButton()
            }
            .padding(.horizontal, 100)
            .foregroundColor(.black)
        }
    }
}

#Preview {
    Settings()
        .environmentObject(Store())
}
