/**
 *  https://github.com/tadija/AEConsole
 *  Copyright (c) Marko Tadić 2016-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import UIKit
import AELog

internal final class Brain: NSObject {
    
    // MARK: - Outlets
    
    internal var console: View!
    
    // MARK: - Properties
    
    internal let settings: Settings

    internal var lines = [CustomStringConvertible]()
    internal var filteredLines = [CustomStringConvertible]()
    
    internal var contentWidth: CGFloat = 0.0
    
    internal var filterText: String? {
        didSet {
            isFilterActive = !isEmpty(filterText)
        }
    }
    
    internal var isFilterActive = false {
        didSet {
            updateFilter()
            updateInterfaceIfNeeded()
        }
    }

    // MARK: Init

    internal init(with settings: Settings) {
        self.settings = settings
    }
    
    // MARK: - API

    internal func configureConsole(in window: UIWindow?) {
        guard let window = window else { return }
        console = createConsoleView(in: window)
        console.tableView.dataSource = self
        console.tableView.delegate = self
        console.textField.delegate = self
    }
    
    internal func addLogLine(_ line: CustomStringConvertible) {
        calculateContentWidth(for: line)
        updateFilteredLines(with: line)
        lines.append(line)
        updateInterfaceIfNeeded()
    }
    
    internal func isEmpty(_ text: String?) -> Bool {
        guard let text = text else { return true }
        let characterSet = CharacterSet.whitespacesAndNewlines
        let isTextEmpty = text.trimmingCharacters(in: characterSet).isEmpty
        return isTextEmpty
    }
    
    // MARK: - Actions
    
    internal func clearLog() {
        lines.removeAll()
        filteredLines.removeAll()
        updateInterfaceIfNeeded()
    }
    
    internal func exportLogFile(completion: @escaping (() throws -> URL) -> Void) {
        DispatchQueue.global().async { [unowned self] in
            completion {
                try self.writeLogFile()
            }
        }
    }

    private func writeLogFile() throws -> URL {
        let stringLines = lines.map({ $0.description })
        let log = stringLines.joined(separator: "\n")

        if isEmpty(log) {
            aelog("Log is empty, nothing to export here.")
            throw NSError(domain: "net.tadija.AEConsole/Brain", code: 0, userInfo: nil)
        } else {
            do {
                let fileURL = logFileURL
                try log.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                aelog("Log is exported to path: \(fileURL)")
                return fileURL
            } catch {
                aelog("Log exporting failed with error: \(error)")
                throw error
            }
        }
    }

    private var logFileURL: URL {
        let filename = "AELog_\(Date().timeIntervalSince1970).txt"
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsURL = URL(fileURLWithPath: documentsPath)
        let fileURL = documentsURL.appendingPathComponent(filename)
        return fileURL
    }
    
}

extension Brain {
    
    // MARK: - Helpers
    
    fileprivate func updateFilter() {
        if isFilterActive {
            applyFilter()
        } else {
            clearFilter()
        }
    }
    
    private func applyFilter() {
        guard let filter = filterText else { return }
        aelog("Filter Lines [\(isFilterActive)] - <\(filter)>")
        let filtered = lines.filter({ $0.description.localizedCaseInsensitiveContains(filter) })
        filteredLines = filtered
    }
    
    private func clearFilter() {
        aelog("Filter Lines [\(isFilterActive)]")
        filteredLines.removeAll()
    }
    
    fileprivate func updateInterfaceIfNeeded() {
        if console.isOnScreen {
            console.updateUI()
        }
    }
    
    fileprivate func createConsoleView(in window: UIWindow) -> View {
        let view = View()
        
        view.frame = window.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isOnScreen = false
        window.addSubview(view)
        
        return view
    }
    
    fileprivate func calculateContentWidth(for line: CustomStringConvertible) {
        let calculatedLineWidth = getWidth(for: line)
        if calculatedLineWidth > contentWidth {
            contentWidth = calculatedLineWidth
        }
    }
    
    fileprivate func updateFilteredLines(with line: CustomStringConvertible) {
        if isFilterActive {
            guard let filter = filterText else { return }
            if line.description.contains(filter) {
                filteredLines.append(line)
            }
        }
    }
    
    private func getWidth(for line: CustomStringConvertible) -> CGFloat {
        let text = line.description
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: settings.estimatedRowHeight)
        let options = NSStringDrawingOptions.usesLineFragmentOrigin
        let attributes = [NSAttributedString.Key.font : settings.consoleFont]
        let nsText = text as NSString
        let size = nsText.boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
        let width = size.width
        return width
    }
    
}

extension Brain: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = isFilterActive ? filteredLines : lines
        return rows.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier) as! Cell

        let rows = isFilterActive ? filteredLines : lines
        let logLine = rows[indexPath.row]
        cell.label.text = logLine.description

        return cell
    }

    // MARK: - UIScrollViewDelegate
    
    internal func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            console.currentOffsetX = scrollView.contentOffset.x
        }
    }
    
    internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        console.currentOffsetX = scrollView.contentOffset.x
    }
    
}

extension Brain: UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if !isEmpty(textField.text) {
            filterText = textField.text
        }
        return true
    }
    
}
