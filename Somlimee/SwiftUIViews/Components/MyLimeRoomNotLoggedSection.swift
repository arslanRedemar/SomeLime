//
//  MyLimeRoomNotLoggedSection.swift
//  Somlimee
//

import SwiftUI

struct MyLimeRoomNotLoggedSection: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Log in to see your Lime Room")
                .font(.hanSansNeoMedium(size: 15))
                .foregroundStyle(.secondary)
                .padding(.top, 40)

            NavigationLink(value: Route.login) {
                Text("Log In")
                    .font(.hanSansNeoBold(size: 14))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 10)
                    .background(Color.somLimePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        MyLimeRoomNotLoggedSection()
    }
}
#endif
