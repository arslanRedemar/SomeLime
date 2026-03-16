//
//  MyLimeRoomNotLoggedSection.swift
//  Somlimee
//

import SwiftUI

struct MyLimeRoomNotLoggedSection: View {
    var body: some View {
        VStack(spacing: 20) {
            // Icon
            Image(systemName: "person.crop.square")
                .font(.system(size: 44, weight: .thin))
                .foregroundStyle(Color.somLimePrimary.opacity(0.7))
                .padding(.top, 28)

            // Text group
            VStack(spacing: 6) {
                Text("나의 라임룸")
                    .font(.hanSansNeoBold(size: 17))
                    .foregroundStyle(Color.somLimeLabel)

                Text("로그인하고 나만의 공간을 만나보세요")
                    .font(.hanSansNeoRegular(size: 13))
                    .foregroundStyle(.secondary)
            }

            // Login button
            NavigationLink(value: Route.login) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 15, weight: .medium))
                    Text("로그인")
                        .font(.hanSansNeoBold(size: 14))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.somLimePrimary.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)

            // Sign up hint
            HStack(spacing: 4) {
                Text("계정이 없으신가요?")
                    .font(.hanSansNeoRegular(size: 12))
                    .foregroundStyle(.tertiary)
                NavigationLink(value: Route.signUp) {
                    Text("회원가입")
                        .font(.hanSansNeoMedium(size: 12))
                        .foregroundStyle(Color.somLimePrimary)
                }
            }
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.somLimeGroupedBackground)
        )
        .padding(.horizontal)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        MyLimeRoomNotLoggedSection()
    }
}
#endif
