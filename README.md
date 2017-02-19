### GKImagePicker

Ever wanted a custom crop area for the UIImagePickerController? Now you can have it with _GKImagePicker_. Just set your custom crop area and that's it. Just 4 lines of code. If you don't set it, it uses the same crop area as the default UIImagePickerController.

### How to use it

- just drag and drop the files in under "GKClasses" & "GKImages" into your project.
- look at the sample code below.
- this project contains a sample project as well, just have a look at the implementation of `ViewController.m` 
- have fun and follow [@gekitz](http://www.twitter.com/gekitz).


### Sample Code

First create the GKImage picker:
''Swift
    let picker = GKImagePicker.init()
    picker.delegate = self
''
Specify your (starting) crop area:
''Swift
picker.cropSize = CGSize.init(width: 200, height: 200)
''
Specify if you want a resizable crop area:
''Swift
picker.hasResizeableCropArea = true
''
Then you can present the picker, in a popOver for instance: 
''
picker.imagePickerController = UIImagePickerController.init()
picker.imagePickerController!.modalPresentationStyle = .popover // or another presentation style
self.present(self.picker.imagePickerController!, animated: true, completion: nil)
if let popoverPresentationController = self.imagePicker.imagePickerController!.popoverPresentationController {
    popoverPresentationController.permittedArrowDirections = .up
    popoverPresentationController.barButtonItem = self.customBarButtonItem
''

You need to implement the delegate, if you want to use the cropped image:
''
extension YourViewController: GKImagePickerDelegate {

func imagePicker(_ imagePicker: GKImagePicker, cropped image: UIImage) {

    self.image = image // save the cropped image

    self.imagePicker.imagePickerController!.dismiss(animated: true, completion: nil) // dismiss the controller
}

}
''

This code results into the following controller + crop area:

![Sample Crop Image](https://dl.dropbox.com/u/311618/GKImageCrop/IMG_1509.PNG)

It's even possible to let the user adjust the crop area (thanks to [@pathonhauser](http://www.twitter.com/pathonhauser) for this pull request) by setting one additional property:
	     
This code results into the following controller + adjustable crop area:
![Sample Crop Image Adjustable](https://dl.dropbox.com/u/311618/GKImageCrop/IMG_2299.PNG)
### License
Under MIT. See license file for details.



    
