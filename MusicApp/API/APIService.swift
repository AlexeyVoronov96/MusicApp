//
//  APIService.swift
//  MusicApp
//
//  Created by Алексей Воронов on 15.09.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import Combine
import Foundation

enum APIServiceErrors: LocalizedError {
    case wrongRequest
    case wrongResponse
}

protocol Networking {
    func getData<T: Decodable>(with endpoint: EndPoint, type: T.Type) -> AnyPublisher<T, Error>
}

class APIService: Networking {
    static let shared: Networking = APIService()
    
    func getData<T: Decodable>(with endpoint: EndPoint, type: T.Type) -> AnyPublisher<T, Error> {
        guard let request = performRequest(with: endpoint) else {
            return Fail(error: APIServiceErrors.wrongRequest)
                .eraseToAnyPublisher()
        }
        
        return loadData(with: request)
            .decode(type: type, decoder: Container.jsonDecoder)
            .eraseToAnyPublisher()
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
    
    private func loadData(with request: URLRequest) -> AnyPublisher<Data, Error> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError({ (error) -> Error in
                return APIServiceErrors.wrongResponse
            })
            .map { $0.data }
            .eraseToAnyPublisher()
    }
}
