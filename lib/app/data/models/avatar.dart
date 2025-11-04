// 头像数据模型
class Avatar {
  final String path;
  Avatar({required this.path});

  factory Avatar.fromJson(Map<String, dynamic> json) =>
      Avatar(path: json['path'] as String);
  Map<String, dynamic> toJson() => {'path': path};
}
