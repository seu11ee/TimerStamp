//
//  CertificationModalView.swift
//  TimerStamp
//
//  Created by 이예슬 on 5/6/25.
//

import SwiftUI

struct CertificationModalView: View {
    var baseImage: UIImage
    var minutes: Int
    var onDismiss: () -> Void
    @State private var hasRendered = false
    @State private var composedImage: UIImage?
    @State private var showShareSheet = false
    @State private var showSaveConfirmation = false

    var body: some View {
        VStack(spacing: 24) {
            Text(L10n.certTitle)
                .font(.title2)
                .foregroundStyle(.mainText)

            if let image = composedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .shadow(color: .mainText.opacity(0.2), radius: 2)
            } else {
                ProgressView(L10n.certRendering)
                    .frame(height: 300)
            }

            HStack(spacing: 16) {
                Button(action: onDismiss) {
                    Text(L10n.certClose)
                        .foregroundColor(.mainButtonText)
                        .padding(9)
                        .frame(maxWidth: .infinity)
                        .background(Color.mainButton)
                        .cornerRadius(10)
                }

                Button(action: saveImage) {
                    Text(L10n.certSaveImage)
                        .foregroundColor(.mainButtonText)
                        .padding(9)
                        .frame(maxWidth: .infinity)
                        .background(Color.mainButton)
                        .cornerRadius(10)
                }
                .disabled(composedImage == nil)

                Button(action: {
                    showShareSheet = true
                }) {
                    Text(L10n.certShare)
                        .foregroundColor(.mainButtonText)
                        .padding(9)
                        .frame(maxWidth: .infinity)
                        .background(Color.mainButton)
                        .cornerRadius(10)
                }
                .disabled(composedImage == nil)
            }
            .frame(height: 44)
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .overlay {
            Color.clear
                .onAppear {
                    if !hasRendered {
                        hasRendered = true
                        DispatchQueue.main.async {
                            if let image = CertificationImageRenderer.render(image: baseImage, minutes: minutes) {
                                DispatchQueue.main.async {
                                    composedImage = image
                                }
                            }
                        }
                    }
                }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = composedImage {
                ActivityView(activityItems: [image])
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .imageSaveCompleted)) { notification in
            if notification.object is Bool {
                showSaveConfirmation = true
            }
        }
        .alert(L10n.done, isPresented: $showSaveConfirmation) {
            Button(L10n.ok, role: .cancel) { }
        } message: {
            Text(L10n.photoSaveSuccess)
        }
        .background(Color.mainBackground)
    }

    private func saveImage() {
        guard let image = composedImage else { return }
        UIImageWriteToSavedPhotosAlbum(
            image,
            ImageSaveService.shared,
            #selector(ImageSaveService.didFinishSaving(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }
}

#Preview {
    Group {
        CertificationModalView(
            baseImage: UIImage(named: "s2") ?? UIImage(),
            minutes: 45,
            onDismiss: {}
        )
        .environment(\.locale, .init(identifier: "en"))
        .previewDisplayName("English")
    }
}
