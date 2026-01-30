import Foundation
import Combine
import UIKit
import PhotosUI

class FileTransferManager: ObservableObject {
    @Published var isUploading = false
    @Published var uploadProgress: Double = 0
    @Published var lastUploadedFile: String?
    @Published var error: String?
    
    func uploadImage(_ image: UIImage, filename: String, toHost host: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            self.error = "Failed to convert image"
            return
        }
        
        uploadFile(data: imageData, filename: filename, host: host)
    }
    
    func uploadFile(data: Data, filename: String, host: String) {
        isUploading = true
        uploadProgress = 0
        
        guard let url = URL(string: "http://\(host):8000/files/upload") else {
            self.error = "Invalid URL"
            isUploading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.uploadTask(with: request, from: body) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isUploading = false
                
                if let error = error {
                    self?.error = error.localizedDescription
                    return
                }
                
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let success = json["success"] as? Bool {
                    if success {
                        self?.lastUploadedFile = filename
                    } else {
                        self?.error = json["error"] as? String ?? "Upload failed"
                    }
                }
            }
        }
        
        task.resume()
    }
}
