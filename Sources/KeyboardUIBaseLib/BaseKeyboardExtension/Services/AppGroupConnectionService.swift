//
//  AppGroupConnectionService.swift
//  Alamofire-dynamic
//
//  Created by Thien Tran-Quan on 5/9/25.
//

import Foundation

protocol AppGroupConnectionServiceProtocol {
    func syncTokens()
}

final class AppGroupConnectionService : AppGroupConnectionServiceProtocol {
    private let appGroupIdentifier = AppGroupConstant.appGroupIdentifier
    private let appGroupTokenKey = AppGroupConstant.appGroupTokenKey
    private let appGroupRefreshTokenKey = AppGroupConstant.appGroupRefreshTokenKey
    
    private func saveDataAppGroup(key: String, value: String){
        let groupId = appGroupIdentifier
        UserDefaultUtil.saveValueToAppGroup(value, forKey: key, groupIdentifier: groupId)
    }
    
    private func saveAccessToken(_ value: String){
        TokenAppStorageService.shared.saveTokens(accessToken: value)
    }
    
    private func saveRefreshToken(_ value: String){
        TokenAppStorageService.shared.saveRefreshToken(value)
    }
    
    private func clearData(key: String){
        UserDefaultUtil.removeData(forKey: key)
    }
    
    private func getDataAppGroup(key: String) -> String? {
        let groupId = appGroupIdentifier
        return UserDefaultUtil.getValueFromAppGroup(String.self, forKey: key, groupIdentifier: groupId)
    }
    
    private func getData(key: String) -> String? {
        return UserDefaultUtil.getData(String.self, forKey: key)
    }
    
    private func getAccessToken() -> String? {
        TokenAppStorageService.shared.getAccessToken()
    }
    
    private func getRefreshToken() -> String? {
        TokenAppStorageService.shared.getRefreshToken()
    }
    
    func syncTokens() {
        LogUtil.v(.AppGroupConnectionService, "AppGroupConnectionService - syncTokens")
        if let agSavedAccessToken = getDataAppGroup(key: appGroupTokenKey) {
            LogUtil.v(.AppGroupConnectionService, "AppGroupConnectionService - syncTokens - agSavedAccessToken: \(agSavedAccessToken)")
            if let savedAccessToken = getAccessToken(){
                if savedAccessToken != agSavedAccessToken {
                    saveAccessToken(agSavedAccessToken)
                }
            }else {
                saveAccessToken(agSavedAccessToken)
            }
        }
        
        if  let agSavedRefreshToken = getDataAppGroup(key: appGroupRefreshTokenKey){
            LogUtil.v(.AppGroupConnectionService, "AppGroupConnectionService - syncTokens - agSavedRefreshToken: \(agSavedRefreshToken)")
            if  let savedRefreshToken = getRefreshToken() {
                if savedRefreshToken != agSavedRefreshToken {
                    saveRefreshToken(agSavedRefreshToken)
                }
            }else{
                saveRefreshToken(agSavedRefreshToken)
            }
        }
    }
}
