//
//  CharacterListViewViewModel.swift
//  RickAndMorty
//
//  Created by admin on 31/07/24.
//

import UIKit

protocol RMCharacterListViewViewModelDelegate: AnyObject {
    func didLoadInitialCharacters()
}

final class RMCharacterListViewViewModel: NSObject {
    
    public weak var delegate: RMCharacterListViewViewModelDelegate?
    
    private var characters: [RMCharacter] = [] {
        didSet {
            for character in characters {
                let viewModel = RMCharacterCollectionViewCellViewModel(
                    characterName: character.name,
                    characterStatusText: character.status,
                    characterImageUrl: URL(string: character.image)
                )
                
                cellViewModels.append(viewModel)
            }
        }
    }
    
    private var cellViewModels: [RMCharacterCollectionViewCellViewModel] = []
    
    //new way using async await
    public func fetchCharacter () async {
        do {
            let response: RMGetAllCharactersResponse = try await RMService.shared.execute(.listCharacterRequests, expecting: RMGetAllCharactersResponse.self)
            let results = response.results
            self.characters = results
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didLoadInitialCharacters()
            }
        } catch {
            print(String(describing: error))
        }
    }
    
    // old way without async await
    
    //    public func fetchCharacter () {
    //        RMService.shared.execute(
    //            .listCharacterRequests,
    //            expection: RMGetAllCharactersResponse.self
    //        ) { [weak self] result in
    //            switch result {
    //            case .success(let responseModel):
    //                let results = responseModel.results
    //                self?.characters = results
    //
    //                DispatchQueue.main.async {
    //                    self?.delegate?.didLoadInitialCharacters()
    //                }
    //            case .failure(let error):
    //                print(String(describing: error))
    //            }
    //        }
    //    }
}

extension RMCharacterListViewViewModel: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RMCharacterCollectionViewCell.cellIdentifier,
            for: indexPath
        ) as? RMCharacterCollectionViewCell else {
            fatalError("Unsupported cell")
        }
        
        cell.configure(with: cellViewModels[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = UIScreen.main.bounds
        let width = (bounds.width - 30)/2
        return CGSize(
            width: width,
            height: width * 1.5
        )
    }
}
