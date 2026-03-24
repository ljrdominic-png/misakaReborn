//
//  KRWKFSManager.swift
//  misaka
//

import Combine
import Foundation

final class KRWKFSManager: ObservableObject {
    static let shared = KRWKFSManager()

    @Published var isReady: Bool = false
    @Published var initLog: String = ""

    private init() {}

    /// Calls `kfs_init` on a background queue; `completion` is called on the main thread.
    func initialize(completion: ((Bool) -> Void)? = nil) {
        kfs_set_log_callback { msg in
            guard let msg else { return }
            let s = String(cString: msg)
            DispatchQueue.main.async {
                KRWKFSManager.shared.initLog += "[KFS] " + s + "\n"
                KRWExploitManager.shared.log += "[KFS] " + s + "\n"
            }
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let r = kfs_init()
            DispatchQueue.main.async {
                self.isReady = (r == 0 && kfs_is_ready())
                if self.isReady {
                    KRWExploitManager.shared.log += "\n=== KFS READY ===\n"
                } else {
                    KRWExploitManager.shared.log += "\n=== KFS INIT FAILED ===\n"
                }
                completion?(self.isReady)
            }
        }
    }

    func listDirectory(path: String) -> [(name: String, isDir: Bool)]? {
        guard isReady else { return nil }
        var ptr: UnsafeMutablePointer<kfs_entry_t>?
        var count: Int32 = 0
        let r = kfs_listdir(path, &ptr, &count)
        guard r == 0, let entries = ptr else { return nil }
        defer { kfs_free_listing(entries) }

        var items: [(String, Bool)] = []
        for i in 0..<Int(count) {
            let e = entries[i]
            let name = withUnsafePointer(to: e.name) { p in
                p.withMemoryRebound(to: CChar.self, capacity: 256) { String(cString: $0) }
            }
            items.append((name, e.d_type == 4))
        }
        return items.sorted { $0.0.lowercased() < $1.0.lowercased() }
    }

    func readFile(path: String, maxSize: Int = 512 * 1024) -> Data? {
        guard isReady else { return nil }
        let fsz = kfs_file_size(path)
        if fsz <= 0 { return nil }
        let toRead = min(Int(fsz), maxSize)
        var buf = [UInt8](repeating: 0, count: toRead)
        let n = kfs_read(path, &buf, toRead, 0)
        if n <= 0 { return nil }
        return Data(buf.prefix(Int(n)))
    }

    func writeFile(path: String, data: Data) -> Bool {
        guard isReady else { return false }
        return data.withUnsafeBytes { ptr in
            let n = kfs_write(path, ptr.baseAddress, data.count, 0)
            return n > 0
        }
    }

    func fileSize(path: String) -> Int64 {
        guard isReady else { return -1 }
        return kfs_file_size(path)
    }

    func overwriteFile(target: String, withBundledFont fontName: String) -> Bool {
        guard isReady else { return false }
        let fontURL: URL? =
            Bundle.main.url(forResource: fontName, withExtension: "ttf", subdirectory: "Fonts")
            ?? Bundle.main.url(forResource: fontName, withExtension: "ttf")
        guard let fontURL else {
            KRWExploitManager.shared.log += "[KFS] Font '\(fontName).ttf' not found in bundle\n"
            return false
        }
        KRWExploitManager.shared.log += "[KFS] Using font: \(fontURL.path)\n"
        let r = kfs_overwrite_file(target, fontURL.path)
        return r == 0
    }

    /// Overwrite a kernel-visible target path using a readable file on disk (sandbox / app container). Uses `kfs_overwrite_file`.
    func overwriteFileFromLocalPath(target: String, sourcePath: String) -> Bool {
        guard isReady else { return false }
        guard FileManager.default.fileExists(atPath: sourcePath) else { return false }
        let r = kfs_overwrite_file(target, sourcePath)
        return r == 0
    }

    func overwriteFileWithData(target: String, data: Data) -> Bool {
        guard isReady else { return false }
        let tmp = NSTemporaryDirectory() + "kfs_src_\(arc4random()).bin"
        do { try data.write(to: URL(fileURLWithPath: tmp)) } catch { return false }
        let ok = overwriteFileFromLocalPath(target: target, sourcePath: tmp)
        try? FileManager.default.removeItem(atPath: tmp)
        return ok
    }

    static let availableFonts: [(name: String, file: String)] = [
        ("Comic Sans MS", "Comic Sans MS"),
        ("DejaVu Sans Condensed", "DejaVuSansCondensed"),
        ("DejaVu Serif", "DejaVuSerif"),
        ("DejaVu Sans Mono", "DejaVuSansMono"),
        ("Fira Sans", "FiraSans-Regular"),
        ("Go Regular", "Go-Regular"),
        ("Go Mono", "Go-Mono"),
        ("Segoe UI", "segoeui"),
        ("Chococooky", "Chococooky"),
        ("Magic", "magic"),
    ]

    static let targetFontPath = "/System/Library/Fonts/Core/SFUI.ttf"
}
