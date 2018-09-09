//
//  LoginViewModel.swift
//  ShoeBuddy
//
//  Created by Van Le on 9/5/18.
//  Copyright © 2018 EdgeWorks Sofware. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import GoogleSignIn

// MARK: Enums
enum LoginField {
    case facebookButton
    case googleButton
    case email
    case password
    case logInButton
    case forGotButton
}

class LoginViewModel: BaseViewModel {
    
    var handleShowMessage: ((String) -> Void)?
    var handleHandleError: ((ErrorType) -> Void)?
    var cellItems: [Any] = []
    
    var logInResponse: AuthenticateResponse?
    var logInRequest = LogInRequest()
    
    private var loginFacebookRequest = SocialLoginRequest()
    var user = User()
    
    // MARK: - Private methods
    func generateCellItems() {
        self.cellItems.append(CGFloat(16))
        self.cellItems.append(SocialButtonTableCellItem(id: RegisterField.facebookButton.hashValue, text: LocalizeStrings.Account.continueWithFacebookString, icon: #imageLiteral(resourceName: "ic_facebook"), bgColor: ThemeKeys.Button.backgroundColor1.key))
        self.cellItems.append(SocialButtonTableCellItem(id: RegisterField.googleButton.hashValue, text: LocalizeStrings.Account.continueWithGoogleString, icon: #imageLiteral(resourceName: "ic_google"), bgColor: ThemeKeys.Button.backgroundColor5.key))
        self.cellItems.append(ACTextContentTableCellItem(text: LocalizeStrings.Account.orWithEmailString))
        self.cellItems.append(ACTextFieldTableCellItem(id: LoginField.email.hashValue, text: "", placeholder: LocalizeStrings.Account.emailOrUsernameString, errorMessage: nil))
        self.cellItems.append(ACTextFieldTableCellItem(id: LoginField.password.hashValue, text: "", placeholder: LocalizeStrings.Account.passwordString, errorMessage: nil))
        self.cellItems.append(CGFloat(8))
        self.cellItems.append(ACButtonTableCellItem(id: LoginField.logInButton.hashValue, titleKey: LocalizeStrings.Account.login()))
        self.cellItems.append(ACForgotButtonTableCellItem(text: LocalizeStrings.Account.forgottenPasswordString))
    }
    
    // MARK: API
    func requestLogIn(completion: (() -> Void)?) {
        
        let param = UserParameters.logIn(request: logInRequest)
        UserAPIs.requestLogIn(param) { [weak self] (result) in
            
            guard let strongSelf = self else { return }
            
            switch result {
            case .Success(let data):
                strongSelf.logInResponse = data
                completion?()
            case .Failure(let error):
                strongSelf.handleHandleError?(error)
            }
        }
    }
    
    // MARK: Facebook
    func loginFB(_ viewController: UIViewController, completion: @escaping (() -> Void)) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: viewController) { [weak self] (loginResult) in
            
            guard let strongSelf = self else { return }
            
            switch loginResult {
            case .failed:
                completion()
                break
                
            case .cancelled:
                completion()
                break
                
            case .success(_, _, let accessToken):
                
                strongSelf.loginFacebookRequest.accessToken = accessToken.authenticationToken
                strongSelf.requestLogInFacebook(completion: {
                    completion()
                })
                break
            }
        }
    }
    
    // MARK: API
    func requestLogInFacebook(completion: (() -> Void)?) {
        let param = UserParameters.logInFacebook(request: self.loginFacebookRequest)
        UserAPIs.requestLogInFacebook(param) { [weak self] (result) in
            
            guard let strongSelf = self else { return }
            
            switch result {
            case .Success(let data):
                //                strongSelf.user = data
                //                AccountManager.shared.saveUser(data)
                completion?()
            case .Failure(let error):
                strongSelf.handleHandleError?(error)
            }
        }
    }
}
