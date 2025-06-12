//
//  Models.swift
//  DemoVerticalScroll
//
//  Created by Prajeet Shrestha on 12/06/2025.
//

import Foundation

struct FilteredResponse: Codable {
    let data: UserFeedData
}

struct UserFeedData: Codable {
    let userFeedDetails: [UserFeedDetail]
}

struct UserFeedDetail: Codable {
    let userProfileDetails: UserProfileDetails
    let videos: [Video]
}

struct UserProfileDetails: Codable {
    let userId: String
    let name: String
    let profilePicurl: String
}

struct Video: Codable {
    let contentId: Int
    let mediaUrl: String
    let thumbnailMediaUrl: String
}
