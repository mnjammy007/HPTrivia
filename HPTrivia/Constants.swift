//
//  Constants.swift
//  HPTrivia
//
//  Created by Apple on 29/10/24.
//

import Foundation
import SwiftUI

enum Constants {
    static let hpFont = "PartyLetPlain"
    static let previewQuestion = try! JSONDecoder().decode([Question].self, from: Data(contentsOf: Bundle.main.url(forResource: "trivia", withExtension: "json")!))[0]
    
}

struct InfoBgImage: View {
    var body: some View {
        Image(.parchment)
            .resizable()
            .ignoresSafeArea()
            .scaledToFill()
            .background(.brown)
    }
}

extension Button{
    func doneButton() -> some View {
        self
        .font(.largeTitle)
        .foregroundColor(.white)
        .cornerRadius(7)
        .buttonStyle(.borderedProminent)
        .tint(.brown)
    }
}

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
