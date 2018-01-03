//
//  BaseWebService.swift
//  Econotouch
//
//  Created by Clément NONN on 25/03/2015.
//  Copyright (c) 2017 Clément NONN. All rights reserved.
//

import Foundation
import UIKit

public enum NetworkError: Error {
    case noData
    case noGoodResponse
    case internalError(Error)
    case badHTTPCode(Int, Data?)
    case badConnection(String)
    case criticError(String, String)
    case networkUnavailable
    case unwrapError(DataRepresentable, Error)
    
    var description: String {
        switch self {
        case .noData:
            return "No data"
            
        case .noGoodResponse:
            return "No response"
            
        case .internalError(let error):
            return "Internal error : \(error.localizedDescription)"
            
        case .badHTTPCode(let httpCode, let data):
            let dataString: String
            if let data = data, let dataStr = String(data: data, encoding: .utf8) {
                dataString = dataStr
            } else {
                dataString = ""
            }
            return "Bad Http Code : \(httpCode) \(dataString)"
            
        case .badConnection(let message):
            return message
            
        case .criticError(let title, let message):
            return "\(title) : \(message)"
            
        case .networkUnavailable:
            return "network unavailable"
            
        case .unwrapError(let data, let error):
            return "unable to unwrap data : \(data) : \(error)"
        }
    }
}

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.noData, .noData), (.noGoodResponse, .noGoodResponse), (.networkUnavailable, .networkUnavailable):
            return true
            
        case (.internalError(let err1), .internalError(let err2)):
            return err1.localizedDescription == err2.localizedDescription
            
        case (.badHTTPCode(let httpCode1, let data1), .badHTTPCode(let httpCode2, let data2)):
            return httpCode1 == httpCode2 && data1 == data2
            
        case (.badConnection(let message1), .badConnection(let message2)):
            return message1 == message2
            
        case (.criticError(let title1, let message1), .criticError(let title2, let message2)):
            return title1 == title2 && message1 == message2
            
        default:
            return false
        }
    }
}

fileprivate var currentRequests: Int = 0 {
    didSet {
        if currentRequests == 0 && oldValue > 0 {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        } else if currentRequests > 0 && oldValue == 0 {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
        }
    }
}

// MARK: - DataRepresentable

public protocol DataRepresentable {
    func toData() throws -> Data
}

extension Data: DataRepresentable {
    public func toData() throws -> Data {
        return self
    }
}

enum StringError: Error {
    case unableToBuildData(String)
    case unableToInitializeString(Data)
}

extension String: DataRepresentable {
    public func toData() throws -> Data {
        return try self.toData(using: .utf8, allowLossyConversion: false)
    }
    
    
    /// convert String to data, with error throwing instead of simple optional
    ///
    /// - Returns: the encoded data
    /// - Throws: unableToBuildData if not possible
    public func toData(using encoding: String.Encoding, allowLossyConversion: Bool = false) throws -> Data {
        if let data = self.data(using: encoding, allowLossyConversion: false) {
            return data
        } else {
            throw StringError.unableToBuildData(self)
        }
    }
}

// MARK: - WS protocols

enum WSResult<T> {
    case success(T)
    case error(Error)
}

protocol Service {
    var isReachable: Bool { get }
    
    mutating func cancelAll()
}

protocol DataService: Service {
    func downloadData(at url: URL, completion: ((WSResult<Data>) -> Void)?)
    func downloadData(with request: URLRequest, completion: ((WSResult<Data>) -> Void)?)
}

protocol SendService: Service {
    func send(data: DataRepresentable, at url: URL, completion: ((WSResult<Data>) -> Void)?)
    func send(data: DataRepresentable, with request: URLRequest, completion: ((WSResult<Data>) -> Void)?)
}

protocol FileService: Service {
    func downloadFile(at url: URL, completion: ((WSResult<URL>) -> Void)?)
    func downloadFile(with request: URLRequest, completion: ((WSResult<URL>) -> Void)?)
}

// MARK: - concrete implementation

protocol WebService: Service {
    var session: URLSession { get }
}

extension WebService {
    /// cancel all current task
    mutating func cancelAll() {
        self.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
    }
    
    /// Generate completion for all task : check errors, and execute completion if possible
    func taskCompletion<T>(completion: ((WSResult<T>) -> Void)? = nil) -> ((T?, URLResponse?, Error?) -> Void) {
        return { dataOrOther, response, error in
            currentRequests -= 1
            
            do {
                let data = try self.checkCommonErrorsFor(data: dataOrOther, response: response, error: error)
                completion?(.success(data))
            } catch let error as NetworkError {
                completion?(.error(error))
            } catch {
                print("error occured : \(error)")
                completion?(.error(NetworkError.internalError(error)))
            }
        }
    }
    
    func checkCommonErrorsFor<T>(data: T?, response: URLResponse?, error: Error?) throws -> T {
        if let error = error {
            throw NetworkError.internalError(error)
        }
        
        guard let httpResp = response as? HTTPURLResponse else {
            throw NetworkError.noGoodResponse
        }
        
        guard (200..<300).contains(httpResp.statusCode) else {
            throw NetworkError.badHTTPCode(httpResp.statusCode, data as? Data)
        }
        
        guard let data = data else {
            throw NetworkError.noData
        }
        return data
    }
}

protocol WebDataService: WebService, DataService { }

extension WebDataService {
    /**
     Download datas with get request from url.
     
     :param: url the url to go to get datas.
     :param: completion stuff to do with received datas (Asynchrone call)
     */
    func downloadData(at url: URL, completion: ((WSResult<Data>) -> Void)? = nil) {
        self.sendRequest(url: url, completion: completion)
    }
    
    func downloadData(with request: URLRequest, completion: ((WSResult<Data>) -> Void)? = nil) {
        self.sendRequest(request: request, completion: completion)
    }
    
    func sendRequest(url: URL, completion: ((WSResult<Data>) -> Void)?) {
        guard isReachable else {
            completion?(.error(NetworkError.networkUnavailable))
            return
        }
        let task = self.session.dataTask(with: url,
                                         completionHandler: self.taskCompletion(completion: completion))
            
        currentRequests += 1
        task.resume()
    }
    
    func sendRequest(request: URLRequest, completion: ((WSResult<Data>) -> Void)? = nil) {
        guard isReachable else {
            completion?(.error(NetworkError.networkUnavailable))
            return
        }
        
        let task = self.session.dataTask(with: request,
                                         completionHandler: self.taskCompletion(completion: completion))
            
        currentRequests += 1
        task.resume()
    }
}

protocol WebSendService: WebService, SendService { }

extension WebSendService {
    /**
     Send POST data to an url.
     
     :param: data The data object to send.
     :param: url Where to send data.
     :param: completion stuff to do with received datas (Asynchrone call)
     */
    func send(data: DataRepresentable, at url: URL, completion: ((WSResult<Data>) -> Void)?) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        self.send(data: data, with: request, completion: completion)
    }
    
    /**
     Send a custom request to an url.
     
     :param: data The data object to send.
     :param: url Where to send data.
     :param: completion stuff to do with received datas (Asynchrone call)
     */
    func send(data: DataRepresentable, with request: URLRequest, completion: ((WSResult<Data>) -> Void)?) {
        guard self.isReachable else {
            completion?(.error(NetworkError.networkUnavailable))
            return
        }
        
        do {
            let data = try data.toData()
            let task = self.session.uploadTask(with: request,
                                               from: data,
                completionHandler: self.taskCompletion(completion: completion))
            currentRequests += 1
            
            task.resume()
        } catch {
            completion?(.error(NetworkError.internalError(error)))
        }
        
    }
}

protocol WebFileService: WebService, FileService { }

extension WebFileService {
    /**
     Download file with get request from url.
     
     :param: url the url to go to get datas.
     :param: completion stuff to do with received datas (Asynchrone call)
     */
    func downloadFile(at url: URL, completion: ((WSResult<URL>) -> Void)?) {
        guard self.isReachable else {
            completion?(.error(NetworkError.networkUnavailable))
            return
        }
        let task = self.session.downloadTask(with: url,
                                             completionHandler: self.taskCompletion(completion: completion))
            
        currentRequests += 1
        task.resume()
    }
    
    func downloadFile(with request: URLRequest, completion: ((WSResult<URL>) -> Void)?) {
        guard self.isReachable else {
            completion?(.error(NetworkError.networkUnavailable))
            return
        }
        
        let task = self.session.downloadTask(with: request, completionHandler: self.taskCompletion(completion: completion))
        
        currentRequests += 1
        task.resume()
    }
}

class BaseWebService: NSObject, WebService {
    var isReachable: Bool {
        // TODO: use of Reachability in case of ios < 11.0
        return true
    }
    
    internal lazy var session: URLSession = {
        let conf = URLSessionConfiguration.default
        if #available(iOS 11.0, *) {
            conf.waitsForConnectivity = true
        }
        
        conf.timeoutIntervalForResource = 30.0
        
        return URLSession(configuration: conf)
    }()
}
