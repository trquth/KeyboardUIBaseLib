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
    
    private func saveData(key: String, value: String){
        UserDefaultUtil.saveValue(value, forKey: key)
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
        if let agSavedAccessToken = getDataAppGroup(key: appGroupTokenKey) {
            LogUtil.d(.AppGroupConnectionService, "AppGroupConnectionService - syncTokens - agSavedAccessToken: \(agSavedAccessToken)")
            if let savedAccessToken = getData(key: appGroupTokenKey){
                if savedAccessToken != agSavedAccessToken {
                    clearData(key: appGroupTokenKey)
                    saveData(key: appGroupTokenKey, value: agSavedAccessToken)
                }
            }else {
                saveData(key: appGroupTokenKey, value: agSavedAccessToken)
            }
        }
        
        if  let agSavedRefreshToken = getDataAppGroup(key: appGroupRefreshTokenKey){
            LogUtil.d(.AppGroupConnectionService, "AppGroupConnectionService - syncTokens - agSavedRefreshToken: \(agSavedRefreshToken)")
            if  let savedRefreshToken = getData(key: appGroupRefreshTokenKey) {
                if savedRefreshToken != agSavedRefreshToken {
                    clearData(key: appGroupRefreshTokenKey)
                    saveData(key: appGroupRefreshTokenKey, value: agSavedRefreshToken)
                }
            }else{
                saveData(key: appGroupRefreshTokenKey, value: agSavedRefreshToken)
            }
        }
    }
}
