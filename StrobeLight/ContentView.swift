//
//  ContentView.swift
//  StrobeLight
//
//  Created by Jesse Born on 03.05.23.
//
import SwiftUI
import Charts

struct ContentView: View {
    
    let snapToZero = 60.0
    
    var ba: BeatAnalyzer = BeatAnalyzer()
    var fl: Flasher = Flasher()
    
    @State private var offset = CGSize.zero
    
    @State private var mode = 0
//        @State private var freq = 0.0
    #if GRAPH
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var index = 0
    #endif
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    Image(systemName: "power.circle").resizable().frame(width: 80.0, height: 80.0)
                        .offset(x: 0, y: offset.height)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    withAnimation {
                                        if (abs(gesture.translation.height + gesture.startLocation.y) < snapToZero) {
                                            withAnimation(.linear(duration: 0.3)) {
                                                offset = .zero
                                            }
                                            mode = 0
                                        } else if (gesture.translation.height + gesture.startLocation.y > UIScreen.main.bounds.height * 0.25) {
                                            offset = CGSize(width: 0.0, height: UIScreen.main.bounds.height * 0.40)
                                            mode = 2
                                        } else {
                                            var y = gesture.translation.height + gesture.startLocation.y
                                            if (abs(y) > UIScreen.main.bounds.height * 0.40) {
                                                y = y > 0 ? UIScreen.main.bounds.height * 0.40 : -UIScreen.main.bounds.height * 0.40
                                            }
                                            offset = CGSize(width: 0.0, height: y)
                                            mode = 1
                                        }
                                    }
                                    fl.stop()
                                    fl.frequency = abs(offset.height / UIScreen.main.bounds.height) * 55.0
                                    //                                    self.freq = abs(offset.height / UIScreen.main.bounds.height) * 55.0
//                                    print("new freq: ", fl.frequency)
                                    print("\(fl.frequency) in mode \(mode)")
                                    
                                }
                                .onEnded { _ in
                                    ba.stopListening()
                                    if (mode == 0) {
                                        withAnimation {
                                            offset = .zero
                                        }
                                        fl.stop()
                                    } else if (mode == 1) {
                                        // commit new freqency
                                        if (fl.frequency != 0.0) {
                                            fl.startFlashing()
                                        } else {
                                            fl.stop()
                                        }
                                    } else if (mode == 2) {
                                        do {
                                            fl.stop()
                                            fl.frequency = 0
                                            try ba.startListening()
                                        }
                                        catch {}
                                    }
                                }
                        ).zIndex(5)
                    Circle().frame(width: 110.0).zIndex(3).foregroundColor(.init(white: colorScheme == .dark ? 1.0 : 0.0, opacity: colorScheme == .dark ? 0.25 : 0.1))
                }
            }.zIndex(1)
            VStack {
                Text("25 Hz").frame(maxWidth: .infinity, alignment: .trailing)
                Spacer()
                Text("Off").frame(maxWidth: .infinity, alignment: .trailing)
                Spacer()
                Text("Music Mode").frame(maxWidth: .infinity, alignment: .trailing)
            }.zIndex(0)
            HStack {
                Text("Drag to start")
                Image(systemName: "arrow.up.and.down")
                Spacer()
            }
            
            #if GRAPH
//          Debug graph for FFT
                        VStack {
                            Spacer()
                            Chart {
                                ForEach((0...ba.lastFFTres.count-1), id: \.self) {
                                    LineMark(x: .value("Relative value", ba.lastFFTres[$0]), y: .value("Freq", $0), series: .value("audio", "A"))
                                }
                                ForEach((0...ba.lastBinsres.count-1), id: \.self) {
                                    LineMark(x: .value("Relative value", ba.lastBinsres[$0]), y: .value("Freq", $0), series: .value("bins", "A")).foregroundStyle(.green)
                                }
                                ForEach((0...ba.lastBinsDerivative.count-1), id: \.self) {
                                    LineMark(x: .value("Relative value", ba.lastBinsDerivative[$0]), y: .value("Freq", $0), series: .value("derivative", "B")).foregroundStyle(.red)
                                }
                            }
                            Text("\(index)")
                        }.onReceive(timer, perform: { _ in
                            index += 1
                        })
            #endif
        }
        .padding()
    }
    init() {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
