import Flutter
import UIKit
import AVFoundation

/// 视频缩略图插件
/// 用于从本地视频生成首帧缩略图
public class VideoThumbnailPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.glasso/video_thumbnail",
            binaryMessenger: registrar.messenger()
        )
        let instance = VideoThumbnailPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getThumbnail":
            guard let args = call.arguments as? [String: Any],
                  let videoPath = args["videoPath"] as? String else {
                result(FlutterError(
                    code: "INVALID_ARGS",
                    message: "videoPath is required",
                    details: nil
                ))
                return
            }
            
            let maxWidth = args["maxWidth"] as? Int ?? 400
            
            // 异步获取缩略图
            DispatchQueue.global(qos: .userInitiated).async {
                self.generateThumbnail(
                    videoPath: videoPath,
                    maxWidth: maxWidth,
                    result: result
                )
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func generateThumbnail(
        videoPath: String,
        maxWidth: Int,
        result: @escaping FlutterResult
    ) {
        // 获取 Flutter asset 的真实路径
        let assetPath: String
        if videoPath.hasPrefix("assets/") {
            // 从 asset 路径转换为实际路径
            let key = FlutterDartProject.lookupKey(forAsset: videoPath)
            guard let path = Bundle.main.path(forResource: key, ofType: nil) else {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "FILE_NOT_FOUND",
                        message: "Video file not found: \(videoPath)",
                        details: nil
                    ))
                }
                return
            }
            assetPath = path
        } else {
            assetPath = videoPath
        }
        
        let videoURL = URL(fileURLWithPath: assetPath)
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        // 设置精确时间
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceBefore = .zero
        imageGenerator.requestedTimeToleranceAfter = .zero
        
        do {
            // 获取第一帧（时间为0）
            let cgImage = try imageGenerator.copyCGImage(
                at: CMTime(seconds: 0, preferredTimescale: 600),
                actualTime: nil
            )
            
            // 转换为 UIImage
            var image = UIImage(cgImage: cgImage)
            
            // 调整大小以优化内存
            if image.size.width > CGFloat(maxWidth) {
                let scale = CGFloat(maxWidth) / image.size.width
                let newSize = CGSize(
                    width: CGFloat(maxWidth),
                    height: image.size.height * scale
                )
                image = self.resizeImage(image: image, targetSize: newSize)
            }
            
            // 转换为 PNG 数据
            guard let imageData = image.pngData() else {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "ENCODE_ERROR",
                        message: "Failed to encode image to PNG",
                        details: nil
                    ))
                }
                return
            }
            
            // 返回图片数据
            DispatchQueue.main.async {
                result(FlutterStandardTypedData(bytes: imageData))
            }
            
        } catch {
            DispatchQueue.main.async {
                result(FlutterError(
                    code: "GENERATION_ERROR",
                    message: "Failed to generate thumbnail: \(error.localizedDescription)",
                    details: nil
                ))
            }
        }
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
}

