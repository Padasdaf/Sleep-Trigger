//
//  RemoteLogBundler.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation
import Compression

enum RemoteLogBundler {
    /// Creates a .zip-like archive (simple .gz of a combined payload) you can share.
    static func bundle() async -> URL? {
        // Gather history
        let history = await HistoryStore.shared.all()
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted]
        let historyData = (try? enc.encode(history)) ?? Data()

        // Ring log (watch writes this path; may not exist on phone)
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupID.suite)!
        let ringURL = container.appendingPathComponent("sleep_ringlog.bin")
        let ringData = (try? Data(contentsOf: ringURL)) ?? Data()

        // Combine
        var payload = Data()
        payload.append("----HISTORY JSON----\n".data(using: .utf8)!)
        payload.append(historyData)
        payload.append("\n----RINGLOG BIN----\n".data(using: .utf8)!)
        payload.append(ringData)

        // Gzip it
        guard let gz = gzip(payload) else { return nil }
        let out = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("sleep_bundle.gz")
        do { try gz.write(to: out, options: .atomic); return out } catch { return nil }
    }

    private static func gzip(_ data: Data) -> Data? {
        var dst = Data()
        data.withUnsafeBytes { srcPtr in
            let src = srcPtr.bindMemory(to: UInt8.self).baseAddress!
            let dstBuff = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count + 512)
            defer { dstBuff.deallocate() }
            let outSize = compression_encode_buffer(
                dstBuff, data.count + 512,
                src, data.count,
                nil,
                COMPRESSION_ZLIB)
            if outSize > 0 { dst.append(dstBuff, count: outSize) }
        }
        return dst
    }
}
