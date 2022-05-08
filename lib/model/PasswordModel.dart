import 'dart:convert';

Password passwordFromJson(String str) {
  final jsonData = json.decode(str);
  return Password.fromJson(jsonData);
}

String clientToJson(Password data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Password {
  late int id;
  late String userName;
  late String appName;
  late String password;
  late String icon;
  late String color;

  Password({
    required this.id,
    required this.icon,
    required this.color,
    required this.userName,
    required this.appName,
    required this.password,
  });

  Password.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    appName = json['app_name'];
    password = json['password'];
    userName = json['user_name'];
    icon = json['icon'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['app_name'] = appName;
    data['password'] = password;
    data['user_name'] = userName;
    data['icon'] = icon;
    data['color'] = color;
    return data;
  }
}
