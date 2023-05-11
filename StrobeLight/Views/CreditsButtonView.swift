//
//  CreditsButtonView.swift
//  StrobeLight
//
//  Created by Jesse Born on 11.05.23.
//

import SwiftUI

struct CreditsButtonView: View {
    @AppStorage("flashes") private var flashCount = 0
    @State var creditsOpen = false
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: {
                    creditsOpen.toggle()
                }) {
                    Label("", systemImage: "info.circle")
                }.sheet(isPresented: $creditsOpen) {
                    VStack {
                        Text("Flashed \(flashCount) times.")
                        Spacer()
                        Text("StrobeLight was developed by Jesse Born, Elias Denzler, and Janis Hunziker as a high school project in informatics. The app is provided without warranties and is distributed as is.")
                        Spacer()
                        Text("© 2023")
                    }.padding().presentationDetents([.fraction(0.28)])
                }
                Spacer()
            }
        }
    }
}

struct CreditsButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsButtonView()
    }
}
