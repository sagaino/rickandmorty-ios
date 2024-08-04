//
//  ImageLoader.swift
//  RickAndMorty
//
//  Created by admin on 04/08/24.
//

import Foundation

final class RMImageLoader {
    static let shared = RMImageLoader()
    
    private var imageDataChache = NSCache<NSString, NSData>()
    
    private init() {
        
    }
    
    /// Get Image content with URL
    /// - Parameter url: Source URL
    /// - Returns: Result
    public func downloadImage (_ url: URL) async throws -> Data {
        let key = url.absoluteString as NSString
        if let data = imageDataChache.object(forKey: key) {
            return data as Data
        }
            
        let request: URLRequest = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        let value = data as NSData
        self.imageDataChache.setObject(value, forKey: key)
        return data
    }
}
