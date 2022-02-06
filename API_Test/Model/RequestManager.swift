//
//  GitHubRequest.swift
//  API_Test
//
//  Created by Константин Машейченко on 04.02.2022.
//

import Foundation

class RequestManager {
    
    var resultRequestUser: GitHubUserDetails?
    var resultRequestList: [GitHubUserAtList]?
    
    private var urlTemplate = "https://api.github.com/users"
    private let token = "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"
    private var usersPerPage = 100
    private var isUserListRequest = false
    
}

//MARK: - Methods

extension RequestManager {
    
    func requestFor(page: Int, since: Int, completion: @escaping (Bool) -> Void) {
        let url = URL(string: urlTemplate + "?per_page=\(usersPerPage)&since=\(since)")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        isUserListRequest = true
        sendRequest(with: request, completion: completion)
        
    }
    
    func requestFor(user: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: urlTemplate + "/\(user)")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        isUserListRequest = false
        sendRequest(with: request, completion: completion)
    }
    
    private func sendRequest(with request: URLRequest, completion: @escaping (Bool) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("Error took place \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                self.resultRequestList = nil
                self.resultRequestUser = nil
                let result = self.tryParseJSON(data: data)
                completion(result)
                print("Response data string:\n \(dataString)")
            }
        }
        task.resume()
    }
    
    private func tryParseJSON(data: Data) -> Bool {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if isUserListRequest {
                resultRequestList = try decoder.decode([GitHubUserAtList].self, from: data)
            } else {
                resultRequestUser = try decoder.decode(GitHubUserDetails.self, from: data)
            }
            print("Decode success")
            return true
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        return false
    }
}
