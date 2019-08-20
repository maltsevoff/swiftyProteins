//
//  LoginViewController.swift
//  swiftyProteins
//
//  Created by Yaroslava HLIBOCHKO on 7/17/19.
//  Copyright © 2019 Yaroslava HLIBOCHKO. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
   
    @IBOutlet weak var loginButtonOutlet: UIButton!
    let context = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            switch context.biometryType {
            case .touchID:
                self.loginButtonOutlet.setTitle("Login with TouchID", for: .normal)
                self.loginButtonOutlet.setImage(UIImage(named: "icons8-touch-id-48"), for: .normal)
                self.loginButtonOutlet.layer.cornerRadius = 5
            case .faceID:
                self.loginButtonOutlet.setTitle("Login with FaceID", for: .normal)
                self.loginButtonOutlet.setImage(UIImage(named: "icons8-face-id-64"), for: .normal)
                self.loginButtonOutlet.layer.cornerRadius = 5
            case .none:
                print("none biometry type")
            @unknown default:
                print("error")
            }
        } else {
            self.loginButtonOutlet.setTitle("Login with Password", for: .normal)
            self.loginButtonOutlet.layer.cornerRadius = 5
        }
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "You need to be authenticate") {succes,error in
            if succes {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "authenticateSucces", sender: "Foo")
                }
            }
        }
    }

    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true)
    }
}

