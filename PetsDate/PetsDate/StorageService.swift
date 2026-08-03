import UIKit
import FirebaseStorage

final class StorageService {
    static let shared = StorageService()
    private let storage = Storage.storage().reference()
    
    private init() {}
    
    /// Загружает UIImage в Firebase Storage и возвращает URL
    func uploadImage(_ image: UIImage, path: String) async throws -> String {
        // Ужимаем фото до приемлемого размера
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            throw NSError(domain: "ImageCompressError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось сжать изображение"])
        }
        
        let ref = storage.child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Надежный асинхронный аплоуд с гарантированным завершением
        return try await withCheckedThrowingContinuation { continuation in
            ref.putData(imageData, metadata: metadata) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // Запрашиваем публичный URL только после успешного завершения загрузки
                ref.downloadURL { url, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let downloadURL = url?.absoluteString {
                        continuation.resume(returning: downloadURL)
                    } else {
                        continuation.resume(throwing: NSError(domain: "URLError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить URL"]))
                    }
                }
            }
        }
    }
}
