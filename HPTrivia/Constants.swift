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
