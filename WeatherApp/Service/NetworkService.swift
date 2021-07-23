//
//  NetworkService.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 23/06/2021.
//

import Foundation
import Alamofire

class NetworkService {
    
    static let shared = NetworkService()
    
    func getCurrentWeatherData(params: [String : String], completed: @escaping (Result<CurrentWeatherBaseData,Error>) -> Void) {
        
        AF.request(Endpoints().currentWeather, method: .get, parameters: params).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let results = try decoder.decode(CurrentWeatherBaseData.self, from: data)
                    completed(.success(results))
                } catch {
                    completed(.failure(error))
                }
                
            case .failure(let error):
                print(error)
                print(response.response?.statusCode ?? 200)
            }
        }
    }
    
    func getAllWeatherData(params: [String : String], completed: @escaping (Result<ForecastWeatherBaseData,Error>) -> Void ){
        
        AF.request(Endpoints().forecastWeather, method: .get, parameters: params).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let results = try decoder.decode(ForecastWeatherBaseData.self, from: data)
                    completed(.success(results))
                } catch {
                    completed(.failure(error))
                }
               
            case .failure(let error):
                print(error)
                print(response.response?.statusCode ?? 200)
            }
        }
    }
}
