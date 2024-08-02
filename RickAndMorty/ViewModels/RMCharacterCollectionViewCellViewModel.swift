//
//  RMCharacterCollectionViewCellViewModel.swift
//  RickAndMorty
//
//  Created by admin on 01/08/24.
//

import Foundation

final class RMCharacterCollectionViewCellViewModel {
    public let characterName: String
    private let characterStatus: RMCharacterStatus
    private let characterImageUrl: URL?
    
    // MARK: - Init
    
    init(
        characterName: String,
        characterStatusText: RMCharacterStatus,
        characterImageUrl: URL?
    ) {
        self.characterName = characterName
        self.characterStatus = characterStatusText
        self.characterImageUrl = characterImageUrl
    }
    
    public var characterStatusText: String {
        return "Status: \(characterStatus.text)"
    }
    
    // new way using async await
    public func fetchImage() async throws -> Data {
        // TODO: Abstract to Image Manager
        guard let url = characterImageUrl else {
            throw URLError(.badURL)
        }
        let request: URLRequest = URLRequest(url: url)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return data
    }

    // old way without async await
//    public func fetchImage(completion: @escaping(Result<Data, Error>) -> Void) {
//        // TODO: Abstract to Image Manager
//        guard let url = characterImageUrl else {
//            completion(.failure(URLError(.badURL)))
//            return
//        }
//        let request = URLRequest(url: url)
//        let task = URLSession.shared.dataTask(with: request) { data, _, error in
//            guard let data = data, error == nil else {
//                completion(.failure(error ?? URLError(.badServerResponse)))
//                return
//            }
//            
//            completion(.success(data))
//        }
//        
//        task.resume()
//    }
}
