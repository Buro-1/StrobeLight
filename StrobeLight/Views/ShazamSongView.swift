//
//  ShazamSongView.swift
//  StrobeLight
//
//  Created by Jesse Born on 15.05.23.
//

import SwiftUI

struct ShazamSongView: View {
    @EnvironmentObject var ba: BeatAnalyzer
    
    @State var bottomSheetVisible: Bool = false
    
    var body: some View {
//        Spacer()
//        Text("\(ba.lastShazamMatch?.title ?? "")")
        Text("")
            .sheet(isPresented: $bottomSheetVisible) {
                VStack {
                    Text("Now playing:\n\(ba.lastShazamMatch?.title ?? "-") by \(ba.lastShazamMatch?.artist ?? "-")")
                        .multilineTextAlignment(.center)
                }
                .padding()
                .presentationDetents([.fraction(0.13)])
                .backgroundStyle(.blue)
                .foregroundColor(.white)
            }.onReceive(self.ba.$lastShazamMatch, perform: { match in
            if (match?.title != nil) {
                self.bottomSheetVisible = true
                                                  
            } else {
                self.bottomSheetVisible = false
            }
        })
    }
}

struct ShazamSongView_Previews: PreviewProvider {
    static var previews: some View {
        ShazamSongView()
    }
}
