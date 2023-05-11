//
//  RightHintView.swift
//  StrobeLight
//
//  Created by Jesse Born on 10.05.23.
//

import SwiftUI

struct RightHintView: View {
    var body: some View {
        VStack {
            Text("25 Hz").frame(maxWidth: .infinity, alignment: .trailing)
            Spacer()
            Text("off-label").frame(maxWidth: .infinity, alignment: .trailing)
            Spacer()
            Text("auto-label").frame(maxWidth: .infinity, alignment: .trailing)
        }.zIndex(0)
    }
}

struct RightHintView_Previews: PreviewProvider {
    static var previews: some View {
        RightHintView()
    }
}
