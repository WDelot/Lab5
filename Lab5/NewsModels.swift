import Foundation

// MARK: - Моделі даних

/// Модель для джерела новини
struct Source: Decodable, Identifiable {
    // Додаємо Identifiable для SwiftUI
    var id: String? { name }
    let name: String?
}

/// Модель для однієї новини
struct Article: Decodable, Identifiable {
    var id: String? { url }
    
    let source: Source?
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    

    var uniqueID: String {
        return url ?? UUID().uuidString
    }
}

/// Головна модель відповіді від API
nonisolated struct NewsAPIResponse: Decodable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}


enum APIError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case apiError(String)

    var localizedDescription: String {
        switch self {
        case .invalidURL: return "Неправильний URL запиту. Перевірте базову адресу та параметри."
        case .noData: return "Сервер не повернув даних. Спробуйте пізніше."
        case .decodingError(let error): return "Помилка обробки даних: \(error.localizedDescription)"
        case .apiError(let message): return "Помилка API: \(message). Можливо, проблема з ключем або лімітами."
        }
    }
}
