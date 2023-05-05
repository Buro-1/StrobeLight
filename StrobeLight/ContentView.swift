//
//  ContentView.swift
//  StrobeLight
//
//  Created by Jesse Born on 03.05.23.
//

import SwiftUI
import Charts

struct ContentView: View {
    
    var ba: BeatAnalyzer = BeatAnalyzer()
    var fl: Flasher = Flasher()
    
    @State private var offset = CGSize.zero
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var index = 0
    
    var body: some View {
        ZStack {
            VStack {
                Image(systemName: "power.circle").resizable().frame(width: 80.0, height: 80.0)
                    .offset(x: 0, y: offset.height)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                withAnimation {
                                    offset = gesture.translation
                                }
                                
                                if (offset.height > 150) {
                                    fl.stop()
                                } else {
                                    fl.startFlashing(atFrequency: offset.height)
                                }
                                
                            }
                            .onEnded { _ in
                                if (offset.height > 150) {
                                    do { try ba.startListening()
                                    } catch {}
                                } else {
                                    ba.stopListening()
                                    fl.stop()
                                    // offset = .zero
                                }
                            }
                    )
                
            }
            VStack {
                Spacer()
                Chart {
                    ForEach((0...ba.lastFFTres.count-1), id: \.self) {
                        LineMark(x: .value("Relative value", ba.lastFFTres[$0]), y: .value("Freq", $0), series: .value("audio", "A"))
                    }
                }
                Text("\(index)")
            }.onReceive(timer, perform: { _ in
                print("updating")
                index += 1
            })
        }
        .padding()
    }
    init() {
        do {
            // ba.configureAudioEngine()
            try ba.startListening()
        }
        catch {}
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
