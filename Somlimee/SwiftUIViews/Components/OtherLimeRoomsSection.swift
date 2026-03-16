//
//  OtherLimeRoomsSection.swift
//  Somlimee
//

import SwiftUI

struct OtherLimeRoomsSection: View {
    let rooms: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("다른 라임방")
                .font(.hanSansNeoBold(size: 17))
                .foregroundStyle(Color.somLimeLabel)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(rooms, id: \.self) { room in
                        NavigationLink(value: Route.limeRoom(boardName: room)) {
                            VStack(spacing: 8) {
                                if let sfSymbol = BoardRegistry.sfSymbol(for: room) {
                                    Image(systemName: sfSymbol)
                                        .font(.system(size: 28))
                                        .foregroundStyle(Color.somLimePrimary)
                                        .frame(width: 64, height: 64)
                                        .background(Color.somLimeSystemGray.opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.somLimeSystemGray.opacity(0.5), lineWidth: 1)
                                        )
                                } else {
                                    Image(room)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 64, height: 64)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.somLimeSystemGray.opacity(0.5), lineWidth: 1)
                                        )
                                }

                                Text(BoardRegistry.shortDisplayName(for: room))
                                    .font(.hanSansNeoMedium(size: 11))
                                    .foregroundStyle(Color.somLimeLabel)
                                    .lineLimit(1)
                            }
                            .frame(width: 76)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        OtherLimeRoomsSection(rooms: PreviewData.limeRooms)
    }
}
#endif
