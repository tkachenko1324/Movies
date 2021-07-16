//
//  HttpServise.swift
//  TestOnseo
//
//  Created by Artem Tkachenko on 04.07.2021.
//  Copyright © 2020 Artem Tkachenko. All rights reserved.
//

import Foundation
import Alamofire

typealias IdResponseBlock = (_ swiftObj: Any?, _ error: Error?) -> Void

enum QueueQos {
    case background
    case defaultQos
}

protocol CustomErrorProtocol: Error {
    var localizedDescription: String { get }
    var code: Int { get }
}

struct CustomError: CustomErrorProtocol {
    
    var localizedDescription: String
    var code: Int
    
    init(localizedDescription: String, code: Int) {
        self.localizedDescription = localizedDescription
        self.code = code
    }
}

class HttpService {
    
    func checkInternetConnect() -> Bool {
        return InternetService.shared.checkInternetConnect()
    }
    
    func internetConnectErr() -> CustomError {
        return CustomError(localizedDescription: "Houston we have a problem", code: 402)
    }
    
    func serverError() -> CustomError {
        return CustomError(localizedDescription: "Houston we have a problem", code: 500)
    }
    
    func serverSomthWrongError() -> CustomError {
        return CustomError(localizedDescription: "Houston we have a problem", code: 500)
    }
    
    func requestError(_ description: String?, _ error: Int?) -> CustomError {
        return CustomError(localizedDescription: description ?? "Houston we have a problem", code: error ?? 404)
    }
    
}

extension HttpService {
    
    func cancellAllRequests() {
        
        Alamofire.Session.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
    
    func queryByApiKey(_ url: URLConvertible,
                       method: HTTPMethod = .get,
                       parameters: Parameters? = nil,
                       encoding: ParameterEncoding = URLEncoding.queryString,
                       headers: HTTPHeaders? = nil,
                       queue: QueueQos,
                       resp: @escaping IdResponseBlock) {
        var params: [String : Any] = [:]
        if let parameters = parameters {
            params = parameters
        }
        params[Requests.apiKeyTitle] = Requests.apiKeyValue
        query(url,
              method: method,
              parameters: params,
              encoding: encoding,
              headers: headers,
              queue: queue,
              resp: resp)
        
    }
    
    internal func query(_ url: URLConvertible,
                        method: HTTPMethod = .get,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = URLEncoding.default,
                        headers: HTTPHeaders? = nil,
                        queue: QueueQos,
                        resp: @escaping IdResponseBlock) {
        
        let queueQos: DispatchQueue
        
        switch queue {
        case QueueQos.defaultQos:
            queueQos = DispatchQueue(label: "queueDefault", qos: .default, attributes: [.concurrent])
        case QueueQos.background:
            queueQos = DispatchQueue(label: "queueBackground", qos: .background, attributes: [.concurrent])
        }
        
        if !checkInternetConnect() {
            return resp(nil, internetConnectErr())
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let request = AF.request(url,
                                 method: method,
                                 parameters: parameters,
                                 encoding: encoding,
                                 headers: headers
        ).validate().responseData(queue: queueQos) { (response) in
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            guard let statusCode = response.response?.statusCode else {
                print("ERROR: Not Found status code")
                return resp(nil, CustomError(localizedDescription: "Not Found status code", code: 0))
            }
            
            switch response.result {
            case .success(let value):
                return resp(value, nil)
            case .failure(let error):
                return resp(nil, CustomError(localizedDescription: error.localizedDescription, code: statusCode))
            }
        }
    }
    
}
