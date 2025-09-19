//
//  PhotoPicker.swift
//  PDF Redactor
//
//  Created by Роман Грачик on 17.09.2025.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    var onPicked: ([UIImage]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = .zero
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onPicked: onPicked) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let onPicked: ([UIImage]) -> Void
        init(onPicked: @escaping ([UIImage]) -> Void) { self.onPicked = onPicked }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            let providers = results.map(\.itemProvider).filter { $0.canLoadObject(ofClass: UIImage.self) }

            let group = DispatchGroup()
            var images: [UIImage] = []
            let lock = NSLock()

            for p in providers {
                group.enter()
                p.loadObject(ofClass: UIImage.self) { object, _ in
                    if let img = object as? UIImage {
                        lock.lock(); images.append(img); lock.unlock()
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.onPicked(images)
            }
        }
    }
}

