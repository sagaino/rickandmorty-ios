//
//  RMService.swift
//  RickAndMorty
//
//  Created by admin on 30/07/24.
//

import Foundation

/// primary API service object to get data
final class RMService {
    /// shared singleton instance
    static let shared = RMService()
    
    /// private constructor
    private init(){}
    
    /// send API call
    /// - Parameters:
    ///   - request: Request instance
    ///   - completion: callback with data or error
    public func execute(_ request: RMRequest, completion: @escaping () -> Void) {
        
    }
}
