//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Arseniy Oksenoyt on 3/1/24.
//

import SwiftUI

struct TitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle.bold())
            .foregroundColor(.white)
    }
}

extension View {
    func title() -> some View {
        modifier(TitleModifier())
    }
}

struct FlagImage: View {
    let name: String
    
    var body: some View {
        Image(name)
            .clipShape(Capsule())
            .shadow(radius: 5)
    }
}

struct ContentView: View {
    static let allCounties = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"]
    
    @State private var countries = allCounties.shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    
    @State private var totalScore = 0
    @State private var questionsAsked = 1

    @State private var showingScore = false
    @State private var newGame = false
    @State private var scoreTitle = ""
    
    @State private var selectedFlag = -1
    
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3),
            ], center: .top, startRadius: 200, endRadius: 700)
                .ignoresSafeArea()

            VStack {
                Spacer()
                
                Text("Guess the Flag")
                    .title()
                
                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    
                    ForEach(0..<3) { number in
                        Button {
                            flagTapped(number)
                        } label: {
                            FlagImage(name: countries[number])
                        }
                        .rotation3DEffect(
                            .degrees(selectedFlag == number ? 360 : 0), axis: (x: 0.0, y: 1.0, z: 0.0)
                        )
                        .opacity(selectedFlag == -1 || selectedFlag == number ? 1 : 0.25)
                        .scaleEffect(selectedFlag == -1 || selectedFlag == number ? 1 : 0.25)
                        .animation(.default, value: selectedFlag)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))
                
                Spacer()
                Spacer()
                
                Text("Score: \(totalScore)")
                    .foregroundStyle(.white)
                    .font(.title.bold())
                Spacer()
                Spacer()
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            Text("Your score is \(totalScore)")
        }
        .alert("Game over. Your score is \(totalScore)", isPresented: $newGame) {
            Button("Reset", action: resetGame)
        }
    }
    
    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            totalScore += 1
            scoreTitle = "Correct."
        } else {
            let countriesNeedTher = ["UK", "US"]
            let theirAnswer = countries[number]
            
            if countriesNeedTher.contains(theirAnswer) {
                scoreTitle = "Wrong! That is a a flag of the \(theirAnswer)"
            } else {
                scoreTitle = "Wrong! That is a a flag of \(theirAnswer)"
            }
        }
        
        selectedFlag = number
        
        if questionsAsked == 8 {
            newGame = true
        } else {
            showingScore = true
        }
    }
    
    func askQuestion() {
        countries.remove(at: correctAnswer)
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        questionsAsked += 1
        selectedFlag = -1
    }
    
    func resetGame() {
        totalScore = 0
        questionsAsked = 0
        countries = Self.allCounties
        askQuestion()
    }
}

#Preview {
    ContentView()
}
