//
//  LoginViewController.swift
//  ShoeBuddy
//
//  Created by Van Le on 9/5/18.
//  Copyright © 2018 EdgeWorks Sofware. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: BaseViewController, HasTableView {
    
    fileprivate var googleSignInHanlder: ((_ authenticateToken: String?) -> Void)?
    fileprivate var googleSignInPresentViewController: ((_ signInViewController: UIViewController) -> Void)?
    fileprivate var googleSignInDismissViewController: ((_ signInViewController: UIViewController) -> Void)?
    
    var viewModel = LoginViewModel()
    
    // tableView
    internal var tableView: UITableView! = {
        let tableView = UITableView()
        tableView.register(SocialButtonTableCell.self, forCellReuseIdentifier: SocialButtonTableCell.identify)
        tableView.register(ACTextContentTableCell.self, forCellReuseIdentifier: ACTextContentTableCell.identify)
        tableView.register(ACTextFieldTableCell.self, forCellReuseIdentifier: ACTextFieldTableCell.identify)
        tableView.register(ACButtonTableCell.self, forCellReuseIdentifier: ACButtonTableCell.identify)
        tableView.register(ACForgotButtonTableCell.self, forCellReuseIdentifier: ACForgotButtonTableCell.identify)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "spaceCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LocalizeStrings.Account.loginString
        
        self.view.setThemeBackgroundColor(keyPath: ThemeKeys.View.backgroundColor.key)
        
        self.initializeUI()
        
        setDataSource()
        
    }
    
    private func setDataSource() {
        self.viewModel.generateCellItems()
        tableView.reloadData()
    }
    
    // MARK: Initialize UI
    func initializeUI() {
        
        tableConfigureDefaultProperties()
        tableView.setThemeBackgroundColor(keyPath: ThemeKeys.View.backgroundColor.key,
                                          alpha: 0.05)
        tableView.allowsSelection = true
        
        // Set constraint layouts
        self.tableView.snp.makeConstraints { [weak self] (maker) in
            guard let strongSelf = self else { return }
            maker.edges.equalTo(strongSelf.view)
        }
    }
    
    func logIn() {
        self.showLoading()
        self.viewModel.requestLogIn {
            self.hideLoading()
            if self.viewModel.logInResponse?.data != nil {
                self.present(UINavigationController(rootViewController: InputViewController()), animated: true, completion: nil)
            }
        }
    }
    
}

extension LoginViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let height = viewModel.cellItems[indexPath.row] as? CGFloat {
            return height
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension LoginViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cellItem = self.viewModel.cellItems[indexPath.row] as? SocialButtonTableCellItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: SocialButtonTableCell.identify, for: indexPath) as! SocialButtonTableCell
            cell.cellItem = cellItem
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        }
        
        if let cellItem = self.viewModel.cellItems[indexPath.row] as? ACTextContentTableCellItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: ACTextContentTableCell.identify, for: indexPath) as! ACTextContentTableCell
            cell.cellItem = cellItem
            cell.selectionStyle = .none
            cell.titleLabel.textAlignment = .center
            cell.titleLabel.alpha = 0.6
            return cell
        }
        
        if let cellItem = self.viewModel.cellItems[indexPath.row] as? ACTextFieldTableCellItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: ACTextFieldTableCell.identify, for: indexPath) as! ACTextFieldTableCell
            cell.cellItem = cellItem
            cell.selectionStyle = .none
            cell.delegate = self
            
            if cell.cellItem?.id == LoginField.password.hashValue {
                cell.textField.isSecureTextEntry = true
            }
            
            return cell
        }
        
        if let cellItem = self.viewModel.cellItems[indexPath.row] as? ACButtonTableCellItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: ACButtonTableCell.identify, for: indexPath) as! ACButtonTableCell
            cell.cellItem = cellItem
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        }
        
        if let cellItem = self.viewModel.cellItems[indexPath.row] as? ACForgotButtonTableCellItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: ACForgotButtonTableCell.identify, for: indexPath) as! ACForgotButtonTableCell
            cell.cellItem = cellItem
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "spaceCell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        return cell
    }
}

extension LoginViewController: ACTextFieldTableCellDelegate {
    
    func acTextFieldTableCell(_ cell: ACTextFieldTableCell, didEditing cellItem: ACTextFieldTableCellItem?) {
        if let validItem = cellItem {
            
            self.viewModel.cellItems = self.viewModel.cellItems.map({ [weak self] (item) -> Any in
                
                guard let strongSelf = self else {
                    return item
                }
                
                if let textFieldItem = item as? ACTextFieldTableCellItem, let id = textFieldItem.id {
                    if id == validItem.id {
                        switch id {
                        case RegisterField.email.hashValue:
                            strongSelf.viewModel.logInRequest.username = validItem.text
                            break
                        case RegisterField.username.hashValue:
                            strongSelf.viewModel.logInRequest.password = validItem.text
                            break
                            
                        default:
                            break
                        }
                        
                        var newItem = textFieldItem
                        newItem.text = validItem.text
                        
                        return newItem
                    }
                }
                
                return item
            })
        }
    }
}

extension LoginViewController: ACButtonTableCellDelegate {
    func acButtonTabelCell(_ cell: ACButtonTableCell, didTapButton cellItem: ACButtonTableCellItem?) {
        
        // valid email or username
        guard let username = self.viewModel.logInRequest.username else {
            self.viewModel.cellItems.remove(at: 4)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: LoginField.email.hashValue, text: self.viewModel.logInRequest.username, placeholder: LocalizeStrings.Account.emailOrUsernameString, errorMessage: LocalizeStrings.ErrorMessage.theUsernameMustNotBeBlankString), at: 4)
            self.tableView.reloadData()
            return
        }
        if username.isEmpty {
            self.viewModel.cellItems.remove(at: 4)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: LoginField.email.hashValue, text: self.viewModel.logInRequest.username, placeholder: LocalizeStrings.Account.emailOrUsernameString, errorMessage: LocalizeStrings.ErrorMessage.theUsernameMustNotBeBlankString), at: 4)
            self.tableView.reloadData()
            return
        } else {
            self.viewModel.cellItems.remove(at: 4)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: LoginField.email.hashValue, text: self.viewModel.logInRequest.username, placeholder: LocalizeStrings.Account.emailOrUsernameString, errorMessage: nil), at: 4)
        }
        
        // valid password
        guard let password = self.viewModel.logInRequest.password else {
            self.viewModel.cellItems.remove(at: 5)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: LoginField.password.hashValue, text: self.viewModel.logInRequest.password, placeholder: LocalizeStrings.Account.passwordString, errorMessage: LocalizeStrings.ErrorMessage.thePasswordMustNotBeBlankString), at: 5)
            self.tableView.reloadData()
            return
        }
        if password.isEmpty {
            self.viewModel.cellItems.remove(at: 5)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: LoginField.password.hashValue, text: self.viewModel.logInRequest.password, placeholder: LocalizeStrings.Account.passwordString, errorMessage: LocalizeStrings.ErrorMessage.thePasswordMustNotBeBlankString), at: 5)
            self.tableView.reloadData()
            return
        } else {
            self.viewModel.cellItems.remove(at: 5)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: LoginField.password.hashValue, text: self.viewModel.logInRequest.password, placeholder: LocalizeStrings.Account.passwordString, errorMessage: nil), at: 5)
        }
        
        self.tableView.reloadData()
        self.logIn()
    }
}

extension LoginViewController: ACForgotButtonTableCellDelegate {
    func acForgotButtonTabelCell(_ cell: ACForgotButtonTableCell, didTapButton cellItem: ACForgotButtonTableCellItem?) {
        let vc = ForgottenPasswordViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LoginViewController: SocialButtonTableCellDelegate {
    func socialButtonTabelCell(_ cell: SocialButtonTableCell, didTapButton cellItem: SocialButtonTableCellItem?) {
        if cellItem?.id == LoginField.facebookButton.hashValue {
            self.showLoading()
            self.viewModel.loginFB(self) { [weak self] in
                
                guard let strongSelf = self else { return }
                strongSelf.hideLoading()
                if AccountManager.shared.isLoggedIn() {
                    //                    AppDelegate.shared.rootViewController.switchToHomeScreen()
                }
            }
        }
        
        if cellItem?.id == LoginField.googleButton.hashValue {
            print("Google login action")
        }
    }
}
