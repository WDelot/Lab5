import Foundation

class NewsAPIManager {
    
    // Вставте свій API ключ
    private let apiKey = "36442bdaf84443f5abf5ed587da1ff32"
    private let baseURL = "https://newsapi.org/v2/top-headlines"

    func fetchTopHeadlines(completion: @escaping (Result<[Article], APIError>) -> Void) {
        // Запит на топові новини з США
        guard let url = URL(string: "\(baseURL)?country=us&apiKey=\(apiKey)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completion(.failure(.decodingError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(.apiError("HTTP статус: \(httpResponse.statusCode)")))
                return
            }

            // Декодування даних
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let apiResponse = try decoder.decode(NewsAPIResponse.self, from: data)
                
                if apiResponse.status == "ok" {
                    completion(.success(apiResponse.articles))
                } else {
                    // News API може повернути статус "error"
                    completion(.failure(.apiError("Статус відповіді не 'ok'")))
                }
            } catch let decodingError {
                completion(.failure(.decodingError(decodingError)))
            }
        }
        
        task.resume()
    }
}
