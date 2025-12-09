import Foundation
import SwiftUI // Потрібно для використання MainActor
internal import Combine

// ViewModel для SwiftUI
final class NewsViewModel: ObservableObject {
    
    // MARK: - @Published властивості
    // SwiftUI автоматично перемальовує View, коли ці властивості змінюються
    @MainActor @Published var articles: [Article] = []
    @MainActor @Published var isLoading: Bool = false
    @MainActor @Published var errorMessage: String?
    
    private let apiManager = NewsAPIManager()
    
    // Метод для завантаження новин
    @MainActor // Гарантуємо, що вся логіка, яка оновлює @Published, виконується на головному потоці
    func loadNews() async {
        // 1. Встановлюємо стан завантаження
        isLoading = true
        errorMessage = nil
        
        let result = await withCheckedContinuation { continuation in
            apiManager.fetchTopHeadlines { result in
                continuation.resume(returning: result)
            }
        }
        
        // 2. Обробка результату
        switch result {
        case .success(let fetchedArticles):
            articles = fetchedArticles.filter { $0.title != nil && $0.urlToImage != nil } // Фільтруємо статті без заголовків чи зображень
        case .failure(let error):
            errorMessage = error.localizedDescription
            print("Помилка: \(error)")
        }
        
        // 3. Знімаємо стан завантаження
        isLoading = false
    }
}
