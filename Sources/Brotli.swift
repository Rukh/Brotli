//
//  Brotli.swift
//  Brotli
//
//  Created by Dmitry Gulyagin on 08.08.2021.
//

import google_brotli
import struct Foundation.Data

/// Wrapper for C lib from google/brotli repo
public class Brotli {
        
    public enum Error: Swift.Error {
        case encodeError
        case decodeError
        case dataIsTooSmallToBeEncoded
    }
    
    public struct Quality {
        internal var rawValue: Int32
        public static let `default` = Self(rawValue: BROTLI_DEFAULT_QUALITY)
        public static let min = Self(rawValue: BROTLI_MIN_QUALITY)
        public static let max = Self(rawValue: BROTLI_MAX_QUALITY)
    }
    
    public struct Window: Equatable {
        internal var rawValue: Int32
        public static let `default` = Self(rawValue: BROTLI_DEFAULT_WINDOW)
        public static let min = Self(rawValue: BROTLI_MIN_WINDOW_BITS)
        public static let max = Self(rawValue: BROTLI_MAX_WINDOW_BITS)
        public static func custom(_ value: UInt) -> Self {
            Self(rawValue: Int32(clamping: value))
        }
    }

    public struct Mode {
        internal var rawValue: BrotliEncoderMode
        public static let text = Self(rawValue: BROTLI_MODE_TEXT)
        public static let font = Self(rawValue: BROTLI_MODE_FONT)
        public static let generic = Self(rawValue: BROTLI_MODE_GENERIC)
    }
    
    public static func encoded(_ data: Data, quality: Quality = .default, window: Window = .default, mode: Mode = .generic) throws -> Data {
        guard data.count >= BROTLI_MIN_INPUT_BLOCK_BITS else {
            throw Error.dataIsTooSmallToBeEncoded
        }
        let bytes = data.withUnsafeBytes { $0.bindMemory(to: UInt8.self).baseAddress }
        var encodedSize = BrotliEncoderMaxCompressedSize(data.count)
        let encodedBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: encodedSize)
        let result = BrotliEncoderCompress(
            quality.rawValue,
            window.rawValue,
            mode.rawValue,
            data.count, bytes,
            &encodedSize, encodedBytes
        )
        guard result == BROTLI_TRUE else { throw Error.encodeError }
        return Data(
            bytesNoCopy: encodedBytes,
            count: encodedSize,
            deallocator: .free
        )
    }
    
    public static func decoded(_ data: Data) throws -> Data {
        guard !data.isEmpty else { return data }
        let bytes = data.withUnsafeBytes { $0.bindMemory(to: UInt8.self).baseAddress }
        var decodedSize = data.count * 7 // best case is 1x, worst case is 7x
        let decodedBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: decodedSize)
        let result = BrotliDecoderDecompress(
            data.count, bytes,
            &decodedSize, decodedBytes
        )
        guard result == BROTLI_DECODER_RESULT_SUCCESS else { throw Error.decodeError }
        return Data(
            bytesNoCopy: decodedBytes,
            count: decodedSize,
            deallocator: .free
        )
    }
    
    //    static let shared = Brotli()
    //
    //    private let encoder = BrotliEncoderCreateInstance(nil, nil, nil)
    //
    //    init() {
    //        BrotliEncoderSetParameter(
    //            encoder,
    //            BROTLI_PARAM_QUALITY,
    //            UInt32(BROTLI_DEFAULT_QUALITY)
    //        )
    //        BrotliEncoderSetParameter(
    //            encoder,
    //            BROTLI_PARAM_LGWIN,
    //            UInt32(BROTLI_DEFAULT_WINDOW)
    //        )
    //    }
    //
    //    deinit {
    //        BrotliEncoderDestroyInstance(encoder)
    //    }
    
}
