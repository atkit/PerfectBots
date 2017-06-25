//
//  FacebookService.swift
//  Messanger
//

import Foundation
import BotsKit
import Mapper
import PerfectCURL

public final class FacebookProvider: Provider {
    internal let accessToken: String
    public let secretToken: String
    
    internal let webhook: MessengerWebhook = MessengerWebhook()
    // Good candidate to remove
    public let update: Signal<Activity>
    
    public init(secretToken: String, accessToken: String) {
        self.secretToken = secretToken;
        self.accessToken = accessToken
        update = Signal()
    }
    
    // Send
    public func send(activity: Activity) {
        
        do {
            let json = [
                "recipient": ["id": activity.recipient.id ],
                "message": ["text": activity.text]
            ];
            
            let data = try JSONSerialization.data(withJSONObject: json)
            
            let url = "https://graph.facebook.com/v2.6/me/messages?access_token=\(self.accessToken)"
            let res = try performPOSTUrlRequest(url, data: data);
            
            debugPrint("Response \(res)")
        }
        catch let error {
            fatalError("\(error)")
        }
    }
    
    fileprivate func performPOSTUrlRequest(_ url: String, data: Data) throws -> String {
        let request = CURLRequest(url,
                                  .httpMethod(.post),
                                  .addHeader(.fromStandard(name: "Content-Type"), "application/json"),
                                  .postData([UInt8](data)))
        return try request.perform().bodyString
    }
}

extension FacebookProvider: Parser {
    public func parse(data: Data) throws {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            throw ProviderError.cantParseJSON(data)
        }
        try parse(json: json)
    }
    
    public func parse(json: JSON) throws {
        let request = try webhook.parse(callback: json)
        request.entry.forEach{
            let conversation = Conversation(members: [], //?
                status: "page",
                channelId: $0.id,
                activityId: "facebook")
            $0.messaging.forEach{ (o) in
                switch (o) {
                case .message(let details, let message):
                    let from = Account(id: details.sender, name: "")
                    let recipient = Account(id: details.recipient, name: "")
                    let activity = Activity(type: .message,
                                            id: message.mid,
                                            conversation: conversation,
                                            from: from,
                                            recipient: recipient,
                                            timestamp: details.timestamp,
                                            localTimestamp: details.timestamp,
                                            text: message.text ?? "")
                    update.update(activity)
                    break
                default:
                    break
                }
            }
        }
    }
}

