//
//  FancyTextEntryController.swift
//  FancyTextEntryController
//
//  Created by Christian Selig on 2021-10-14.
//

import UIKit

class FancyTextEntryController: UIAlertController {
    enum TextValidation {
        case none
        case length(range: Range<Int>)
        case regex(pattern: String, lengthRange: Range<Int>)
    }
    
    private var textFieldsValidationStatus: [Int: Bool] = [:] {
        didSet {
            let areAllValid = !textFieldsValidationStatus.values.contains(false)
            addAction.isEnabled = areAllValid
        }
    }
    
    private var addAction: UIAlertAction {
        return actions.first { $0.style == .default }!
    }
    
    private var cancelAction: UIAlertAction {
        return actions.first { $0.style == .cancel }!
    }
    
    static func create(withTitle title: String, message: String? = nil, addButtonTitle: String = "Add", cancelButtonTitle: String = "Cancel", addAction: ((FancyTextEntryController) -> Void)? = nil) -> FancyTextEntryController {
        let alertController = FancyTextEntryController(title: title, message: message, preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: addButtonTitle, style: .default) { [weak alertController] action in
            guard let alertController = alertController else { return }
            addAction?(alertController)
        }
        
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: nil)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        alertController.preferredAction = addAction
        
        return alertController
    }
    
    func addTextField(withPrepopulatedText prepopulatedText: String?, placeholder: String?, validation: TextValidation, keyboardType: UIKeyboardType = .default) {
        let currentTotalTextFields = textFields?.count ?? 0
        
        addTextField { [weak self] textField in
            guard let strongSelf = self else { return }
            
            textField.text = prepopulatedText
            textField.placeholder = placeholder
            textField.keyboardType = keyboardType
            
            // In my opinion the font is a hair too small right by default
            textField.font = .preferredFont(forTextStyle: .body)
            
            textField.addAction(UIAction(handler: { action in
                strongSelf.textFieldsValidationStatus[currentTotalTextFields] = strongSelf.isTextValid(textField.text ?? "", withValidation: validation)
            }), for: .editingChanged)
            
            strongSelf.textFieldsValidationStatus[currentTotalTextFields] = strongSelf.isTextValid(textField.text ?? "", withValidation: validation)
        }
    }
    
    private func isTextValid(_ text: String, withValidation validation: TextValidation) -> Bool {
        switch validation {
        case .none:
            // Wild west
            return true
        case .length(let range):
            return range.contains(text.count)
        case .regex(let pattern, let lengthRange):
            guard lengthRange.contains(text.count) else { return false }
            
            do {
                let regularExpression = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines, .caseInsensitive])
                let firstMatch = regularExpression.firstMatch(in: text, options: [], range: NSRange(location: 0, length: (text as NSString).length))
                return firstMatch != nil
            } catch {
                fatalError("Error with passed regex: \(error)")
            }
        }
    }
    
    func text(forTextFieldAtIndex index: Int) -> String {
        return textFields?[index].text ?? ""
    }
}
