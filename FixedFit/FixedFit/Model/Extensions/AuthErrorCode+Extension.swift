//
//  AuthErrorCode+Extension.swift
//  Firechat
//
//  Created by Amanuel Ketebo on 9/10/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import Foundation
import FirebaseAuth

extension AuthErrorCode {
    var description: String {
        switch self {
        case .invalidCustomToken:
            return "Invalid custom token"
        case .customTokenMismatch:
            return "Custom token mismatch"
        case .invalidCredential:
            return "Invalid credential"
        case .userDisabled:
            return "User disabled"
        case .operationNotAllowed:
            return "Operation not allowed"
        case .emailAlreadyInUse:
            return "Email already in use"
        case .invalidEmail:
            return "Invalid email"
        case .wrongPassword:
            return "Wrong password"
        case .tooManyRequests:
            return "Too many requests"
        case .userNotFound:
            return "User not found"
        case .accountExistsWithDifferentCredential:
            return "Account exists with different credential"
        case .requiresRecentLogin:
            return "Requires recent login"
        case .providerAlreadyLinked:
            return "Provider already linked"
        case .noSuchProvider:
            return "No such provider"
        case .invalidUserToken:
            return "Invalid user token"
        case .networkError:
            return "Network error"
        case .userTokenExpired:
            return "User token expired"
        case .invalidAPIKey:
            return "Invalid API key"
        case .userMismatch:
            return "User mismatch"
        case .credentialAlreadyInUse:
            return "Credential already in use"
        case .weakPassword:
            return "Weak password"
        case .appNotAuthorized:
            return "App not authorized"
        case .expiredActionCode:
            return "Expired action code"
        case .invalidActionCode:
            return "Invalid action code"
        case .invalidMessagePayload:
            return "Invalid message payload"
        case .invalidSender:
            return "Invalid sender"
        case .invalidRecipientEmail:
            return "Invalid recipient email"
        case .missingPhoneNumber:
            return "Missing phone number"
        case .invalidPhoneNumber:
            return "Invalid phone number"
        case .missingVerificationCode:
            return "Missing verification code"
        case .invalidVerificationCode:
            return "Invalid verification code"
        case .missingVerificationID:
            return "Missing verification ID"
        case .invalidVerificationID:
            return "Invalid verification ID"
        case .missingAppCredential:
            return "Missing app credential"
        case .invalidAppCredential:
            return "Invalid app credential"
        case .sessionExpired:
            return "Session expired"
        case .quotaExceeded:
            return "Quota exceeded"
        case .missingAppToken:
            return "Missing app token"
        case .notificationNotForwarded:
            return "Notification not forwarded"
        case .appNotVerified:
            return "App not verified"
        case .keychainError:
            return "Keychain error"
        case .internalError:
            return "Internal error"
        case .missingEmail:
            return "Missing email"
        case .missingIosBundleID:
            return "Missing iOS bundle id"
        case .missingAndroidPackageName:
            return "Missing Android package name"
        case .unauthorizedDomain:
            return "Unauthorized domain"
        case .invalidContinueURI:
            return "Invalid continue URI"
        case .missingContinueURI:
            return "Missing continue URI"
        case .captchaCheckFailed:
            return "Captcha check failed"
        default: return "Bruhh"
        }
    }
}
