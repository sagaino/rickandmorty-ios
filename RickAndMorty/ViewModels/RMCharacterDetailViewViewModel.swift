//
//  RMCharacterDetailViewViewModel.swift
//  RickAndMorty
//
//  Created by admin on 04/08/24.
//

import Foundation

final class RMCharacterDetailViewViewModel {
    private let character: RMCharacter
    
    init(character: RMCharacter) {
        self.character = character
    }
    
    public var title: String {
        character.name.uppercased()
    }
}
