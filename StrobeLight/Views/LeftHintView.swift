//
//  LeftHintView.swift
//  StrobeLight
//
//  Created by Jesse Born on 10.05.23.
//

import SwiftUI

struct LeftHintView: View {
    var body: some View {
        HStack {
            Text("drag-to-start")
            Image(systemName: "arrow.up.and.down")
            Spacer()
        }
    }
}

struct LeftHintView_Previews: PreviewProvider {
    static var previews: some View {
        LeftHintView()
    }
}
