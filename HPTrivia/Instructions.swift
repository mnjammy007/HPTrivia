//
//  GameInstructions.swift
//  HPTrivia
//
//  Created by Apple on 29/10/24.
//

import SwiftUI

struct Instructions: View {
    
    @Environment(\.dismiss) private var dismiss
    
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
                            .padding([.horizontal, .bottom])
                        Text("Each question is worth 5 points, but if you guess a wrong answer, you'll lose 1 point.")
                            .padding([.horizontal, .bottom])
                        Text("If you are struggling with a question, there is an option to reveal a hint or reveal the book that anserws the question. But beware, using these also minuses 1 point each.")
                            .padding([.horizontal, .bottom])
                        Text("When you select the correct answer, you will be awarded all the points left for that question and they will be added to your total score.")
                            .padding([.horizontal, .bottom])
                    }
                    .font(.title3)

                    Text("Good Luck")
                        .font(.title)
                }
                .foregroundColor(.black)
                Button("Done") {
                    dismiss()
                }
                .doneButton()
            }
            .padding(.horizontal, 90)
        }
    }
}

#Preview {
    Instructions()
}
