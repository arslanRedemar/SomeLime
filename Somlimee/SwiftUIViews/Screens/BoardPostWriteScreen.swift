//
//  BoardPostWriteScreen.swift
//  Somlimee
//

import SwiftUI
import PhotosUI
import Swinject

struct BoardPostWriteScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.diContainer) private var container
    @State private var vm: BoardPostWriteViewModelImpl?
    @State private var title = ""
    @State private var content = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showSuccess = false

    let boardName: String

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !content.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.somLimeLabel)
                }
                .accessibilityLabel("닫기")
                Spacer()
                Text("Write Post")
                    .font(.hanSansNeoBold(size: 16))
                Spacer()
                Button("Submit") {
                    Task {
                        await vm?.submitPost(boardName: boardName, title: title, paragraph: content)
                    }
                }
                .font(.hanSansNeoBold(size: 15))
                .foregroundColor(isValid ? .somLimePrimary : .somLimeSystemGray)
                .disabled(!isValid || vm?.isSubmitting == true)
            }
            .padding()

            if vm?.isSubmitting == true {
                Spacer()
                ProgressView("Submitting...")
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        TextField("Title", text: $title)
                            .font(.hanSansNeoBold(size: 18))
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                            .padding(.top, 8)

                        TextEditor(text: $content)
                            .font(.hanSansNeoRegular(size: 15))
                            .frame(minHeight: 200)
                            .padding(.horizontal)

                        // Image attachment section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                PhotosPicker(
                                    selection: $selectedItems,
                                    maxSelectionCount: 5,
                                    matching: .images
                                ) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "photo.badge.plus")
                                        Text("Add Images (\(vm?.selectedImageData.count ?? 0)/5)")
                                            .font(.hanSansNeoMedium(size: 14))
                                    }
                                    .foregroundColor(.somLimePrimary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.somLimePrimary.opacity(0.1))
                                    .clipShape(Capsule())
                                }
                                Spacer()
                            }
                            .padding(.horizontal)

                            // Image previews
                            if let images = vm?.selectedImageData, !images.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(Array(images.enumerated()), id: \.offset) { index, data in
                                            ZStack(alignment: .topTrailing) {
                                                if let uiImage = UIImage(data: data) {
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 80, height: 80)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                }
                                                Button {
                                                    vm?.removeImage(at: index)
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.white)
                                                        .background(Circle().fill(Color.black.opacity(0.5)))
                                                }
                                                .accessibilityLabel("이미지 삭제")
                                                .offset(x: 4, y: -4)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }

                        if let error = vm?.errorMessage {
                            Text(error)
                                .font(.hanSansNeoRegular(size: 13))
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
        .task {
            guard vm == nil else { return }
            vm = container.resolve(BoardPostWriteViewModel.self) as? BoardPostWriteViewModelImpl
        }
        .onChange(of: vm?.isSubmitted) { _, submitted in
            if submitted == true {
                showSuccess = true
            }
        }
        .alert("게시글 등록 완료", isPresented: $showSuccess) {
            Button("확인") { dismiss() }
        } message: {
            Text("게시글이 성공적으로 등록되었습니다.")
        }
        .onChange(of: selectedItems) { _, newItems in
            Task {
                var newData: [Data] = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        newData.append(data)
                    }
                }
                vm?.selectedImageData = newData
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        BoardPostWriteScreen(boardName: "SDR")
    }
    .previewWithContainer()
}
#endif
