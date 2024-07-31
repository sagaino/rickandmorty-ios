//
//  RMCharacterViewController.swift
//  RickAndMorty
//
//  Created by admin on 30/07/24.
//

import UIKit


/// Controller to show and search for character
final class RMCharacterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Characters"
        
        RMService.shared.execute(
            .listCharacterRequests,
            expection: RMGetAllCharactersResponse.self
        ) {  result in
            switch result {
            case .success(let model):
                print("total : " + String(model.info.count))
                print("pages : " + String(model.info.pages))
                print("Page result count : " + String(model.results.count))
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
    
}
