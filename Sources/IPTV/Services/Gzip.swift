import Compression
import Foundation

/// Minimal gzip (RFC 1952) decompression on top of Apple's Compression framework,
/// which only speaks raw DEFLATE — the gzip member header and trailer have to be
/// stripped by hand. Enough for well-formed single-member .gz files like the
/// hosted EPG feeds; not a general-purpose gzip implementation.
enum Gzip {
    enum GzipError: Error {
        case notGzip
        case truncated
        case decompressionFailed
    }

    static func decompress(_ data: Data) throws -> Data {
        let payloadStart = try deflatePayloadStart(in: data)
        // Trailer: CRC32(4) + ISIZE(4). ISIZE = uncompressed size mod 2^32.
        guard data.endIndex - payloadStart > 8 else { throw GzipError.truncated }
        let deflated = data[payloadStart ..< data.endIndex - 8]
        let sizeBytes = data[(data.endIndex - 4)...]
        var expectedSize = 0
        for (index, byte) in sizeBytes.enumerated() {
            expectedSize |= Int(byte) << (8 * index)
        }

        let capacity = max(expectedSize, deflated.count * 4)
        let destination = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
        defer { destination.deallocate() }

        let written = deflated.withUnsafeBytes { (raw: UnsafeRawBufferPointer) -> Int in
            guard let source = raw.bindMemory(to: UInt8.self).baseAddress else { return 0 }
            return compression_decode_buffer(
                destination, capacity,
                source, raw.count,
                nil, COMPRESSION_ZLIB
            )
        }
        guard written > 0 else { throw GzipError.decompressionFailed }
        return Data(bytes: destination, count: written)
    }

    /// Walks the variable-length gzip member header (RFC 1952) and returns the
    /// index where the raw DEFLATE payload begins.
    private static func deflatePayloadStart(in data: Data) throws -> Data.Index {
        // Fixed part: magic (1f 8b), method (08 = deflate), flags, mtime(4), xfl, os.
        guard data.count > 18, data[data.startIndex] == 0x1F, data[data.startIndex + 1] == 0x8B else {
            throw GzipError.notGzip
        }
        guard data[data.startIndex + 2] == 0x08 else { throw GzipError.notGzip }
        let flags = data[data.startIndex + 3]
        var offset = data.startIndex + 10

        if flags & 0x04 != 0 { // FEXTRA: 2-byte little-endian length + payload
            guard data.count >= offset - data.startIndex + 2 else { throw GzipError.truncated }
            let extraLength = Int(data[offset]) | (Int(data[offset + 1]) << 8)
            offset += 2 + extraLength
        }
        if flags & 0x08 != 0 { // FNAME: NUL-terminated
            guard let nul = data[offset...].firstIndex(of: 0) else { throw GzipError.truncated }
            offset = nul + 1
        }
        if flags & 0x10 != 0 { // FCOMMENT: NUL-terminated
            guard let nul = data[offset...].firstIndex(of: 0) else { throw GzipError.truncated }
            offset = nul + 1
        }
        if flags & 0x02 != 0 { // FHCRC: 2 bytes
            offset += 2
        }
        return offset
    }
}
