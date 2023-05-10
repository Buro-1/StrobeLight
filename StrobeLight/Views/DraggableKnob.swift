//
//  DraggableKnob.swift
//  StrobeLight
//
//  Created by Jesse Born on 10.05.23.
//

import SwiftUI

struct DraggableKnob: View {
    let snapToZero = 60.0
    
    @State private var offset = CGSize.zero
    
    @State private var mode = 0
    @EnvironmentObject var ba: BeatAnalyzer
    @EnvironmentObject var td: TourchDriver
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
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
                                td.stop()
                                td.frequency = abs(offset.height / UIScreen.main.bounds.height) * 55.0
                                //                                    self.freq = abs(offset.height / UIScreen.main.bounds.height) * 55.0
//                                    print("new freq: ", fl.frequency)
                                print("\(td.frequency) in mode \(mode)")
                                
                            }
                            .onEnded { _ in
                                ba.stopListening()
                                if (mode == 0) {
                                    withAnimation {
                                        offset = .zero
                                    }
                                    td.stop()
                                } else if (mode == 1) {
                                    // commit new freqency
                                    if (td.frequency != 0.0) {
                                        td.startFlashing()
                                    } else {
                                        td.stop()
                                    }
                                } else if (mode == 2) {
                                    do {
                                        td.stop()
                                        td.frequency = 0
                                        try ba.startListening()
                                    }
                                    catch {}
                                }
                            }
                    ).zIndex(5)
                Circle().frame(width: 110.0).zIndex(3).foregroundColor(.init(white: colorScheme == .dark ? 1.0 : 0.0, opacity: colorScheme == .dark ? 0.25 : 0.1))
            }
        }.zIndex(1)
    }
}

struct DraggableKnob_Previews: PreviewProvider {
    static var previews: some View {
        DraggableKnob()
    }
}
