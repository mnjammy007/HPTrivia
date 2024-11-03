//
//  ContentView.swift
//  HPTrivia
//
//  Created by Apple on 29/10/24.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @EnvironmentObject private var store: Store
    @EnvironmentObject private var game: Game
    @State private var audioPlayer: AVAudioPlayer!
    @State private var isPlayButtonScaling = false
    @State private var isBgImageMoving = false
    @State private var areViewsAnimatingIn = false
    @State var isInstructionSheetPresented = false
    @State var isSettingsSheetPresented = false
    @State var isPlayGameSheetPresented = false
    
    
    var body: some View {
        GeometryReader { geo in
            ZStack{
                Image(.hogwarts)
                    .resizable()
                    .frame(width: geo.size.width * 3, height: geo.size.height)
                    .padding(.top, 3)
                    .offset(x: isBgImageMoving ? geo.size.width/1.1 : -geo.size.width/1.1)
                    .onAppear{
                        withAnimation(.linear(duration: 60).repeatForever()) {
                            isBgImageMoving.toggle()
                        }
                    }
                VStack {
                    VStack {
                        if areViewsAnimatingIn {
                            VStack {
                                Image(systemName: "bolt.fill")
                                    .font(.largeTitle)
                                    .imageScale(.large)
                                Text("HP")
                                    .font(.custom(Constants.hpFont, size: 70))
                                    .padding(.bottom, -50)
                                Text("Trivia")
                                    .font(.custom(Constants.hpFont, size: 60))
                            }
                            .padding(.top, 70)
                            .transition(.move(edge: .top))
                        }
                    }
                    .animation(.easeOut(duration: 0.7).delay(2), value: areViewsAnimatingIn)
                    
                    Spacer()
                    
                    VStack {
                        if areViewsAnimatingIn {
                            VStack {
                                Text("Recent Scores")
                                    .font(.title2)
                                Text("\(game.recentScores[0])")
                                Text("\(game.recentScores[1])")
                                Text("\(game.recentScores[2])")
                            }
                            .font(.title3)
                            .padding(.horizontal)
                            .foregroundColor(.white)
                            .background(.black.opacity(0.7))
                            .cornerRadius(15)
                            .transition(.opacity)
                        }
                    }
                    .animation(.linear(duration: 1).delay(3.5), value: areViewsAnimatingIn)
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            if areViewsAnimatingIn{
                                Button {
                                    isInstructionSheetPresented.toggle()
                                } label: {
                                    Image(systemName: "info.circle.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                        .shadow(radius: 5)
                                }
                                .transition(.offset(x: -geo.size.width/4))
                            }
                        }
                        .animation(.easeOut(duration: 0.7).delay(2.7), value: areViewsAnimatingIn)
                        Spacer()
                        VStack {
                            if areViewsAnimatingIn{
                                Button {
                                    filterQuestions()
                                    game.startGame()
                                    isPlayGameSheetPresented.toggle()
                                } label: {
                                    Text("Play")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 7)
                                        .padding(.horizontal, 50)
                                        .background(store.books.contains(.active) ? .brown : .gray)
                                        .cornerRadius(7)
                                        .shadow(radius: 5)
                                }
                                .scaleEffect(isPlayButtonScaling ? 1.2 : 1)
                                .onAppear{
                                    withAnimation(.easeInOut(duration: 1.3).repeatForever()) {
                                        isPlayButtonScaling.toggle()
                                    }
                                }
                                .transition(.offset(y: geo.size.height/3))
                                .disabled(store.books.contains(.active) ? false : true)
                            }
                        }
                        .animation(.easeOut(duration: 0.7).delay(2), value: areViewsAnimatingIn)
                        Spacer()
                        VStack {
                            if areViewsAnimatingIn{
                                Button {
                                    isSettingsSheetPresented.toggle()
                                } label: {
                                    Image(systemName: "gearshape.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                        .shadow(radius: 5)
                                }
                                .transition(.offset(x: geo.size.width/4))
                            }
                        }
                        .animation(.easeOut(duration: 0.7).delay(2.7), value: areViewsAnimatingIn)
                        Spacer()
                        
                    }
                    .frame(width: geo.size.width)
                    VStack {
                        if areViewsAnimatingIn && store.books.contains(.active) == false{
                            Text("No questions available. Go to settings. ⬆️")
                                .multilineTextAlignment(.center)
                                .padding(.top)
                                .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut.delay(3), value: areViewsAnimatingIn)
                    
                    Spacer()
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .onAppear{
            areViewsAnimatingIn = true
            playAudio()
        }
        .sheet(isPresented: $isInstructionSheetPresented) {
            Instructions()
        }
        .fullScreenCover(isPresented: $isPlayGameSheetPresented, content: {
            GamePlay()
                .environmentObject(game)
                .onAppear{
                    audioPlayer.setVolume(0, fadeDuration: 2)
                }
            onDisappear{
                audioPlayer.setVolume(1, fadeDuration: 3)
            }
        })
        .sheet(isPresented: $isSettingsSheetPresented) {
            Settings()
                .environmentObject(store)
        }
    }
    
    private func playAudio(){
        let sound = Bundle.main.path(forResource: "magic-in-the-air", ofType: "mp3")
        audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
        audioPlayer.numberOfLoops = -1
        audioPlayer.play()
    }
    
    private func filterQuestions() {
        var books: [Int] = []
        for (index, status) in store.books.enumerated(){
            if status == .active{
                books.append(index+1)
            }
        }
        game.filterQuestions(to: books)
        game.newQuestion()
    }
}

#Preview {
    ContentView()
        .environmentObject(Store())
        .environmentObject(Game())
}
