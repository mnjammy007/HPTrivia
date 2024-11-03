//
//  HPTriviaApp.swift
//  HPTrivia
//
//  Created by Apple on 29/10/24.
//

import SwiftUI

@main
struct HPTriviaApp: App {
    @StateObject private var store = Store()
    @StateObject private var game = Game()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(game)
                .task({
                    await store.loadProducts()
                    game.loadScores()
                    store.loadStatus()
                })
        }
    }
}
