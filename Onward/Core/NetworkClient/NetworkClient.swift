import Foundation

// MARK: - Backend API Data Structures

/// The request body sent to our secure backend API.
struct ChatRequest: Codable {
    let message: String
    let userId: String?
}

/// The response body received from our secure backend API.
struct ChatResponse: Codable {
    let message: String
    let timestamp: String
}

/// Error response from backend
struct ErrorResponse: Codable {
    let error: String
}


// MARK: - Network Client

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
    case noReply
}

class NetworkClient {
    /// The shared singleton instance of the network client.
    static let shared = NetworkClient()
    
    // Private init to ensure singleton usage.
    private init() {}

    // SECURE: API endpoint points to our secure backend instead of Claude directly
    // For development: http://localhost:3000/api/chat
    // For production: Railway deployment
    private let apiEndpoint = URL(string: "https://onward-healing-production.up.railway.app/api/chat")

    /// Sends a message to our secure backend API and returns the response.
    func sendMessage(_ message: String, userId: String? = nil) async throws -> String {
        guard let url = apiEndpoint else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Construct the request body for our backend
        let requestBody = ChatRequest(
            message: message,
            userId: userId
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw NetworkError.decodingError(error)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            // Handle different HTTP status codes
            switch httpResponse.statusCode {
            case 200:
                let decodedResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
                return decodedResponse.message
                
            case 400, 401, 403:
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                throw NetworkError.requestFailed(NSError(
                    domain: "NetworkClient",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: errorResponse.error]
                ))
                
            case 429:
                throw NetworkError.requestFailed(NSError(
                    domain: "NetworkClient",
                    code: 429,
                    userInfo: [NSLocalizedDescriptionKey: "Too many requests. Please try again later."]
                ))
                
            case 500...599:
                throw NetworkError.requestFailed(NSError(
                    domain: "NetworkClient",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Server error. Please try again later."]
                ))
                
            default:
                throw NetworkError.invalidResponse
            }
            
        } catch let error as DecodingError {
            throw NetworkError.decodingError(error)
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
} 