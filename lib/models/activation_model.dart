
import 'dart:convert';

ActivationModel activationModelFromJson(String str) => ActivationModel.fromJson(json.decode(str));



class ActivationModel {
  final String? subDomain;
  final String? schoolName;
  final String? logoUrl;
  final String? schoolId;

  ActivationModel(
      {
      this.subDomain,
       this.schoolName,
       this.logoUrl,
         this.schoolId,
      });

  factory ActivationModel.fromJson(Map<String, dynamic> json) {
    return ActivationModel(
        subDomain: json['subDomain'],
        schoolName: json['schoolName'],
        logoUrl: json['logoUrl'],
        schoolId: json['schoolId']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subDomain'] = this.subDomain;
    data['schoolName'] = this.schoolName;
    data['logoUrl'] = this.logoUrl;
    data['schoolId'] = this.schoolId;
    return data;
  }
}
