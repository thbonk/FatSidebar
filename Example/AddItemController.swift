//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

struct NewItem {
    static var empty: NewItem { return NewItem(title: "", image: nil) }
    var title: String = ""
    var image: NSImage?
}

class AddItemController: NSWindowController, NSTextFieldDelegate {

    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var iconImageView: NSImageView!

    private var viewModel: NewItem! {
        didSet {
            displayTitle()
            displayImage()
        }
    }

    private func displayTitle() {

        titleTextField.stringValue = viewModel.title
    }

    private func displayImage() {

        iconImageView.image = viewModel.image
    }

    @IBAction func browseImage(_ sender: Any) {

        let panel = NSOpenPanel()
        panel.allowedFileTypes = NSImage.imageTypes()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.resolvesAliases = true

        let response = panel.runModal()

        if response == NSFileHandlingPanelOKButton,
            let url = panel.urls.first,
            let image = NSImage(contentsOf: url) {

            viewModel.image = image
        }
    }

    override func controlTextDidChange(_ obj: Notification) {

        guard let textField = obj.object as? NSTextField,
            textField === self.titleTextField
            else { return }

        viewModel.title = textField.stringValue
    }

    // MARK: -
    // MARK: Showing as Sheet

    func showSheet(in hostingWindow: NSWindow, completion: @escaping (NewItem?) -> Void) {

        guard let window = self.window else { preconditionFailure("expected window outlet") }

        self.viewModel = .empty

        hostingWindow.beginSheet(window) {

            let action = Action(modalResponse: $0) ?? .cancel
            let item: NewItem? = {
                switch action {
                case .create: return self.viewModel
                case .cancel: return nil
                }
            }()

            completion(item)
        }
    }

    // MARK: Closing Sheet

    enum Action {
        case create
        case cancel

        init?(modalResponse: NSModalResponse) {

            switch modalResponse {
            case NSModalResponseOK:
                self = .create
            case NSModalResponseCancel:
                self = .cancel

            default: return nil
            }
        }

        var modalResponse: NSModalResponse {
            switch self {
            case .create: return NSModalResponseOK
            case .cancel: return NSModalResponseCancel
            }
        }
    }

    @IBAction func create(_ sender: Any) {

        closeSheet(action: .create)
    }

    @IBAction func cancel(_ sender: Any) {

        closeSheet(action: .cancel)
    }

    private func closeSheet(action: Action) {

        guard let window = self.window else { preconditionFailure("expected window outlet") }

        window.sheetParent?.endSheet(window, returnCode: action.modalResponse)
    }
}