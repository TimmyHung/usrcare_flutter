class User {
  final String? id_token;
  final String? username;
  final String? password;
  final String? salt;
  final String? email;
  final String name;
  final String gender;
  final String birthday;
  final String? phone; // 可選
  final String city;
  final String district;
  final String neighbor;
  final String? address; // 可選
  final String? EName; // 可選
  final String? EPhone; // 可選
  final String? ERelation; // 可選

  User({
    this.id_token,
    this.username,
    this.password,
    this.salt,
    this.email,
    required this.name,
    required this.gender,
    required this.birthday,
    this.phone,
    required this.city,
    required this.district,
    required this.neighbor,
    this.address,
    this.EName,
    this.EPhone,
    this.ERelation,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_token': id_token,
      'username': username,
      'password': password,
      'salt': salt,
      'email': email,
      'name': name,
      'gender': gender,
      'birthday': birthday,
      'phone': phone,
      'city': city,
      'district': district,
      'neighbor': neighbor,
      'address': address,
      'EName': EName,
      'EPhone': EPhone,
      'ERelation': ERelation,
    };
  }
}


class OTPRequest {
  final String email;
  final String OTP;

  OTPRequest({required this.email, required this.OTP});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'OTP': OTP,
    };
  }
}

class PasswordReset {
  final String otp;
  final String newPassword;
  final String salt;

  PasswordReset({
    required this.otp,
    required this.newPassword,
    required this.salt,
  });

  Map<String, dynamic> toJson() {
    return {
      'otp': otp,
      'newPassword': newPassword,
      'salt': salt,
    };
  }
}

class TypewriterRecord {
  final String typewriter;

  TypewriterRecord({required this.typewriter});

  Map<String, dynamic> toJson() {
    return {
      'typewriter': typewriter,
    };
  }
}

class PointsDeduction {
  final String time;
  final int deductionType;
  final int deductionAmount;

  PointsDeduction({
    required this.time,
    required this.deductionType,
    required this.deductionAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'deductionType': deductionType,
      'deductionAmount': deductionAmount,
    };
  }
}

class GameRecordOcean {
  final int level;
  final String startTime;
  final String endTime;
  final String starCount;
  final int score;
  final int helpTotalCount;
  final List<String> helpRecord;

  GameRecordOcean({
    required this.level,
    required this.startTime,
    required this.endTime,
    required this.starCount,
    required this.score,
    required this.helpTotalCount,
    required this.helpRecord,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'startTime': startTime,
      'endTime': endTime,
      'starCount': starCount,
      'score': score,
      'helpTotalCount': helpTotalCount,
      'helpRecord': helpRecord,
    };
  }
}
