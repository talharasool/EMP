
import Foundation
import UIKit

protocol ImagePickerUtilsDelegate : class {
    func didFinishPickingImage(selectedImage : UIImage)
    func didTapOnCancel()
    func cameraNotAvailable()
}

class ImagePickerUtils : NSObject {
    
    private let imagePicker =  UIImagePickerController()
    private weak var pickerViewController : UIViewController!
    private weak var delegate : ImagePickerUtilsDelegate!
    
    init(delegate : ImagePickerUtilsDelegate , pickerViewController : UIViewController) {
        super.init()
        
        imagePicker.delegate = self
        self.delegate = delegate
        self.pickerViewController = pickerViewController
    }
    
    func photoFromGallery() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        pickerViewController.present(imagePicker, animated: true, completion: nil)
    }
    
    func photoFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            pickerViewController.present(imagePicker,animated: true,completion: nil)
            
        } else {
            delegate.cameraNotAvailable()
        }
    }
    
    
}

extension ImagePickerUtils :  UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
//    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//
//    }
    
   internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
      let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        delegate.didFinishPickingImage(selectedImage: selectedImage)
        pickerViewController.dismiss(animated: true, completion: nil)
    }
    
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate.didTapOnCancel()
        pickerViewController.dismiss(animated: true, completion: nil)
        
    }
}

