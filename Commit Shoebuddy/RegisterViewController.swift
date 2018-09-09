//
//  RegisterViewController.swift
//  ShoeBuddy
//
//  Created by Van Le on 9/4/18.
//  Copyright © 2018 EdgeWorks Sofware. All rights reserved.
//

import UIKit

class RegisterViewController: BaseViewController, HasTableView {
    
    fileprivate var googleSignInHanlder: ((_ authenticateToken: String?) -> Void)?
    fileprivate var googleSignInPresentViewController: ((_ signInViewController: UIViewController) -> Void)?
    fileprivate var googleSignInDismissViewController: ((_ signInViewController: UIViewController) -> Void)?

    var viewModel = RegisterViewModel()
    var confirmPassword: String?
    
    // tableView
    internal var tableView: UITableView! = {
        let tableView = UITableView()
        tableView.register(SocialButtonTableCell.self, forCellReuseIdentifier: SocialButtonTableCell.identify)
        tableView.register(ACTextContentTableCell.self, forCellReuseIdentifier: ACTextContentTableCell.identify)
        tableView.register(ACTextFieldTableCell.self, forCellReuseIdentifier: ACTextFieldTableCell.identify)
        tableView.register(ACButtonTableCell.self, forCellReuseIdentifier: ACButtonTableCell.identify)
        tableView.register(ACAgreementTableCell.self, forCellReuseIdentifier: ACAgreementTableCell.identify)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "spaceCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LocalizeStrings.Account.signUpString
        
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
    
    func register() {
        self.showLoading()
        self.viewModel.requestSignUp {
            self.hideLoading()
        }
    }
    
    @objc func handleTextFieldTapped(_ gestureRegconize: UITapGestureRecognizer) {
        print("select location")
//        self.delegate?.acAgreementTableCell(self, didTapButton: self.cellItem, gestureRegconize)
        self.viewModel.signUpRequest.location = "Viet nam"
        navigationController?.pushViewController(LocationViewController(), animated: true)
    }
}

extension RegisterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let height = viewModel.cellItems[indexPath.row] as? CGFloat {
            return height
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension RegisterViewController: UITableViewDataSource {
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
        
        if let cellItem = self.viewModel.cellItems[indexPath.row] as? ACAgreementTableCellItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: ACAgreementTableCell.identify, for: indexPath) as! ACAgreementTableCell
            cell.cellItem = cellItem
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        }
        
        if let cellItem = self.viewModel.cellItems[indexPath.row] as? ACTextFieldTableCellItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: ACTextFieldTableCell.identify, for: indexPath) as! ACTextFieldTableCell
            cell.cellItem = cellItem
            cell.selectionStyle = .none
            cell.delegate = self
            
            if cell.cellItem?.id == RegisterField.password.hashValue || cell.cellItem?.id == RegisterField.confirmpassword.hashValue {
                cell.textField.isSecureTextEntry = true
            }
            
            if cell.cellItem?.errorMessage != nil && cell.textField.isSecureTextEntry == false {
                cell.textField.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
            }
            
            if cell.cellItem?.placeholder == LocalizeStrings.Account.locationString {
//                cell.textField.isUserInteractionEnabled = false
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTextFieldTapped(_ :)))
                cell.textField.addGestureRecognizer(tapGesture)
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "spaceCell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        return cell
    }
}

extension RegisterViewController: ACTextFieldTableCellDelegate {
    
    func acTextFieldTableCell(_ cell: ACTextFieldTableCell, didEditing cellItem: ACTextFieldTableCellItem?) {
        
        cell.textField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        if cellItem?.id == RegisterField.confirmpassword.hashValue {
            self.confirmPassword = cellItem?.text
        }
        
        if let validItem = cellItem {
            
            self.viewModel.cellItems = self.viewModel.cellItems.map({ [weak self] (item) -> Any in
                
                guard let strongSelf = self else {
                    return item
                }
                
                if let textFieldItem = item as? ACTextFieldTableCellItem, let id = textFieldItem.id {
                    if id == validItem.id {
                        switch id {
                        case RegisterField.email.hashValue:
                            strongSelf.viewModel.signUpRequest.email = validItem.text
                            break
                        case RegisterField.username.hashValue:
                            strongSelf.viewModel.signUpRequest.username = validItem.text
                            break
                        case RegisterField.password.hashValue:
                            strongSelf.viewModel.signUpRequest.password = validItem.text
                            break
                        case RegisterField.location.hashValue:
                            strongSelf.viewModel.signUpRequest.location = validItem.text
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

extension RegisterViewController: ACButtonTableCellDelegate {
    func acButtonTabelCell(_ cell: ACButtonTableCell, didTapButton cellItem: ACButtonTableCellItem?) {
        
        // valid email
        guard let email = self.viewModel.signUpRequest.email else {
            self.viewModel.cellItems.remove(at: 4)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: RegisterField.email.hashValue, text: self.viewModel.signUpRequest.email, placeholder: LocalizeStrings.Account.emailString, errorMessage: LocalizeStrings.ErrorMessage.theEmailAddressMustNotBeBlankString), at: 4)
            self.tableView.reloadData()
            return
        }
        if email.isEmpty {
            self.viewModel.cellItems.remove(at: 4)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: RegisterField.email.hashValue, text: self.viewModel.signUpRequest.email, placeholder: LocalizeStrings.Account.emailString, errorMessage: LocalizeStrings.ErrorMessage.theEmailAddressMustNotBeBlankString), at: 4)
            self.tableView.reloadData()
            return
        } else if !email.isEmail {
            self.viewModel.cellItems.remove(at: 4)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: RegisterField.email.hashValue, text: self.viewModel.signUpRequest.email, placeholder: LocalizeStrings.Account.emailString, errorMessage: LocalizeStrings.ErrorMessage.thatEmailAddressIsInvalidString), at: 4)
            self.tableView.reloadData()
            return
        }
        else {
            self.viewModel.cellItems.remove(at: 4)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: RegisterField.email.hashValue, text: self.viewModel.signUpRequest.email, placeholder: LocalizeStrings.Account.emailString, errorMessage: nil), at: 4)
        }
        
        // valid username
        guard let username = self.viewModel.signUpRequest.username else {
            self.viewModel.cellItems.remove(at: 5)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: RegisterField.username.hashValue, text: self.viewModel.signUpRequest.username, placeholder: LocalizeStrings.Account.usernameString, errorMessage: LocalizeStrings.ErrorMessage.theUsernameMustNotBeBlankString), at: 5)
            self.tableView.reloadData()
            return
        }
        if username.isEmpty {
            self.viewModel.cellItems.remove(at: 5)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: RegisterField.username.hashValue, text: self.viewModel.signUpRequest.username, placeholder: LocalizeStrings.Account.usernameString, errorMessage: LocalizeStrings.ErrorMessage.theUsernameMustNotBeBlankString), at: 5)
        } else {
            self.viewModel.cellItems.remove(at: 5)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: RegisterField.username.hashValue, text: self.viewModel.signUpRequest.username, placeholder: LocalizeStrings.Account.usernameString, errorMessage: nil), at: 5)
        }
        
        // valid password
        guard let password = self.viewModel.signUpRequest.password else {
            self.viewModel.cellItems.remove(at: 7)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: RegisterField.password.hashValue, text: self.viewModel.signUpRequest.password, placeholder: LocalizeStrings.Account.passwordString, errorMessage: LocalizeStrings.ErrorMessage.thePasswordMustNotBeBlankString), at: 7)
            self.tableView.reloadData()
            return
        }
        if password.isEmpty {
            self.viewModel.cellItems.remove(at: 7)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: RegisterField.password.hashValue, text: self.viewModel.signUpRequest.password, placeholder: LocalizeStrings.Account.passwordString, errorMessage: LocalizeStrings.ErrorMessage.thePasswordMustNotBeBlankString), at: 7)
            self.tableView.reloadData()
            return
        } else if !password.isPasswordValid {
            self.viewModel.cellItems.remove(at: 7)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: RegisterField.password.hashValue, text: self.viewModel.signUpRequest.password, placeholder: LocalizeStrings.Account.passwordString, errorMessage: LocalizeStrings.ErrorMessage.passwordMustContainMinimumString), at: 7)
            self.tableView.reloadData()
            return
        } else {
            self.viewModel.cellItems.remove(at: 7)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: RegisterField.password.hashValue, text: self.viewModel.signUpRequest.password, placeholder: LocalizeStrings.Account.passwordString, errorMessage: nil), at: 7)
        }
        
        // valid confirmPassword
        guard let confirmPassword = self.confirmPassword else {
            self.viewModel.cellItems.remove(at: 8)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: RegisterField.confirmpassword.hashValue, text: self.confirmPassword, placeholder: LocalizeStrings.Account.confirmPasswordString, errorMessage: LocalizeStrings.ErrorMessage.theConfirmPasswordMustNotBeBlankString), at: 8)
            self.tableView.reloadData()
            return
        }
        if confirmPassword.isEmpty {
            self.viewModel.cellItems.remove(at: 8)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: RegisterField.confirmpassword.hashValue, text: self.confirmPassword, placeholder: LocalizeStrings.Account.confirmPasswordString, errorMessage: LocalizeStrings.ErrorMessage.theConfirmPasswordMustNotBeBlankString), at: 8)
            self.tableView.reloadData()
            return
        } else if confirmPassword != self.viewModel.signUpRequest.password {
            self.viewModel.cellItems.remove(at: 8)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: RegisterField.confirmpassword.hashValue, text: self.confirmPassword, placeholder: LocalizeStrings.Account.confirmPasswordString, errorMessage: LocalizeStrings.ErrorMessage.thesePasswordDoesNotMatchString), at: 8)
            self.tableView.reloadData()
            return
        } else {
            self.viewModel.cellItems.remove(at: 8)
            self.viewModel.cellItems.insert(ACTextFieldTableCellItem(id: RegisterField.confirmpassword.hashValue, text: self.confirmPassword, placeholder: LocalizeStrings.Account.confirmPasswordString, errorMessage: nil), at: 8)
        }
        
        self.tableView.reloadData()
        self.register()
    }
}

extension RegisterViewController: SocialButtonTableCellDelegate {
    func socialButtonTabelCell(_ cell: SocialButtonTableCell, didTapButton cellItem: SocialButtonTableCellItem?) {
        if cellItem?.id == RegisterField.facebookButton.hashValue {
            
            self.showLoading()
            self.viewModel.loginFB(self) { [weak self] in
                
                guard let strongSelf = self else { return }
                strongSelf.hideLoading()
                if AccountManager.shared.isLoggedIn() {
//                    AppDelegate.shared.rootViewController.switchToHomeScreen()
                }
            }
        }
        
        if cellItem?.id == RegisterField.googleButton.hashValue {
            print("Google login action")
        }
    }
}

extension RegisterViewController: ACAgreementTableCellDelegate {
    func acAgreementTableCell(_ cell: ACAgreementTableCell, didTapButton cellItem: ACAgreementTableCellItem?, _ gestureRegconize: UITapGestureRecognizer) {
        
        guard let agreementText = cellItem?.title else { return }
        
        let linkTermConditionRange = (agreementText as NSString).range(of: LocalizeStrings.Account.termsAndConditionsString)
        
        let linkPrivacyPolicyRange = (agreementText as NSString).range(of: LocalizeStrings.Account.privacyPolicyString)
        
        if gestureRegconize.didTapAttributedTextInLabel(label: cell.titleLabel, inRange: linkTermConditionRange) {
            
            // Push to TermCondition screen
            navigationController?.pushViewController(ForgottenPasswordViewController(), animated: true)
        }
        if gestureRegconize.didTapAttributedTextInLabel(label: cell.titleLabel, inRange: linkPrivacyPolicyRange) {
            
            // Push to PrivacyPolicy screen
            navigationController?.pushViewController(ResetPasswordViewController(), animated: true)
        }
    }
}
