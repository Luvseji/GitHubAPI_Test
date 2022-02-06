//
//  GitHubModels.swift
//  API_Test
//
//  Created by Константин Машейченко on 05.02.2022.
//

import Foundation

struct GitHubUserAtList: Codable {
    let avatarUrl: String
    let login: String
    let id: Int
}

struct GitHubUserDetails: Codable {
    let avatarUrl: String
    let name: String?
    let email: String?
    let company: String?
    let following: Int?
    let followers: Int?
    let createdAt: Date
}
