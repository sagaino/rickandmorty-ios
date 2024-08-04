//
//  CharacterListViewViewModel.swift
//  RickAndMorty
//
//  Created by admin on 31/07/24.
//

import UIKit

protocol RMCharacterListViewViewModelDelegate: AnyObject {
    func didLoadInitialCharacters()
    func didLoadMoreCharacters(with newIndexPaths: [IndexPath])
    func didSelectCharacter(_ character:RMCharacter)
}

// View Model to handle list view logic
final class RMCharacterListViewViewModel: NSObject {
    
    public weak var delegate: RMCharacterListViewViewModelDelegate?
    
    private var isLoadingMoreCharacters: Bool = false
    
    private var characters: [RMCharacter] = [] {
        didSet {
            for character in characters {
                let viewModel = RMCharacterCollectionViewCellViewModel(
                    characterName: character.name,
                    characterStatusText: character.status,
                    characterImageUrl: URL(string: character.image)
                )
                if !cellViewModels.contains(viewModel) {
                    cellViewModels.append(viewModel)
                }
            }
        }
    }
    
    private var cellViewModels: [RMCharacterCollectionViewCellViewModel] = []
    
    private var apiInfo: RMGetAllCharactersResponse.Info? = nil
    
    /// Fetch initial set of character (20)
    //new way using async await
    public func fetchCharacter () async {
        do {
            let response: RMGetAllCharactersResponse = try await RMService.shared.execute(.listCharacterRequests, expecting: RMGetAllCharactersResponse.self)
            let results = response.results
            let info = response.info
            self.characters = results
            self.apiInfo = info
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didLoadInitialCharacters()
            }
        } catch {
            print(String(describing: error))
        }
    }
    
    // old way without async await
    
    //        public func fetchCharacter () {
    //            RMService.shared.execute(
    //                .listCharacterRequests,
    //                expection: RMGetAllCharactersResponse.self
    //            ) { [weak self] result in
    //                switch result {
    //                case .success(let responseModel):
    //                    let results = responseModel.results
    //                    let info = responseModel.info
    //                    self?.characters = results
    //                    self?.apiInfo = info
    //
    //                    DispatchQueue.main.async {
    //                        self?.delegate?.didLoadInitialCharacters()
    //                    }
    //                case .failure(let error):
    //                    print(String(describing: error))
    //                }
    //            }
    //        }
    
    
    /// Paginate if additional character needed
    public func fetchAdditionalCharacters(url: URL) async {
        // Fetch characters
        guard !isLoadingMoreCharacters else {
            return
        }
        isLoadingMoreCharacters = true
        guard let request = RMRequest(url: url) else {
            isLoadingMoreCharacters = false
            print("Failed to create request")
            return
        }
        do {
            let response = try await RMService.shared.execute(request, expecting: RMGetAllCharactersResponse.self)
            let results = response.results
            let info = response.info
            self.apiInfo = info
            
            let originalCount = self.characters.count
            let newCount = results.count
            let total = originalCount + newCount
            let startingIndex = total - newCount
            let indexPathsToAdd: [IndexPath] = Array(startingIndex..<(startingIndex + newCount)).compactMap({
                return IndexPath(row: $0, section: 0)
            })
            self.characters.append(contentsOf: results)
            
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didLoadMoreCharacters(
                    with: indexPathsToAdd
                )
                self?.isLoadingMoreCharacters = false
            }
        } catch {
            print(String(describing: error))
            isLoadingMoreCharacters = false
        }
    }
    
    public var shouldShowLoadMoreIndicator: Bool {
        return apiInfo?.next != nil
    }
}

// MARK: - CollectionView

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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,
              let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: RMFooterLoadingCollectionReusableView.identifier,
                for: indexPath
              ) as? RMFooterLoadingCollectionReusableView else {
            fatalError("Unsupported")
        }
        footer.startAnimating()
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard shouldShowLoadMoreIndicator else {
            return .zero
        }
        return CGSize(
            width: collectionView.frame.width,
            height: 100
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = UIScreen.main.bounds
        let width = (bounds.width - 30)/2
        return CGSize(
            width: width,
            height: width * 1.5
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let character = characters[indexPath.row]
        delegate?.didSelectCharacter(character)
        
    }
}


// MARK: - ScrollView

extension RMCharacterListViewViewModel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldShowLoadMoreIndicator,
              !isLoadingMoreCharacters,
              !cellViewModels.isEmpty,
              let nextUrlString = apiInfo?.next,
              let url = URL(string: nextUrlString)
        else {
            return
        }
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] t in
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollViewFixedHeight = scrollView.frame.size.height
            
            if offset >= (totalContentHeight - totalScrollViewFixedHeight - 120) {
                Task {
                    await self?.fetchAdditionalCharacters(url: url)
                }
            }
            t.invalidate()
        }
    }
}
