//
//  LimeRoomNavBarView.swift
//  Somlimee
//

import SwiftUI

struct LimeRoomNavBarView: View {
    let title: String
    var onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(Color.somLimeLabel)
            }

            Spacer()

            Text(title)
                .font(.hanSansNeoBold(size: 18))
                .foregroundStyle(Color.somLimeLabel)

            Spacer()

            // Placeholder for symmetry
            Image(systemName: "chevron.left")
                .font(.title3)
                .hidden()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}

#if DEBUG
#Preview {
    LimeRoomNavBarView(title: "SDR", onBack: {})
}
#endif
