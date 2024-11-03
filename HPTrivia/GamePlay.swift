//
//  GamePlay.swift
//  HPTrivia
//
//  Created by Apple on 01/11/24.
//

import SwiftUI
import AVKit

struct GamePlay: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var game: Game
    @Namespace private var namespace
    @State private var musicPlayer: AVAudioPlayer!
    @State private var sfxPlayer: AVAudioPlayer!
    @State private var areViewsAnimatingIn = false
    @State private var tappedCorrectAnswer = false
    @State private var tappedIncorrectAnswers:[Int] = []
    @State private var hintWiggle = false
    @State private var isNextButtonScaling = false
    @State private var addPointsToScore = false
    @State private var revealHint = false
    @State private var revealBook = false
    
    let tempAnswers:[Bool] = [true, false, false, false]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                Image(.hogwarts)
                    .resizable()
                    .frame(width: geo.size.width * 3, height: geo.size.height * 1.05)
                    .overlay(Rectangle().foregroundColor(.black.opacity(0.8)))
                
                // MARK: Controls
                VStack {
                    
                    HStack{
                        Button("End Game"){
                            game.endGame()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red.opacity(0.5))
                        Spacer()
                        Text("Score: \(game.gameScore)")
                    }
                    .padding()
                    .padding(.vertical, 30)
                    
                    // MARK: Question
                    VStack {
                        if areViewsAnimatingIn {
                            Text(game.currentQuestion.question)
                                .multilineTextAlignment(.center)
                                .font(.custom(Constants.hpFont, size: 50))
                                .padding()
                                .transition(.scale)
                                .opacity(tappedCorrectAnswer ? 0.1 : 1)
                        }
                    }
                    .animation(.easeOut(duration: areViewsAnimatingIn ? 2 : 0), value: areViewsAnimatingIn)
                    
                    Spacer()
                    
                    // MARK: Hints
                    HStack {
                        VStack {
                            if areViewsAnimatingIn{
                                Image(systemName: "questionmark.app.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                                    .foregroundColor(.cyan)
                                    .rotationEffect(.degrees(hintWiggle ? -13 : -17))
                                    .padding()
                                    .transition(.offset(x: -geo.size.width/2))
                                    .onAppear {
                                        withAnimation(.easeInOut(duration:0.1).repeatCount(9).delay(5).repeatForever()){
                                            hintWiggle = true
                                        }
                                    }
                                    .onTapGesture {
                                        withAnimation(.easeIn(duration: 1)) {
                                            revealHint = true
                                        }
                                        playFlipSound()
                                        game.questionScore -= 1
                                    }
                                    .rotation3DEffect(.degrees(revealHint ? 1440 : 0), axis: (x: 0, y: 1, z: 0))
                                    .scaleEffect(revealHint ? 5 : 1)
                                    .opacity(revealHint ? 0 : 1)
                                    .offset(x: revealHint ? geo.size.width/2 :0)
                                    .overlay {
                                        Text(game.currentQuestion.hint)
                                            .padding(.leading)
                                            .multilineTextAlignment(.center)
                                            .minimumScaleFactor(0.5)
                                            .opacity(revealHint ? 1 : 0)
                                            .scaleEffect(revealHint ? 1.33 :1)
                                    }
                                    .opacity(tappedCorrectAnswer ? 0.1 : 1)
                                    .disabled(tappedCorrectAnswer)
                            }
                        }
                        .animation(.linear(duration: areViewsAnimatingIn ? 1.5 : 0).delay(areViewsAnimatingIn ? 2 : 0), value: areViewsAnimatingIn)
                        
                        Spacer()
                        
                        VStack {
                            if areViewsAnimatingIn{
                                Image(systemName: "book.closed")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50)
                                    .foregroundColor(.black)
                                    .frame(width: 100, height: 100)
                                    .background(.cyan)
                                    .cornerRadius(15)
                                    .rotationEffect(.degrees(hintWiggle ? 13 : 17))
                                    .padding()
                                    .transition(.offset(x: geo.size.width/2))
                                    .onAppear {
                                        withAnimation(.easeInOut(duration:0.1).repeatCount(9).delay(5).repeatForever()){
                                            hintWiggle = true
                                        }
                                    }
                                    .onTapGesture {
                                        withAnimation(.easeIn(duration: 1)) {
                                            revealBook = true
                                        }
                                        playFlipSound()
                                        game.questionScore -= 1
                                    }
                                    .rotation3DEffect(.degrees(revealBook ? 1440 : 0), axis: (x: 0, y: 1, z: 0))
                                    .scaleEffect(revealBook ? 5 : 1)
                                    .opacity(revealBook ? 0 : 1)
                                    .offset(x: revealBook ? -geo.size.width/2 :0)
                                    .overlay {
                                        Image("hp\(game.currentQuestion.book)")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(.trailing)
                                            .opacity(revealBook ? 1 : 0)
                                            .scaleEffect(revealBook ? 1.33 :1)
                                    }
                                    .opacity(tappedCorrectAnswer ? 0.1 : 1)
                                    .disabled(tappedCorrectAnswer)
                            }
                        }
                        .animation(.linear(duration: areViewsAnimatingIn ? 1.5 : 0).delay(areViewsAnimatingIn ? 2 : 0), value: areViewsAnimatingIn)
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom)
                    
                    // MARK: Answers
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(Array(game.answers.enumerated()), id: \.offset){i, answer in
                            if game.currentQuestion.answers[answer] == true {
                                VStack {
                                    if areViewsAnimatingIn && tappedCorrectAnswer == false {
                                        Text(answer)
                                            .minimumScaleFactor(0.5)
                                            .multilineTextAlignment(.center)
                                            .padding(10)
                                            .frame(width: geo.size.width/2.15, height: 80)
                                            .background(.green.opacity(0.5))
                                            .cornerRadius(25)
                                            .transition(.asymmetric(insertion: .scale, removal: .scale(scale: 5).combined(with: .opacity.animation(.easeIn(duration: 5)))))
                                            .matchedGeometryEffect(id: "answer", in: namespace)
                                            .onTapGesture {
                                                withAnimation(.easeOut(duration: 1)){
                                                    tappedCorrectAnswer = true
                                                }
                                                playCorrectAnswerSound()
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5){
                                                    game.correct()
                                                }
                                            }
                                    }
                                }
                                .animation(.easeOut(duration: areViewsAnimatingIn ? 1 : 0).delay(areViewsAnimatingIn ? 1.5 : 0), value: areViewsAnimatingIn)
                            }
                            else {
                                VStack {
                                    if areViewsAnimatingIn{
                                        Text(answer)
                                            .minimumScaleFactor(0.5)
                                            .multilineTextAlignment(.center)
                                            .padding(10)
                                            .frame(width: geo.size.width/2.15, height: 80)
                                            .background(tappedIncorrectAnswers.contains(i) ? .red.opacity(0.5) : .green.opacity(0.5))
                                            .cornerRadius(25)
                                            .transition(.scale)
                                            .onTapGesture {
                                                withAnimation(.easeInOut(duration: 1)) {
                                                    tappedIncorrectAnswers.append(i)
                                                }
                                                playIncorrectAnswerSound()
                                                game.questionScore -= 1
                                                
                                            }
                                            .scaleEffect(tappedIncorrectAnswers.contains(i) ? 0.8 : 1)
                                            .disabled(tappedCorrectAnswer || tappedIncorrectAnswers.contains(i))
                                            .opacity(tappedCorrectAnswer ? 0.1 : 1)
                                    }
                                }
                                .animation(.easeOut(duration: areViewsAnimatingIn ? 1 :0 ).delay(areViewsAnimatingIn ? 1.5 : 0), value: areViewsAnimatingIn)
                            }
                        }
                    }
                    Spacer()
                }
                .foregroundColor(.white)
                .frame(width: geo.size.width, height: geo.size.height)
                
                // MARK: Celebration
                VStack {
                    Spacer()
                    
                    VStack {
                        if tappedCorrectAnswer{
                            Text("\(game.questionScore)")
                                .font(.largeTitle)
                                .padding(.top, 50)
                                .transition(.offset(y: -geo.size.height/4))
                                .offset(x: addPointsToScore ? geo.size.width/2.3 : 0,
                                        y: addPointsToScore ? -geo.size.width/13 : 0
                                )
                                .opacity(addPointsToScore ? 0 : 1)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 1).delay(3)) {
                                        addPointsToScore = true
                                    }
                                }
                        }
                    }
                    .animation(.easeInOut(duration: 1).delay(2), value: tappedCorrectAnswer)
                    
                    Spacer()
                    
                    VStack {
                        if tappedCorrectAnswer{
                            Text("Brilliant!")
                                .font(.custom(Constants.hpFont, size: 100))
                                .transition(.scale.combined(with: .offset(y: -geo.size.height/2)))
                        }
                    }
                    .animation(.easeInOut(duration: tappedCorrectAnswer ? 1 : 0).delay(tappedCorrectAnswer ? 1 : 0), value: tappedCorrectAnswer)
                    
                    Spacer()
                    
                    if tappedCorrectAnswer{
                        Text(game.correctAnswer)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .padding(10)
                            .frame(width: geo.size.width/2.15, height: 80)
                            .background(.green.opacity(0.5))
                            .cornerRadius(25)
                            .scaleEffect(2)
                            .matchedGeometryEffect(id: "answer", in: namespace)
                    }
                    
                    Group {
                        Spacer()
                        Spacer()
                    }
                    
                    VStack{
                        if tappedCorrectAnswer{
                            Button("Next Level >>") {
                                areViewsAnimatingIn = false
                                tappedCorrectAnswer = false
                                tappedIncorrectAnswers = []
                                game.newQuestion()
                                revealHint = false
                                revealBook = false
                                addPointsToScore = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                    areViewsAnimatingIn = true
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue.opacity(0.5))
                            .font(.largeTitle)
                            .scaleEffect(isNextButtonScaling ? 1.2 : 1)
                            .onAppear{
                                withAnimation(.easeInOut(duration: 1.3).repeatForever()) {
                                    isNextButtonScaling.toggle()
                                }
                            }
                            .transition(.offset(y: geo.size.height/3))
                        }
                    }
                    .animation(.easeInOut(duration: tappedCorrectAnswer ? 2.7 : 0).delay(tappedCorrectAnswer ? 2.7 : 0), value: tappedCorrectAnswer)
                    
                    Group {
                        Spacer()
                        Spacer()
                    }
                }
                .foregroundColor(.white)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .onAppear{
            areViewsAnimatingIn = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                playMusic()
            }
        }
    }
    
    private func playMusic(){
        let songs = ["let-the-mystery-unfold", "spellcraft", "hiding-place-in-the-forest", "deep-in-the-dell"]
        let i = Int.random(in: 1...3)
        let sound = Bundle.main.path(forResource: songs[i], ofType: "mp3")
        
        musicPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
        musicPlayer.volume = 0.1
        musicPlayer.numberOfLoops = -1
        musicPlayer.play()
    }
    
    private func playFlipSound() {
        let sound = Bundle.main.path(forResource: "page-flip", ofType: "mp3")
        sfxPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
        sfxPlayer.play()
    }
    
    private func playIncorrectAnswerSound() {
        let sound = Bundle.main.path(forResource: "negative-beeps", ofType: "mp3")
        sfxPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
        sfxPlayer.play()
    }
    
    private func playCorrectAnswerSound() {
        giveIncorrectFeedback()
        let sound = Bundle.main.path(forResource: "magic-wand", ofType: "mp3")
        sfxPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
        sfxPlayer.play()
    }
    private func giveIncorrectFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

#Preview {
    GamePlay()
        .environmentObject(Game())
}
