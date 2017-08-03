//
//  ViewController.swift
//  FriesOrNot2
//
//  Created by Madoka CHIYODA on 2017/08/02.
//  Copyright © 2017 Madoka Chiyoda. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var service = CustomVisionService()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func selectImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected an image, but was provided \(info)")
        }
        
        photoImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
        
        resultLabel.text = ""
        self.activityIndicator.startAnimating()
        
        let imageData = UIImageJPEGRepresentation(selectedImage, 0.8)!
        service.predict(image: imageData, completion: { (result: CustomVisionResult?, error: Error?) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                if let error = error {
                    self.resultLabel.text = error.localizedDescription
                } else if let result = result {
                    let prediction = result.Predictions[0]
                    let probabilityLabel = String(format: "%.1f", prediction.Probability * 100)
                    self.resultLabel.text = "\(probabilityLabel)% sure this is \(prediction.Tag)"
                }
            }
        })
    }
}

