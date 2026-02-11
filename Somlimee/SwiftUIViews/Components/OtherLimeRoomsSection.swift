//
//  OtherLimeRoomsSection.swift
//  Somlimee
//

import SwiftUI

struct OtherLimeRoomsSection: View {
    let rooms: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Other Lime Rooms")
                .font(.hanSansNeoBold(size: 16))
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(rooms, id: \.self) { room in
                        NavigationLink(value: Route.limeRoom(boardName: room)) {
                            VStack {
                                Image(room)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 70, height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                Text(room)
                                    .font(.hanSansNeoRegular(size: 11))
                                    .foregroundStyle(Color.somLimeLabel)
                                    .lineLimit(1)
                            }
                            .frame(width: 80)
                        }
                    }
                }
                .padding(.horizontal)
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
