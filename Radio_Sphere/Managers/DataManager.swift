//
//  DataManager.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.02.25.

import Foundation

enum DataError: Error {
    case urlNotValid, dataNotValid, dataNotFound, httpResponseNotValid
}

typealias StationsResult = Result<[RadioStation], Error>
typealias StationsCompletion = (StationsResult) -> Void

struct DataManager {
    
    private static let api = RadioAPI()
    
    /// Holt Radiosender und verarbeitet die API-Daten
    static func getStations(offset: Int, completion: @escaping StationsCompletion) {
        api.fetchStations(offset: offset) { result in
            handleAPIResponse(result, completion: completion)
        }
    }
    
    /// Sucht Radiosender nach Namen
    static func searchStations(query: String, completion: @escaping StationsCompletion) {
        api.searchStations(query: query) { stations in
            DispatchQueue.main.async {
                completion(.success(stations))
            }
        }
    }


    /// Verarbeitet die API-Antwort und dekodiert `RadioStation`
    private static func handleAPIResponse(_ result: Result<Data, Error>, completion: @escaping StationsCompletion) {
        DispatchQueue.main.async {
            switch result {
            case .success(let data):
                let decodedResult = decode(data)
                completion(decodedResult)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Dekodiert die JSON-Daten in `RadioStation`
    private static func decode(_ data: Data) -> StationsResult {
        do {
            let stations = try JSONDecoder().decode([RadioStation].self, from: data)
            return .success(stations)
        } catch {
            return .failure(error)
        }
    }
}


