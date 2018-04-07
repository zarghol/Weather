//
//  URLSession+Rx.swift
//  Weather
//
//  Created by Clément NONN on 07/04/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public enum RxURLSessionError: Error {
    case noResponse, noData
}


extension Reactive where Base == URLSession {
    private func checkErrors<T>(data: T?, response: URLResponse?, error: Error?) throws -> T {
        if let error = error {
            throw error
        }
        
        guard let basicResponse = response else {
            throw RxURLSessionError.noResponse
        }
        
        guard let response = basicResponse as? HTTPURLResponse else {
            throw RxCocoaURLError.nonHTTPResponse(response: basicResponse)
        }
        
        guard 200..<300 ~= response.statusCode else {
            throw RxCocoaURLError.httpRequestFailed(response: response, data: data as? Data)
        }
        
        guard let data = data else {
            throw RxURLSessionError.noData
        }
        
        return data
    }
    
    private func taskCompletion<T>(observer: AnyObserver<T>) -> ((T?, URLResponse?, Error?) -> Void) {
        return { dataOrOther, response, error in
            do {
                let data = try self.checkErrors(data: dataOrOther, response: response, error: error)
                observer.on(.next(data))
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
        }
    }
    
    private func generateObservable<T>(_ taskGenerator: @escaping (AnyObserver<T>) -> URLSessionTask) -> Observable<T> {
        return Observable.create { observer in
            let task = taskGenerator(observer)
            task.resume()
            
            return Disposables.create(with: task.cancel)
        }
    }
    
    // MARK: - data tasks
    
    
    public func data(with url: URL) -> Observable<Data> {
        return self.generateObservable { self.base.dataTask(with: url, completionHandler: self.taskCompletion(observer: $0)) }
    }
    
    // MARK: - upload tasks
    
    public func upload(with request: URLRequest, from data: Data) -> Observable<Data> {
        return self.generateObservable { self.base.uploadTask(with: request, from: data, completionHandler: self.taskCompletion(observer: $0)) }
    }
    
    public func upload(with request: URLRequest, fromFile fileUrl: URL) -> Observable<Data> {
        return self.generateObservable { self.base.uploadTask(with: request, fromFile: fileUrl, completionHandler: self.taskCompletion(observer: $0)) }
    }
    
    // MARK: - download tasks
    
    public func download(with request: URLRequest) -> Observable<URL> {
        return self.generateObservable { self.base.downloadTask(with: request, completionHandler: self.taskCompletion(observer: $0)) }
    }
    
    public func download(with url: URL) -> Observable<URL> {
        return self.generateObservable { self.base.downloadTask(with: url, completionHandler: self.taskCompletion(observer: $0)) }
    }
}
