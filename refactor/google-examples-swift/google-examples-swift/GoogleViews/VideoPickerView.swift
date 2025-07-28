//
//  VideoPickerView.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 28.07.2025..
//

import SwiftUI
import UIKit
import MobileCoreServices

struct VideoPickerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    typealias CompletionHandler = (URL?) -> Void
    
    var completion: CompletionHandler

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeHigh
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let completion: CompletionHandler

        init(completion: @escaping CompletionHandler) {
            self.completion = completion
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            let url = info[.mediaURL] as? URL
            completion(url)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            completion(nil)
        }
    }
}
