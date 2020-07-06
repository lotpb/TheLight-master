//
//  ConversationModels.swift
//  TheLight2
//
//  Created by Peter Balsamo on 6/20/20.
//  Copyright © 2020 Peter Balsamo. All rights reserved.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
