import Foundation
import Combine

class APIService {
    private let host: String
    private let baseURL: String
    
    init(host: String) {
        self.host = host
        self.baseURL = "http://\(host):8000"
    }
    
    func pairDevice(code: String) -> AnyPublisher<PairResponse, Error> {
        guard let url = URL(string: "\(baseURL)/pair?code=\(code)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: PairResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getClipboard() -> AnyPublisher<String, Error> {
        guard let url = URL(string: "\(baseURL)/clipboard") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: ClipboardResponse.self, decoder: JSONDecoder())
            .map { $0.content }
            .eraseToAnyPublisher()
    }
    
    func setClipboard(content: String) -> AnyPublisher<Bool, Error> {
        guard let encodedContent = content.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/clipboard?content=\(encodedContent)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: SuccessResponse.self, decoder: JSONDecoder())
            .map { $0.success }
            .eraseToAnyPublisher()
    }
}

struct ClipboardResponse: Codable {
    let success: Bool
    let content: String
}

struct SuccessResponse: Codable {
    let success: Bool
}
