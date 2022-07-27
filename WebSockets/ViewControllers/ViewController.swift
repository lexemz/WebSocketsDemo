//
//  ViewController.swift
//  WebSockets
//
//  Created by Igor Buzykin on 20.05.2022.
//

import UIKit
import Starscream

class ViewController: UIViewController {
    @IBOutlet var textField: UITextField!
    @IBOutlet var messages: UILabel!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var segmentControl: UISegmentedControl!
    
    private var webSocket: WebSocketProvider?
    
    private let url = URL(string: "wss://demo.piesocket.com/v3/channel_1?api_key=VCXCEuvhGcBDP7XhiJJUDvR1e1D3eiVjgZ9VRiaV&notify_self")!

    override func viewDidLoad() {
        super.viewDidLoad()
        webSocket = NativeWebSocket(url: url)
        webSocket?.delegate = self
        setupGesturesAndObservers()
    }

    @IBAction func sendButtonPressed() {
        guard let text = textField.text, !text.isEmpty else { return }
        webSocket?.send(text)
        textField.text = ""
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // For iOS 13+
            webSocket = NativeWebSocket(url: url)
        } else {
            // Up to iOS 13
            webSocket = StarscreamWebSocket(url: url)
        }
        webSocket?.delegate = self
        
        
        // ❗️ If your application requires support for iOS 12 and below,
        // then you can initialize various implementations of the websocket
        
        /*
        if #available(iOS 13.0, *) {
            webSocket = NativeWebSocket(url: url)
        } else {
            webSocket = StarscreamWebSocket(url: url)
        }
        webSocket?.delegate = self
        */
    }
    
    @IBAction func connectButtonPressed(_ sender: UIButton) {
        segmentControl.isEnabled = false
        if webSocket?.isConnected ?? false {
            webSocket?.disconnect()
        } else {
            webSocket?.connect()
            sender.isEnabled = false
        }
    }
}

extension ViewController: WebSocketDelegate {
    func webSocketDidConnect() {
        print(#function)
        
        connectButton.setTitle("Disconnect", for: .normal)
        connectButton.setTitleColor(.systemRed, for: .normal)
        connectButton.isEnabled = true
    }
    
    func webSocketDidDisconnect() {
        print("\(#function) webSocketDidDisconnect")
        
        connectButton.setTitle("Connect", for: .normal)
        connectButton.setTitleColor(.systemGreen, for: .normal)
        segmentControl.isEnabled = true
    }
    
    func webSocket(didReceiveString string: String) {
        messages.text! += "\n\(string)"
        print("\(#function) String message: \(string)")
    }
    
    func webSocket(didReceiveData data: Data) {
        print("\(#function) Data message: \(data)")
    }
}


// MARK: - Gestures and Observers
extension ViewController {
    private func setupGesturesAndObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        let hideKeyboardGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        view.addGestureRecognizer(hideKeyboardGesture)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
