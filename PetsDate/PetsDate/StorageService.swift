import UIKit
import FirebaseStorage

final class StorageService {
    static let shared = StorageService()
    private let storage = Storage.storage().reference()
    
    private init() {}
    
    /// Загружает UIImage в Firebase Storage и возвращает URL
    func uploadImage(_ image: UIImage, path: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "ImageCompressError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось сжать изображение"])
        }
        
        let ref = storage.child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await ref.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await ref.downloadURL()
        return downloadURL.absoluteString
    }
}
