//
//  BaseReponseModel.swift
//  SwiftUIBaseIOS
//
//  Created by Thien Tran-Quan on 7/6/25.
//
struct BaseResponse<T: Decodable>: Decodable {
    let status: Int?
    let message: String?
    let data: T
    
    var success: Bool {
        if let status = status {
            return (200...299).contains(status)}
        return false
        
    }
    
    init(status: Int?, message: String?, data: T) {
        self.status = status
        self.message = message
        self.data = data
    }
}
