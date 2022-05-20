//
//  StarscreamWebSocket.swift
//  WebSockets
//
//  Created by Igor Buzykin on 06.07.2022.
//

import Foundation
import Starscream

class StarscreamWebSocket: WebSocketProvider {
    weak var delegate: WebSocketDelegate?
    var isConnected: Bool = false
    
    private let webSocket: WebSocket

    init(url: URL) {
        let request = URLRequest(url: url)
        webSocket = WebSocket(request: request)
        webSocket.delegate = self
    }
    
    deinit {
        print("StarscreamSocket has been replaced on NativeSocket")
    }
    
    func connect() {
        print("connect")
        webSocket.connect()
    }

    func disconnect() {
        webSocket.disconnect()
    }

    func send(_ string: String) {
        webSocket.write(string: string)
    }

    func send(_ data: Data) {
        webSocket.write(data: data)
    }
}

extension StarscreamWebSocket: Starscream.WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client _: WebSocket) {
        switch event {
        case let .connected(dictionary):
            isConnected = true
            delegate?.webSocketDidConnect()
            print(dictionary)
        case let .disconnected(string, uInt16):
            isConnected = false
            delegate?.webSocketDidDisconnect()
            print(string, uInt16)
        case let .text(string):
            delegate?.webSocket(didReceiveString: string)
        case let .binary(data):
            delegate?.webSocket(didReceiveData: data)
        case let .pong(optional):
            print(optional ?? "")
        case let .ping(optional):
            print(optional ?? "")
        case let .error(optional):
            print(optional ?? "")
        case let .viabilityChanged(bool):
            print(bool)
        case let .reconnectSuggested(bool):
            print(bool)
        case .cancelled:
            print("WebSocket cancelled")
            // FIXME: Понять, почему срабатывает cancel
            isConnected = false
            delegate?.webSocketDidDisconnect()
        }
    }
}
