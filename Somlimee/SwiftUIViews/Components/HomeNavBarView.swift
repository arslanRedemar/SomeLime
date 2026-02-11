//
//  HomeNavBarView.swift
//  Somlimee
//

import SwiftUI

struct HomeNavBarView: View {
    var onMenuTap: () -> Void
    var onProfileTap: () -> Void

    var body: some View {
        HStack {
            Button(action: onMenuTap) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundStyle(Color.somLimeLabel)
            }

            Spacer()

            Image("SomeLimeLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 28)

            Spacer()

            Button(action: onProfileTap) {
                Image(systemName: "person.circle")
                    .font(.title2)
                    .foregroundStyle(Color.somLimeLabel)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}

#if DEBUG
#Preview {
    HomeNavBarView(onMenuTap: {}, onProfileTap: {})
}
#endif
