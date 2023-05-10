//
//  ContentView.swift
//  StrobeLight
//
//  Created by Jesse Born on 03.05.23.
//
import SwiftUI
import Charts

struct ContentView: View {
    
    @StateObject var ba: BeatAnalyzer = BeatAnalyzer()
    @StateObject var fl: Flasher = Flasher()
    
    var body: some View {
        NavigationView() {
            ZStack {
                DraggableKnob()
                RightHintView()
                LeftHintView()
            }
            .padding()
        }.environmentObject(ba)
        .environmentObject(fl)
    }
    init() {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
