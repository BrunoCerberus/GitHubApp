//
//  APIRequest.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Combine
import Foundation

private enum APIRequestError: Error {
    case genericError
    case parseError
}

class APIRequest {
    func fetchRequest<T: APIFetcher, V: Codable>(target: T, dataType: V.Type) -> AnyPublisher<V, Error> {
        let url: String = target.path
        let parameters: [String: Any] = target.task?.dictionary() ?? [:]
        let method: HTTPMethod = target.method
        
        guard let urlRequest: URL = URL(string: url) else {
            return Fail(error: APIRequestError.genericError)
                .eraseToAnyPublisher()
        }
        
        var request: URLRequest = URLRequest(url: urlRequest)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let headerOpts: [String: Any] = target.header?.dictionary(), !headerOpts.isEmpty {
            target.header?.dictionary()?.forEach { key, value in
                if let value: String = value as? String {
                    request.addValue(value, forHTTPHeaderField: key)
                }
            }
        }
        
        let session: URLSession = URLSession.shared
        
        if method == .POST || method == .PUT || method == .DELETE {
            guard let httpBody: Data = try? JSONSerialization.data(withJSONObject: parameters, options: [.sortedKeys]) else {
                return Fail(error: APIRequestError.genericError)
                    .eraseToAnyPublisher()
            }
            request.httpBody = httpBody
        }
        
        return session
            .dataTaskPublisher(for: request)
            .map(\.data, \.response)
            .tryMap { data, response in
                self.debugResponse(request, data, response, nil)
                let decoded = try JSONDecoder().decode(V.self, from: data)
                return decoded
            }
            .eraseToAnyPublisher()
    }
}

private extension APIRequest {
    private func debugResponse(
            _ request: URLRequest,
            _ responseData: Data?,
            _ response: URLResponse?,
            _ error: Error?
        ) {
            let uuid: String = UUID().uuidString
            print("\n↗️ ======= REQUEST =======")
            print("↗️ REQUEST #: \(uuid)")
            print("↗️ URL: \(request.url?.absoluteString ?? "")")
            print("↗️ HTTP METHOD: \(request.httpMethod ?? "GET")")
            
            if let requestHeaders: [String: String] = request.allHTTPHeaderFields,
               let requestHeadersData: Data = try? JSONSerialization.data(withJSONObject: requestHeaders, options: .prettyPrinted),
               let requestHeadersString: String = String(data: requestHeadersData, encoding: .utf8) {
                print("↗️ HEADERS:\n\(requestHeadersString)")
            }
            
            if let requestBodyData: Data = request.httpBody,
               let requestBody: String = String(data: requestBodyData, encoding: .utf8) {
                print("↗️ BODY: \n\(requestBody)")
            }
            
            if let httpResponse: HTTPURLResponse = response as? HTTPURLResponse {
                print("\n↙️ ======= RESPONSE =======")
                switch httpResponse.statusCode {
                case 200...202, 204, 205:
                    print("↙️ CODE: \(httpResponse.statusCode) - ✅")
                case 400...505:
                    print("↙️ CODE: \(httpResponse.statusCode) - 🆘")
                default:
                    print("↙️ CODE: \(httpResponse.statusCode) - ✴️")
                }
                
                if let responseHeadersData: Data = try? JSONSerialization.data(withJSONObject: httpResponse.allHeaderFields, options: .prettyPrinted),
                   let responseHeadersString: String = String(data: responseHeadersData, encoding: .utf8) {
                    print("↙️ HEADERS:\n\(responseHeadersString)")
                }
                
                if let responseBodyData: Data = responseData, let responseBody: String = String(data: responseBodyData, encoding: .utf8),
                   !responseBody.isEmpty {
                    
                    print("↙️ BODY:\n\(responseBody)\n")
                }
            }
            
            if let urlError: URLError = error as? URLError {
                print("\n❌ ======= ERROR =======")
                print("❌ CODE: \(urlError.errorCode)")
                print("❌ DESCRIPTION: \(urlError.localizedDescription)\n")
            }
            
            print("======== END OF: \(uuid) ========\n\n")
        }
        
        private func getParseMessage(dataRequest: Data?, request: URLRequest, response: URLResponse?, error: Error) -> String {
            var responseStatusCode: String = ""
            var responseBody: String = ""
            
            if let httpResponse: HTTPURLResponse = response as? HTTPURLResponse {
                responseStatusCode = String(httpResponse.statusCode)
            }
            
            if let data = dataRequest, let body = String(data: data, encoding: .utf8) {
                responseBody = body
            }
            
            var parseResponse: String = ""
            parseResponse += "[REQUEST_URL: \(request.url?.absoluteString ?? "")] "
            parseResponse += "[RESPONSE_CODE: \(responseStatusCode)] "
            parseResponse += "[RESPONSE_BODY: \(responseBody)] "
            parseResponse += "[PARSE: \(error.localizedDescription)]"
            
            return parseResponse
        }
}

private extension Encodable {
    func dictionary() -> [String: Any]? {
        if let jsonData: Data = try? JSONEncoder().encode(self),
           let dict: [String: Any] = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
            return dict
        }
        return nil
    }
}
