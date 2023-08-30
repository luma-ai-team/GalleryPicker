//
//  PixabayAPI.swift
//  Pixabay
//
//  Created by Roi on 06/08/2023.
//

import Foundation


class PixabayAPI {
    private let apiKey = "38666574-2df79c3a218b225d89741d9c3"
    
    struct PixabayResponse<T: Codable>: Codable {
        let total: Int
        let totalHits: Int
        let hits: [T]
    }
    
    func fetchMedia(type: PixabaySearchType, query: String) async throws -> [PixabayMedia] {
        var queryString: String
        if query.isEmpty {
            queryString = "?key=\(apiKey)&order=trending&per_page=120\(type.extraArguments)"
        } else {
            queryString = "?key=\(apiKey)&q=\(query)&per_page=120\(type.extraArguments)"
        }
        
        queryString = queryString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "\(type.baseUrlString)\(queryString)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        
        switch type {
        case .video:
            let result = try decoder.decode(PixabayResponse<PixabayVideoMedia>.self, from: data)
            return result.hits.map { PixabayMedia.video($0) }
        case .image:
            let result = try decoder.decode(PixabayResponse<PixabayImageMedia>.self, from: data)
            return result.hits.map { PixabayMedia.image($0) }
        }
    }
}
