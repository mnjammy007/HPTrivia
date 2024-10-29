//
//  GameInstructions.swift
//  HPTrivia
//
//  Created by Apple on 29/10/24.
//

import SwiftUI

struct GameInstructions: View {
    var body: some View {
        ZStack{
            InfoBgImage()
            VStack {
                Image(.appiconwithradius)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .padding(.top)
                ScrollView {
                    Text("How To Play")
                        .font(.largeTitle)
                        .padding()
                    
                    VStack(alignment: .leading) {
                        Text("Welocome To HP Trivia! in this game you will be asked random qustions from the Harry Potter books and you must guess the right answer or you will loose points!😱")
                    }

                }
            }
        }
    }
}

#Preview {
    GameInstructions()
}
