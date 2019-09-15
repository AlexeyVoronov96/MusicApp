//
//  APIService.swift
//  MusicApp
//
//  Created by Алексей Воронов on 15.09.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import Foundation

enum APIServiceErrors: LocalizedError {
    case wrongRequest
    case wrongResponse
    case dataNil
    case fetchingError
}

protocol Networking {
    func getData<T: Decodable>(with endpoint: EndPoint, type: T.Type, completion: @escaping (Result<T, Error>) -> Void)
}

class APIService: Networking {
    static let shared: Networking = APIService()
    
    func getData<T: Decodable>(with endpoint: EndPoint, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let request = performRequest(with: endpoint) else {
            completion(Result.failure(APIServiceErrors.wrongRequest))
            return
        }

        loadData(with: request, type: type, completion: completion)
    }

    private func performRequest(with endpoint: EndPoint) -> URLRequest? {
        var components = URLComponents()
        components.scheme = endpoint.scheme
        components.host = endpoint.host
        components.path = endpoint.path
        components.queryItems = endpoint.params.map({ (param) -> URLQueryItem in
            return URLQueryItem(name: param.key, value: param.value)
        })
        
        guard let url = components.url else {
            return nil
        }
        return URLRequest(url: url)
    }
    
    private func loadData<T: Decodable>(with request: URLRequest, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            guard let data = data else {
                completion(Result.failure(APIServiceErrors.dataNil))
                return
            }
            
            guard let parsedData = self?.parse(data, with: type) else {
                completion(Result.failure(APIServiceErrors.fetchingError))
                return
            }
            
            completion(Result.success(parsedData))
        }.resume()
    }
    
    private func parse<T: Decodable>(_ data: Data, with type: T.Type) -> T? {
        return try? Container.jsonDecoder.decode(type, from: data)
    }
}
