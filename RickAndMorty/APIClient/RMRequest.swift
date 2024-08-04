//
//  RMRequest.swift
//  RickAndMorty
//
//  Created by admin on 30/07/24.
//

import Foundation


/// object that represents a single API call
final class RMRequest{
    /// API Constants
    private struct Constanst {
        static let baseUrl = "https://rickandmortyapi.com/api"
    }
    
    /// Desired endpoint
    private let endpoint: RMEndpoint
    
    /// Path component for API, if any
    private let pathComponents: [String]
    
    /// Params component for API, if any
    private let queryParameters: [URLQueryItem]
    
    /// Constructed url for the api request in string format
    private var urlString: String {
        var string = Constanst.baseUrl
        string += "/"
        string += endpoint.rawValue
        
        if !pathComponents.isEmpty {
            pathComponents.forEach({
                string += "/\($0)"
            })
        }
        if !queryParameters.isEmpty {
            string += "?"
            
            let argumentString = queryParameters.compactMap({
                guard let value = $0.value else {return nil}
                return "\($0.name)=\(value)"
            }).joined(separator: "&")
            
            string += argumentString
        }
        
        return string
    }
    
    /// Computed & constructed API url
    public var url: URL? {
        return URL(string: urlString)
    }
    
    /// Desired http method
    public let httpMethod = "GET"
    // MARK: - Public
    
    /// Construct request
    /// - Parameters:
    ///   - endpoint: Target endpoint
    ///   - pathComponents: Collection of path components
    ///   - queryParameters: Collection of query params
    init(
        endpoint: RMEndpoint,
        pathComponents: [String] = [],
        queryParameters: [URLQueryItem] = []
    ) {
        self.endpoint = endpoint
        self.pathComponents = pathComponents
        self.queryParameters = queryParameters
    }
    
    convenience init?(url: URL) {
        let string = url.absoluteString
        if !string.contains(Constanst.baseUrl) {
            return nil
        }
        let trimmed = string.replacingOccurrences(of: Constanst.baseUrl+"/", with: "")
        if trimmed.contains("/") {
            let components = trimmed.components(separatedBy: "/")
            guard !components.isEmpty else {
                return nil
            }
            let endpointString = components[0]
            if let rmEndpoint = RMEndpoint(rawValue: endpointString) {
                self.init(endpoint: rmEndpoint)
                return
            }
        } else if trimmed.contains("?") {
            let components = trimmed.components(separatedBy: "?")
            guard !components.isEmpty, components.count >= 2 else {
                return nil
            }
            let endpointString = components[0]
            let queryItemsString = components[1]
            let quertyItems: [URLQueryItem] = queryItemsString.components(separatedBy: "&").compactMap({
                guard $0.contains("=") else {
                    return nil
                }
                let parts = $0.components(separatedBy: "=")
                return URLQueryItem(
                    name: parts[0],
                    value: parts[1]
                )
            })
            
            if let rmEndpoint = RMEndpoint(rawValue: endpointString) {
                self.init(
                    endpoint: rmEndpoint,
                    queryParameters: quertyItems
                )
                return
            }
        }
        return nil
    }
}


extension RMRequest {
    static let listCharacterRequests = RMRequest(endpoint: .character)
}
