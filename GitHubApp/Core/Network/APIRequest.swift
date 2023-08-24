//
//  APIRequest.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Combine
import Foundation

// Custom error enum for API request errors
enum APIRequestError: Error {
    case invalidURL
    case genericError
    case parseError
}

// Class for making API requests and handling responses
class APIRequest {
    // Main method for fetching API requests
    func fetchRequest<T: APIFetcher, V: Codable>(
        target: T, // The APIFetcher object defining the request details
        dataType: V.Type // The Codable type for the expected response
    ) -> AnyPublisher<V, Error> {
        let url: String = target.path // API endpoint URL
        let parameters: [String: Any] = target.task?.dictionary() ?? [:] // Request parameters
        let method: HTTPMethod = target.method // HTTP method (GET, POST, etc.)

        // Validate and create the URL request
        guard let urlRequest: URL = URL(string: url) else {
            // Return a publisher with a failure containing the custom error
            return Fail(error: APIRequestError.invalidURL)
                .eraseToAnyPublisher()
        }
        var request: URLRequest = URLRequest(url: urlRequest) // Create the URLRequest
        request.httpMethod = method.rawValue // Set the HTTP method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // Add JSON content type header

        // Add custom headers if present in the APIFetcher
        if let headerOpts: [String: Any] = target.header?.dictionary(), !headerOpts.isEmpty {
            target.header?.dictionary()?.forEach { key, value in
                if let value: String = value as? String {
                    request.addValue(value, forHTTPHeaderField: key)
                }
            }
        }

        let session: URLSession = URLSession.shared // Create a shared URLSession

        // For POST, PUT, or DELETE methods, encode parameters and add to the request body
        if method == .POST || method == .PUT || method == .DELETE {
            guard let httpBody: Data =
                    try? JSONSerialization.data(withJSONObject: parameters, options: [.sortedKeys]) else {
                // Return a publisher with a failure containing the custom error
                return Fail(error: APIRequestError.genericError)
                    .eraseToAnyPublisher()
            }
            request.httpBody = httpBody
        }

        // Execute the API request using dataTaskPublisher
        return session
            .dataTaskPublisher(for: request)
            .map(\.data, \.response)
            .tryMap { [weak self, debug = target.debug] data, response in
                if debug {
                    // Debug the response if debug flag is enabled
                    self?.debugResponse(request, data, response, nil)
                }
                return data
            }
            .decode(type: dataType, decoder: jsonDecoder) // Decode the response using the specified Codable type
            .mapError { [weak self] error in
                // Handle decoding errors and debug the response with error if debug flag is enabled
                self?.debugResponse(request, nil, nil, error)
                return APIRequestError.parseError
            }
            .eraseToAnyPublisher() // Convert the publisher to AnyPublisher<V, Error>
    }
}

// Private extension for APIRequest class with helper methods
private extension APIRequest {
    // Private method for debugging API request and response details
    private func debugResponse(
        _ request: URLRequest,
        _ responseData: Data?,
        _ response: URLResponse?,
        _ error: Error?
    ) {
        let uuid: String = UUID().uuidString // Unique identifier for the request
        print("\n↗️ ======= REQUEST =======")
        print("↗️ REQUEST #: \(uuid)")
        print("↗️ URL: \(request.url?.absoluteString ?? "")")
        print("↗️ HTTP METHOD: \(request.httpMethod ?? "GET")")

        // Print request headers if available
        if let requestHeaders: [String: String] = request.allHTTPHeaderFields,
           let requestHeadersData: Data = try?
            JSONSerialization.data(withJSONObject: requestHeaders, options: .prettyPrinted),
           let requestHeadersString: String = String(data: requestHeadersData, encoding: .utf8) {
            print("↗️ HEADERS:\n\(requestHeadersString)")
        }

        // Print request body if available
        if let requestBodyData: Data = request.httpBody,
           let requestBody: String = String(data: requestBodyData, encoding: .utf8) {
            print("↗️ BODY: \n\(requestBody)")
        }

        // Print response details if response is an HTTPURLResponse
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

            // Print response headers if available
            if let responseHeadersData: Data =
                try? JSONSerialization.data(withJSONObject: httpResponse.allHeaderFields, options: .prettyPrinted),
               let responseHeadersString: String = String(data: responseHeadersData, encoding: .utf8) {
                print("↙️ HEADERS:\n\(responseHeadersString)")
            }

            // Print response body if available and not empty
            if let responseBodyData: Data = responseData,
               let responseBody: String = String(data: responseBodyData, encoding: .utf8),
               !responseBody.isEmpty {
                print("↙️ BODY:\n\(responseBody)\n")
            }
        }

        // Print URLError details if an error occurred
        if let urlError: URLError = error as? URLError {
            print("\n❌ ======= ERROR =======")
            print("❌ CODE: \(urlError.errorCode)")
            print("❌ DESCRIPTION: \(urlError.localizedDescription)\n")
        }

        print("======== END OF: \(uuid) ========\n\n")
    }

    // Private method to construct a parse error message
    private func getParseMessage(
        dataRequest: Data?,
        request: URLRequest,
        response: URLResponse?,
        error: Error
    ) -> String {
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

// Private extension on Encodable to convert an object to a dictionary representation
private extension Encodable {
    func dictionary() -> [String: Any]? {
        if let jsonData: Data = try? JSONEncoder().encode(self),
           let dict: [String: Any] = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
            return dict
        }
        return nil
    }
}
