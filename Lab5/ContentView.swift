import SwiftUI

// MARK: - Допоміжна View для відображення рядка новини
struct ArticleRow: View {
    let article: Article
    
    var body: some View {
        HStack(alignment: .top) {
            // MARK: - Завантаження зображення
            // Використовуємо AsyncImage для асинхронного завантаження зображень з URL
            if let urlString = article.urlToImage, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView() // Показуємо індикатор завантаження
                            .frame(width: 80, height: 80)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(8)
                    case .failure:
                        Image(systemName: "photo") // Зображення-заповнювач у разі помилки
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "newspaper")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
            }
            
            // MARK: - Текст новини
            VStack(alignment: .leading, spacing: 4) {
                Text(article.source?.name ?? "Невідоме джерело")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(article.title ?? "Заголовок недоступний")
                    .font(.headline)
                    .lineLimit(2)
                
                Text(article.description ?? "Опис відсутній.")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Головна View
struct ContentView: View {
    
    // Створення екземпляра ViewModel
    @StateObject private var viewModel = NewsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading {
                    // Показуємо індикатор завантаження
                    ProgressView("Завантаження топових новин...")
                        .padding()
                } else if let error = viewModel.errorMessage {
                    // Показуємо повідомлення про помилку
                    VStack(alignment: .center, spacing: 10) {
                        Image(systemName: "xmark.octagon.fill")
                            .foregroundColor(.red)
                            .font(.largeTitle)
                        Text("Помилка завантаження:")
                            .font(.headline)
                        Text(error)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                        
                        Button("Спробувати знову") {
                            Task {
                                await viewModel.loadNews()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    // Відображаємо список новин
                    ForEach(viewModel.articles, id: \.uniqueID) { article in
                        // Навігація до повної статті
                        if let urlString = article.url, let url = URL(string: urlString) {
                            Link(destination: url) {
                                ArticleRow(article: article)
                            }
                        } else {
                            ArticleRow(article: article)
                        }
                    }
                }
            }
            .navigationTitle("Світові Топ-Новини")
            .refreshable {
                // Дозволяє користувачу оновлювати дані, потягнувши вниз
                await viewModel.loadNews()
            }
        }
        .task {
            await viewModel.loadNews()
        }
    }
}
