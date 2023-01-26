//
//  ViewController.swift
//  ThreadAsyncAwait
//
//  Created by kaan gokcek on 25.01.2023.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var myTableView: UITableView!
  var cryptoListViewModel = [Currency]()
  override func viewDidLoad() {
    super.viewDidLoad()
    myTableView.delegate = self
    myTableView.dataSource = self
    DownloadArray(){result in
      switch result{
        case .failure(let error):
          print(error)
        case .success(let cryptos):
          self.cryptoListViewModel = cryptos!
      }
    }
  }
  func DownloadArray(completion: @escaping (Result<[Currency]?,DownloaderError>) -> Void){
    guard let url = URL (string: "https://raw.githubusercontent.com/atilsamancioglu/K21-JSONDataSet/master/crypto.json") else {
      return completion(.failure(.badUrl))
    }
    URLSession.shared.dataTask(with: url){ data, response, error in
      guard let data = data, error == nil else {
        return completion(.failure(.noData))
      }
      guard let currencies = try? JSONDecoder().decode([Currency].self, from: data) else {
        return completion(.failure(.dataParseError))
      }
      completion(.success(currencies))
      DispatchQueue.main.async {
        self.myTableView.reloadData()
      }
    }.resume()
  }
}

  
  struct Currency: Codable  {
    let currency : String
    let price : String
  }
  enum DownloaderError: Error {
    case badUrl
    case noData
    case dataParseError
  }
  extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return cryptoListViewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = myTableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath)
      var content = cell.defaultContentConfiguration()
      content.text = cryptoListViewModel[indexPath.row].currency
      content.secondaryText = cryptoListViewModel[indexPath.row].price
      //cell.detailTextLabel?.text = cryptoListViewModel[indexPath.row].price
      cell.contentConfiguration = content
      return cell
    }
    
    
  }


