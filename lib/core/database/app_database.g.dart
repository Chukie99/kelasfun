// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $StudentsTable extends Students with TableInfo<$StudentsTable, Student> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nisMeta = const VerificationMeta('nis');
  @override
  late final GeneratedColumn<String> nis = GeneratedColumn<String>(
      'nis', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _classNameMeta =
      const VerificationMeta('className');
  @override
  late final GeneratedColumn<String> className = GeneratedColumn<String>(
      'class_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<String> birthDate = GeneratedColumn<String>(
      'birth_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parentNameMeta =
      const VerificationMeta('parentName');
  @override
  late final GeneratedColumn<String> parentName = GeneratedColumn<String>(
      'parent_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parentPhoneMeta =
      const VerificationMeta('parentPhone');
  @override
  late final GeneratedColumn<String> parentPhone = GeneratedColumn<String>(
      'parent_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _qrDataMeta = const VerificationMeta('qrData');
  @override
  late final GeneratedColumn<String> qrData = GeneratedColumn<String>(
      'qr_data', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nis,
        fullName,
        className,
        gender,
        birthDate,
        address,
        parentName,
        parentPhone,
        qrData,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(Insertable<Student> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nis')) {
      context.handle(
          _nisMeta, nis.isAcceptableOrUnknown(data['nis']!, _nisMeta));
    } else if (isInserting) {
      context.missing(_nisMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('class_name')) {
      context.handle(_classNameMeta,
          className.isAcceptableOrUnknown(data['class_name']!, _classNameMeta));
    } else if (isInserting) {
      context.missing(_classNameMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('parent_name')) {
      context.handle(
          _parentNameMeta,
          parentName.isAcceptableOrUnknown(
              data['parent_name']!, _parentNameMeta));
    }
    if (data.containsKey('parent_phone')) {
      context.handle(
          _parentPhoneMeta,
          parentPhone.isAcceptableOrUnknown(
              data['parent_phone']!, _parentPhoneMeta));
    }
    if (data.containsKey('qr_data')) {
      context.handle(_qrDataMeta,
          qrData.isAcceptableOrUnknown(data['qr_data']!, _qrDataMeta));
    } else if (isInserting) {
      context.missing(_qrDataMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Student map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Student(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nis: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nis'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      className: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}class_name'])!,
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])!,
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}birth_date']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      parentName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_name']),
      parentPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_phone']),
      qrData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}qr_data'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $StudentsTable createAlias(String alias) {
    return $StudentsTable(attachedDatabase, alias);
  }
}

class Student extends DataClass implements Insertable<Student> {
  final int id;
  final String nis;
  final String fullName;
  final String className;
  final String gender;
  final String? birthDate;
  final String? address;
  final String? parentName;
  final String? parentPhone;
  final String qrData;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Student(
      {required this.id,
      required this.nis,
      required this.fullName,
      required this.className,
      required this.gender,
      this.birthDate,
      this.address,
      this.parentName,
      this.parentPhone,
      required this.qrData,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nis'] = Variable<String>(nis);
    map['full_name'] = Variable<String>(fullName);
    map['class_name'] = Variable<String>(className);
    map['gender'] = Variable<String>(gender);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<String>(birthDate);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || parentName != null) {
      map['parent_name'] = Variable<String>(parentName);
    }
    if (!nullToAbsent || parentPhone != null) {
      map['parent_phone'] = Variable<String>(parentPhone);
    }
    map['qr_data'] = Variable<String>(qrData);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      id: Value(id),
      nis: Value(nis),
      fullName: Value(fullName),
      className: Value(className),
      gender: Value(gender),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      parentName: parentName == null && nullToAbsent
          ? const Value.absent()
          : Value(parentName),
      parentPhone: parentPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(parentPhone),
      qrData: Value(qrData),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Student.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Student(
      id: serializer.fromJson<int>(json['id']),
      nis: serializer.fromJson<String>(json['nis']),
      fullName: serializer.fromJson<String>(json['fullName']),
      className: serializer.fromJson<String>(json['className']),
      gender: serializer.fromJson<String>(json['gender']),
      birthDate: serializer.fromJson<String?>(json['birthDate']),
      address: serializer.fromJson<String?>(json['address']),
      parentName: serializer.fromJson<String?>(json['parentName']),
      parentPhone: serializer.fromJson<String?>(json['parentPhone']),
      qrData: serializer.fromJson<String>(json['qrData']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nis': serializer.toJson<String>(nis),
      'fullName': serializer.toJson<String>(fullName),
      'className': serializer.toJson<String>(className),
      'gender': serializer.toJson<String>(gender),
      'birthDate': serializer.toJson<String?>(birthDate),
      'address': serializer.toJson<String?>(address),
      'parentName': serializer.toJson<String?>(parentName),
      'parentPhone': serializer.toJson<String?>(parentPhone),
      'qrData': serializer.toJson<String>(qrData),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Student copyWith(
          {int? id,
          String? nis,
          String? fullName,
          String? className,
          String? gender,
          Value<String?> birthDate = const Value.absent(),
          Value<String?> address = const Value.absent(),
          Value<String?> parentName = const Value.absent(),
          Value<String?> parentPhone = const Value.absent(),
          String? qrData,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Student(
        id: id ?? this.id,
        nis: nis ?? this.nis,
        fullName: fullName ?? this.fullName,
        className: className ?? this.className,
        gender: gender ?? this.gender,
        birthDate: birthDate.present ? birthDate.value : this.birthDate,
        address: address.present ? address.value : this.address,
        parentName: parentName.present ? parentName.value : this.parentName,
        parentPhone: parentPhone.present ? parentPhone.value : this.parentPhone,
        qrData: qrData ?? this.qrData,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Student copyWithCompanion(StudentsCompanion data) {
    return Student(
      id: data.id.present ? data.id.value : this.id,
      nis: data.nis.present ? data.nis.value : this.nis,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      className: data.className.present ? data.className.value : this.className,
      gender: data.gender.present ? data.gender.value : this.gender,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      address: data.address.present ? data.address.value : this.address,
      parentName:
          data.parentName.present ? data.parentName.value : this.parentName,
      parentPhone:
          data.parentPhone.present ? data.parentPhone.value : this.parentPhone,
      qrData: data.qrData.present ? data.qrData.value : this.qrData,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Student(')
          ..write('id: $id, ')
          ..write('nis: $nis, ')
          ..write('fullName: $fullName, ')
          ..write('className: $className, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('address: $address, ')
          ..write('parentName: $parentName, ')
          ..write('parentPhone: $parentPhone, ')
          ..write('qrData: $qrData, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      nis,
      fullName,
      className,
      gender,
      birthDate,
      address,
      parentName,
      parentPhone,
      qrData,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Student &&
          other.id == this.id &&
          other.nis == this.nis &&
          other.fullName == this.fullName &&
          other.className == this.className &&
          other.gender == this.gender &&
          other.birthDate == this.birthDate &&
          other.address == this.address &&
          other.parentName == this.parentName &&
          other.parentPhone == this.parentPhone &&
          other.qrData == this.qrData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StudentsCompanion extends UpdateCompanion<Student> {
  final Value<int> id;
  final Value<String> nis;
  final Value<String> fullName;
  final Value<String> className;
  final Value<String> gender;
  final Value<String?> birthDate;
  final Value<String?> address;
  final Value<String?> parentName;
  final Value<String?> parentPhone;
  final Value<String> qrData;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const StudentsCompanion({
    this.id = const Value.absent(),
    this.nis = const Value.absent(),
    this.fullName = const Value.absent(),
    this.className = const Value.absent(),
    this.gender = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.address = const Value.absent(),
    this.parentName = const Value.absent(),
    this.parentPhone = const Value.absent(),
    this.qrData = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  StudentsCompanion.insert({
    this.id = const Value.absent(),
    required String nis,
    required String fullName,
    required String className,
    required String gender,
    this.birthDate = const Value.absent(),
    this.address = const Value.absent(),
    this.parentName = const Value.absent(),
    this.parentPhone = const Value.absent(),
    required String qrData,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : nis = Value(nis),
        fullName = Value(fullName),
        className = Value(className),
        gender = Value(gender),
        qrData = Value(qrData);
  static Insertable<Student> custom({
    Expression<int>? id,
    Expression<String>? nis,
    Expression<String>? fullName,
    Expression<String>? className,
    Expression<String>? gender,
    Expression<String>? birthDate,
    Expression<String>? address,
    Expression<String>? parentName,
    Expression<String>? parentPhone,
    Expression<String>? qrData,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nis != null) 'nis': nis,
      if (fullName != null) 'full_name': fullName,
      if (className != null) 'class_name': className,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birth_date': birthDate,
      if (address != null) 'address': address,
      if (parentName != null) 'parent_name': parentName,
      if (parentPhone != null) 'parent_phone': parentPhone,
      if (qrData != null) 'qr_data': qrData,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  StudentsCompanion copyWith(
      {Value<int>? id,
      Value<String>? nis,
      Value<String>? fullName,
      Value<String>? className,
      Value<String>? gender,
      Value<String?>? birthDate,
      Value<String?>? address,
      Value<String?>? parentName,
      Value<String?>? parentPhone,
      Value<String>? qrData,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return StudentsCompanion(
      id: id ?? this.id,
      nis: nis ?? this.nis,
      fullName: fullName ?? this.fullName,
      className: className ?? this.className,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      qrData: qrData ?? this.qrData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nis.present) {
      map['nis'] = Variable<String>(nis.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (className.present) {
      map['class_name'] = Variable<String>(className.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<String>(birthDate.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (parentName.present) {
      map['parent_name'] = Variable<String>(parentName.value);
    }
    if (parentPhone.present) {
      map['parent_phone'] = Variable<String>(parentPhone.value);
    }
    if (qrData.present) {
      map['qr_data'] = Variable<String>(qrData.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('id: $id, ')
          ..write('nis: $nis, ')
          ..write('fullName: $fullName, ')
          ..write('className: $className, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('address: $address, ')
          ..write('parentName: $parentName, ')
          ..write('parentPhone: $parentPhone, ')
          ..write('qrData: $qrData, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AttendanceTable extends Attendance
    with TableInfo<$AttendanceTable, AttendanceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _studentIdMeta =
      const VerificationMeta('studentId');
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
      'student_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES students (id)'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scanMethodMeta =
      const VerificationMeta('scanMethod');
  @override
  late final GeneratedColumn<String> scanMethod = GeneratedColumn<String>(
      'scan_method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scannedAtMeta =
      const VerificationMeta('scannedAt');
  @override
  late final GeneratedColumn<DateTime> scannedAt = GeneratedColumn<DateTime>(
      'scanned_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<String> synced = GeneratedColumn<String>(
      'synced', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('false'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, studentId, date, status, scanMethod, scannedAt, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance';
  @override
  VerificationContext validateIntegrity(Insertable<AttendanceData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(_studentIdMeta,
          studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta));
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('scan_method')) {
      context.handle(
          _scanMethodMeta,
          scanMethod.isAcceptableOrUnknown(
              data['scan_method']!, _scanMethodMeta));
    } else if (isInserting) {
      context.missing(_scanMethodMeta);
    }
    if (data.containsKey('scanned_at')) {
      context.handle(_scannedAtMeta,
          scannedAt.isAcceptableOrUnknown(data['scanned_at']!, _scannedAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {studentId, date},
      ];
  @override
  AttendanceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}student_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      scanMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scan_method'])!,
      scannedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scanned_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $AttendanceTable createAlias(String alias) {
    return $AttendanceTable(attachedDatabase, alias);
  }
}

class AttendanceData extends DataClass implements Insertable<AttendanceData> {
  final int id;
  final int studentId;
  final String date;
  final String status;
  final String scanMethod;
  final DateTime scannedAt;
  final String synced;
  const AttendanceData(
      {required this.id,
      required this.studentId,
      required this.date,
      required this.status,
      required this.scanMethod,
      required this.scannedAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['date'] = Variable<String>(date);
    map['status'] = Variable<String>(status);
    map['scan_method'] = Variable<String>(scanMethod);
    map['scanned_at'] = Variable<DateTime>(scannedAt);
    map['synced'] = Variable<String>(synced);
    return map;
  }

  AttendanceCompanion toCompanion(bool nullToAbsent) {
    return AttendanceCompanion(
      id: Value(id),
      studentId: Value(studentId),
      date: Value(date),
      status: Value(status),
      scanMethod: Value(scanMethod),
      scannedAt: Value(scannedAt),
      synced: Value(synced),
    );
  }

  factory AttendanceData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceData(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      date: serializer.fromJson<String>(json['date']),
      status: serializer.fromJson<String>(json['status']),
      scanMethod: serializer.fromJson<String>(json['scanMethod']),
      scannedAt: serializer.fromJson<DateTime>(json['scannedAt']),
      synced: serializer.fromJson<String>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'date': serializer.toJson<String>(date),
      'status': serializer.toJson<String>(status),
      'scanMethod': serializer.toJson<String>(scanMethod),
      'scannedAt': serializer.toJson<DateTime>(scannedAt),
      'synced': serializer.toJson<String>(synced),
    };
  }

  AttendanceData copyWith(
          {int? id,
          int? studentId,
          String? date,
          String? status,
          String? scanMethod,
          DateTime? scannedAt,
          String? synced}) =>
      AttendanceData(
        id: id ?? this.id,
        studentId: studentId ?? this.studentId,
        date: date ?? this.date,
        status: status ?? this.status,
        scanMethod: scanMethod ?? this.scanMethod,
        scannedAt: scannedAt ?? this.scannedAt,
        synced: synced ?? this.synced,
      );
  AttendanceData copyWithCompanion(AttendanceCompanion data) {
    return AttendanceData(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      scanMethod:
          data.scanMethod.present ? data.scanMethod.value : this.scanMethod,
      scannedAt: data.scannedAt.present ? data.scannedAt.value : this.scannedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceData(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('scanMethod: $scanMethod, ')
          ..write('scannedAt: $scannedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, studentId, date, status, scanMethod, scannedAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceData &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.date == this.date &&
          other.status == this.status &&
          other.scanMethod == this.scanMethod &&
          other.scannedAt == this.scannedAt &&
          other.synced == this.synced);
}

class AttendanceCompanion extends UpdateCompanion<AttendanceData> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<String> date;
  final Value<String> status;
  final Value<String> scanMethod;
  final Value<DateTime> scannedAt;
  final Value<String> synced;
  const AttendanceCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.scanMethod = const Value.absent(),
    this.scannedAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  AttendanceCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required String date,
    required String status,
    required String scanMethod,
    this.scannedAt = const Value.absent(),
    this.synced = const Value.absent(),
  })  : studentId = Value(studentId),
        date = Value(date),
        status = Value(status),
        scanMethod = Value(scanMethod);
  static Insertable<AttendanceData> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<String>? date,
    Expression<String>? status,
    Expression<String>? scanMethod,
    Expression<DateTime>? scannedAt,
    Expression<String>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (scanMethod != null) 'scan_method': scanMethod,
      if (scannedAt != null) 'scanned_at': scannedAt,
      if (synced != null) 'synced': synced,
    });
  }

  AttendanceCompanion copyWith(
      {Value<int>? id,
      Value<int>? studentId,
      Value<String>? date,
      Value<String>? status,
      Value<String>? scanMethod,
      Value<DateTime>? scannedAt,
      Value<String>? synced}) {
    return AttendanceCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      status: status ?? this.status,
      scanMethod: scanMethod ?? this.scanMethod,
      scannedAt: scannedAt ?? this.scannedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (scanMethod.present) {
      map['scan_method'] = Variable<String>(scanMethod.value);
    }
    if (scannedAt.present) {
      map['scanned_at'] = Variable<DateTime>(scannedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<String>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('scanMethod: $scanMethod, ')
          ..write('scannedAt: $scannedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _teacherIdMeta =
      const VerificationMeta('teacherId');
  @override
  late final GeneratedColumn<int> teacherId = GeneratedColumn<int>(
      'teacher_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, code, teacherId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(Insertable<Subject> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('teacher_id')) {
      context.handle(_teacherIdMeta,
          teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      teacherId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}teacher_id']),
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final int id;
  final String name;
  final String code;
  final int? teacherId;
  const Subject(
      {required this.id,
      required this.name,
      required this.code,
      this.teacherId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    if (!nullToAbsent || teacherId != null) {
      map['teacher_id'] = Variable<int>(teacherId);
    }
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      name: Value(name),
      code: Value(code),
      teacherId: teacherId == null && nullToAbsent
          ? const Value.absent()
          : Value(teacherId),
    );
  }

  factory Subject.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
      teacherId: serializer.fromJson<int?>(json['teacherId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
      'teacherId': serializer.toJson<int?>(teacherId),
    };
  }

  Subject copyWith(
          {int? id,
          String? name,
          String? code,
          Value<int?> teacherId = const Value.absent()}) =>
      Subject(
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
        teacherId: teacherId.present ? teacherId.value : this.teacherId,
      );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('teacherId: $teacherId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, code, teacherId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.id == this.id &&
          other.name == this.name &&
          other.code == this.code &&
          other.teacherId == this.teacherId);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> code;
  final Value<int?> teacherId;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.teacherId = const Value.absent(),
  });
  SubjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String code,
    this.teacherId = const Value.absent(),
  })  : name = Value(name),
        code = Value(code);
  static Insertable<Subject> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? code,
    Expression<int>? teacherId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (teacherId != null) 'teacher_id': teacherId,
    });
  }

  SubjectsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? code,
      Value<int?>? teacherId}) {
    return SubjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      teacherId: teacherId ?? this.teacherId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<int>(teacherId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('teacherId: $teacherId')
          ..write(')'))
        .toString();
  }
}

class $GradesTable extends Grades with TableInfo<$GradesTable, Grade> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GradesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _studentIdMeta =
      const VerificationMeta('studentId');
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
      'student_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES students (id)'));
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES subjects (id)'));
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
      'score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _examTypeMeta =
      const VerificationMeta('examType');
  @override
  late final GeneratedColumn<String> examType = GeneratedColumn<String>(
      'exam_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _semesterMeta =
      const VerificationMeta('semester');
  @override
  late final GeneratedColumn<String> semester = GeneratedColumn<String>(
      'semester', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, studentId, subjectId, score, examType, semester, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grades';
  @override
  VerificationContext validateIntegrity(Insertable<Grade> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(_studentIdMeta,
          studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta));
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('exam_type')) {
      context.handle(_examTypeMeta,
          examType.isAcceptableOrUnknown(data['exam_type']!, _examTypeMeta));
    } else if (isInserting) {
      context.missing(_examTypeMeta);
    }
    if (data.containsKey('semester')) {
      context.handle(_semesterMeta,
          semester.isAcceptableOrUnknown(data['semester']!, _semesterMeta));
    } else if (isInserting) {
      context.missing(_semesterMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {studentId, subjectId, examType, semester},
      ];
  @override
  Grade map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Grade(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}student_id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subject_id'])!,
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}score'])!,
      examType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exam_type'])!,
      semester: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}semester'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $GradesTable createAlias(String alias) {
    return $GradesTable(attachedDatabase, alias);
  }
}

class Grade extends DataClass implements Insertable<Grade> {
  final int id;
  final int studentId;
  final int subjectId;
  final double score;
  final String examType;
  final String semester;
  final DateTime createdAt;
  const Grade(
      {required this.id,
      required this.studentId,
      required this.subjectId,
      required this.score,
      required this.examType,
      required this.semester,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['subject_id'] = Variable<int>(subjectId);
    map['score'] = Variable<double>(score);
    map['exam_type'] = Variable<String>(examType);
    map['semester'] = Variable<String>(semester);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GradesCompanion toCompanion(bool nullToAbsent) {
    return GradesCompanion(
      id: Value(id),
      studentId: Value(studentId),
      subjectId: Value(subjectId),
      score: Value(score),
      examType: Value(examType),
      semester: Value(semester),
      createdAt: Value(createdAt),
    );
  }

  factory Grade.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Grade(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
      score: serializer.fromJson<double>(json['score']),
      examType: serializer.fromJson<String>(json['examType']),
      semester: serializer.fromJson<String>(json['semester']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'subjectId': serializer.toJson<int>(subjectId),
      'score': serializer.toJson<double>(score),
      'examType': serializer.toJson<String>(examType),
      'semester': serializer.toJson<String>(semester),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Grade copyWith(
          {int? id,
          int? studentId,
          int? subjectId,
          double? score,
          String? examType,
          String? semester,
          DateTime? createdAt}) =>
      Grade(
        id: id ?? this.id,
        studentId: studentId ?? this.studentId,
        subjectId: subjectId ?? this.subjectId,
        score: score ?? this.score,
        examType: examType ?? this.examType,
        semester: semester ?? this.semester,
        createdAt: createdAt ?? this.createdAt,
      );
  Grade copyWithCompanion(GradesCompanion data) {
    return Grade(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      score: data.score.present ? data.score.value : this.score,
      examType: data.examType.present ? data.examType.value : this.examType,
      semester: data.semester.present ? data.semester.value : this.semester,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Grade(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('subjectId: $subjectId, ')
          ..write('score: $score, ')
          ..write('examType: $examType, ')
          ..write('semester: $semester, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, studentId, subjectId, score, examType, semester, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Grade &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.subjectId == this.subjectId &&
          other.score == this.score &&
          other.examType == this.examType &&
          other.semester == this.semester &&
          other.createdAt == this.createdAt);
}

class GradesCompanion extends UpdateCompanion<Grade> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<int> subjectId;
  final Value<double> score;
  final Value<String> examType;
  final Value<String> semester;
  final Value<DateTime> createdAt;
  const GradesCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.score = const Value.absent(),
    this.examType = const Value.absent(),
    this.semester = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GradesCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required int subjectId,
    required double score,
    required String examType,
    required String semester,
    this.createdAt = const Value.absent(),
  })  : studentId = Value(studentId),
        subjectId = Value(subjectId),
        score = Value(score),
        examType = Value(examType),
        semester = Value(semester);
  static Insertable<Grade> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<int>? subjectId,
    Expression<double>? score,
    Expression<String>? examType,
    Expression<String>? semester,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (subjectId != null) 'subject_id': subjectId,
      if (score != null) 'score': score,
      if (examType != null) 'exam_type': examType,
      if (semester != null) 'semester': semester,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GradesCompanion copyWith(
      {Value<int>? id,
      Value<int>? studentId,
      Value<int>? subjectId,
      Value<double>? score,
      Value<String>? examType,
      Value<String>? semester,
      Value<DateTime>? createdAt}) {
    return GradesCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      subjectId: subjectId ?? this.subjectId,
      score: score ?? this.score,
      examType: examType ?? this.examType,
      semester: semester ?? this.semester,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (examType.present) {
      map['exam_type'] = Variable<String>(examType.value);
    }
    if (semester.present) {
      map['semester'] = Variable<String>(semester.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GradesCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('subjectId: $subjectId, ')
          ..write('score: $score, ')
          ..write('examType: $examType, ')
          ..write('semester: $semester, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PointsTable extends Points with TableInfo<$PointsTable, Point> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _studentIdMeta =
      const VerificationMeta('studentId');
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
      'student_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES students (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pointValueMeta =
      const VerificationMeta('pointValue');
  @override
  late final GeneratedColumn<int> pointValue = GeneratedColumn<int>(
      'point_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, studentId, type, category, pointValue, description, date, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'points';
  @override
  VerificationContext validateIntegrity(Insertable<Point> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(_studentIdMeta,
          studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta));
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('point_value')) {
      context.handle(
          _pointValueMeta,
          pointValue.isAcceptableOrUnknown(
              data['point_value']!, _pointValueMeta));
    } else if (isInserting) {
      context.missing(_pointValueMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Point map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Point(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}student_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      pointValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}point_value'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PointsTable createAlias(String alias) {
    return $PointsTable(attachedDatabase, alias);
  }
}

class Point extends DataClass implements Insertable<Point> {
  final int id;
  final int studentId;
  final String type;
  final String category;
  final int pointValue;
  final String? description;
  final String date;
  final DateTime createdAt;
  const Point(
      {required this.id,
      required this.studentId,
      required this.type,
      required this.category,
      required this.pointValue,
      this.description,
      required this.date,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    map['point_value'] = Variable<int>(pointValue);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['date'] = Variable<String>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PointsCompanion toCompanion(bool nullToAbsent) {
    return PointsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      type: Value(type),
      category: Value(category),
      pointValue: Value(pointValue),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      date: Value(date),
      createdAt: Value(createdAt),
    );
  }

  factory Point.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Point(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      pointValue: serializer.fromJson<int>(json['pointValue']),
      description: serializer.fromJson<String?>(json['description']),
      date: serializer.fromJson<String>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'pointValue': serializer.toJson<int>(pointValue),
      'description': serializer.toJson<String?>(description),
      'date': serializer.toJson<String>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Point copyWith(
          {int? id,
          int? studentId,
          String? type,
          String? category,
          int? pointValue,
          Value<String?> description = const Value.absent(),
          String? date,
          DateTime? createdAt}) =>
      Point(
        id: id ?? this.id,
        studentId: studentId ?? this.studentId,
        type: type ?? this.type,
        category: category ?? this.category,
        pointValue: pointValue ?? this.pointValue,
        description: description.present ? description.value : this.description,
        date: date ?? this.date,
        createdAt: createdAt ?? this.createdAt,
      );
  Point copyWithCompanion(PointsCompanion data) {
    return Point(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      pointValue:
          data.pointValue.present ? data.pointValue.value : this.pointValue,
      description:
          data.description.present ? data.description.value : this.description,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Point(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('pointValue: $pointValue, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, studentId, type, category, pointValue, description, date, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Point &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.type == this.type &&
          other.category == this.category &&
          other.pointValue == this.pointValue &&
          other.description == this.description &&
          other.date == this.date &&
          other.createdAt == this.createdAt);
}

class PointsCompanion extends UpdateCompanion<Point> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<String> type;
  final Value<String> category;
  final Value<int> pointValue;
  final Value<String?> description;
  final Value<String> date;
  final Value<DateTime> createdAt;
  const PointsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.pointValue = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PointsCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required String type,
    required String category,
    required int pointValue,
    this.description = const Value.absent(),
    required String date,
    this.createdAt = const Value.absent(),
  })  : studentId = Value(studentId),
        type = Value(type),
        category = Value(category),
        pointValue = Value(pointValue),
        date = Value(date);
  static Insertable<Point> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<String>? type,
    Expression<String>? category,
    Expression<int>? pointValue,
    Expression<String>? description,
    Expression<String>? date,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (pointValue != null) 'point_value': pointValue,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PointsCompanion copyWith(
      {Value<int>? id,
      Value<int>? studentId,
      Value<String>? type,
      Value<String>? category,
      Value<int>? pointValue,
      Value<String?>? description,
      Value<String>? date,
      Value<DateTime>? createdAt}) {
    return PointsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      type: type ?? this.type,
      category: category ?? this.category,
      pointValue: pointValue ?? this.pointValue,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (pointValue.present) {
      map['point_value'] = Variable<int>(pointValue.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PointsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('pointValue: $pointValue, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const Setting(
      {required this.key, required this.value, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Setting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      Setting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? key,
      Value<String>? value,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StudentsTable students = $StudentsTable(this);
  late final $AttendanceTable attendance = $AttendanceTable(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $GradesTable grades = $GradesTable(this);
  late final $PointsTable points = $PointsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [students, attendance, subjects, grades, points, settings];
}

typedef $$StudentsTableCreateCompanionBuilder = StudentsCompanion Function({
  Value<int> id,
  required String nis,
  required String fullName,
  required String className,
  required String gender,
  Value<String?> birthDate,
  Value<String?> address,
  Value<String?> parentName,
  Value<String?> parentPhone,
  required String qrData,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$StudentsTableUpdateCompanionBuilder = StudentsCompanion Function({
  Value<int> id,
  Value<String> nis,
  Value<String> fullName,
  Value<String> className,
  Value<String> gender,
  Value<String?> birthDate,
  Value<String?> address,
  Value<String?> parentName,
  Value<String?> parentPhone,
  Value<String> qrData,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$StudentsTableReferences
    extends BaseReferences<_$AppDatabase, $StudentsTable, Student> {
  $$StudentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AttendanceTable, List<AttendanceData>>
      _attendanceRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.attendance,
          aliasName:
              $_aliasNameGenerator(db.students.id, db.attendance.studentId));

  $$AttendanceTableProcessedTableManager get attendanceRefs {
    final manager = $$AttendanceTableTableManager($_db, $_db.attendance)
        .filter((f) => f.studentId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_attendanceRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GradesTable, List<Grade>> _gradesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.grades,
          aliasName: $_aliasNameGenerator(db.students.id, db.grades.studentId));

  $$GradesTableProcessedTableManager get gradesRefs {
    final manager = $$GradesTableTableManager($_db, $_db.grades)
        .filter((f) => f.studentId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_gradesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PointsTable, List<Point>> _pointsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.points,
          aliasName: $_aliasNameGenerator(db.students.id, db.points.studentId));

  $$PointsTableProcessedTableManager get pointsRefs {
    final manager = $$PointsTableTableManager($_db, $_db.points)
        .filter((f) => f.studentId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_pointsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$StudentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nis => $composableBuilder(
      column: $table.nis, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get className => $composableBuilder(
      column: $table.className, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentName => $composableBuilder(
      column: $table.parentName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentPhone => $composableBuilder(
      column: $table.parentPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get qrData => $composableBuilder(
      column: $table.qrData, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> attendanceRefs(
      Expression<bool> Function($$AttendanceTableFilterComposer f) f) {
    final $$AttendanceTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attendance,
        getReferencedColumn: (t) => t.studentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendanceTableFilterComposer(
              $db: $db,
              $table: $db.attendance,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> gradesRefs(
      Expression<bool> Function($$GradesTableFilterComposer f) f) {
    final $$GradesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.grades,
        getReferencedColumn: (t) => t.studentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GradesTableFilterComposer(
              $db: $db,
              $table: $db.grades,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> pointsRefs(
      Expression<bool> Function($$PointsTableFilterComposer f) f) {
    final $$PointsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.points,
        getReferencedColumn: (t) => t.studentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PointsTableFilterComposer(
              $db: $db,
              $table: $db.points,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$StudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nis => $composableBuilder(
      column: $table.nis, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get className => $composableBuilder(
      column: $table.className, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentName => $composableBuilder(
      column: $table.parentName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentPhone => $composableBuilder(
      column: $table.parentPhone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get qrData => $composableBuilder(
      column: $table.qrData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$StudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nis =>
      $composableBuilder(column: $table.nis, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get className =>
      $composableBuilder(column: $table.className, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get parentName => $composableBuilder(
      column: $table.parentName, builder: (column) => column);

  GeneratedColumn<String> get parentPhone => $composableBuilder(
      column: $table.parentPhone, builder: (column) => column);

  GeneratedColumn<String> get qrData =>
      $composableBuilder(column: $table.qrData, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> attendanceRefs<T extends Object>(
      Expression<T> Function($$AttendanceTableAnnotationComposer a) f) {
    final $$AttendanceTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attendance,
        getReferencedColumn: (t) => t.studentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendanceTableAnnotationComposer(
              $db: $db,
              $table: $db.attendance,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> gradesRefs<T extends Object>(
      Expression<T> Function($$GradesTableAnnotationComposer a) f) {
    final $$GradesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.grades,
        getReferencedColumn: (t) => t.studentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GradesTableAnnotationComposer(
              $db: $db,
              $table: $db.grades,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> pointsRefs<T extends Object>(
      Expression<T> Function($$PointsTableAnnotationComposer a) f) {
    final $$PointsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.points,
        getReferencedColumn: (t) => t.studentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PointsTableAnnotationComposer(
              $db: $db,
              $table: $db.points,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$StudentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StudentsTable,
    Student,
    $$StudentsTableFilterComposer,
    $$StudentsTableOrderingComposer,
    $$StudentsTableAnnotationComposer,
    $$StudentsTableCreateCompanionBuilder,
    $$StudentsTableUpdateCompanionBuilder,
    (Student, $$StudentsTableReferences),
    Student,
    PrefetchHooks Function(
        {bool attendanceRefs, bool gradesRefs, bool pointsRefs})> {
  $$StudentsTableTableManager(_$AppDatabase db, $StudentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nis = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String> className = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<String?> birthDate = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> parentName = const Value.absent(),
            Value<String?> parentPhone = const Value.absent(),
            Value<String> qrData = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              StudentsCompanion(
            id: id,
            nis: nis,
            fullName: fullName,
            className: className,
            gender: gender,
            birthDate: birthDate,
            address: address,
            parentName: parentName,
            parentPhone: parentPhone,
            qrData: qrData,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nis,
            required String fullName,
            required String className,
            required String gender,
            Value<String?> birthDate = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> parentName = const Value.absent(),
            Value<String?> parentPhone = const Value.absent(),
            required String qrData,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              StudentsCompanion.insert(
            id: id,
            nis: nis,
            fullName: fullName,
            className: className,
            gender: gender,
            birthDate: birthDate,
            address: address,
            parentName: parentName,
            parentPhone: parentPhone,
            qrData: qrData,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$StudentsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {attendanceRefs = false,
              gradesRefs = false,
              pointsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (attendanceRefs) db.attendance,
                if (gradesRefs) db.grades,
                if (pointsRefs) db.points
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (attendanceRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$StudentsTableReferences._attendanceRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$StudentsTableReferences(db, table, p0)
                                .attendanceRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.studentId == item.id),
                        typedResults: items),
                  if (gradesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$StudentsTableReferences._gradesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$StudentsTableReferences(db, table, p0).gradesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.studentId == item.id),
                        typedResults: items),
                  if (pointsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$StudentsTableReferences._pointsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$StudentsTableReferences(db, table, p0).pointsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.studentId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$StudentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StudentsTable,
    Student,
    $$StudentsTableFilterComposer,
    $$StudentsTableOrderingComposer,
    $$StudentsTableAnnotationComposer,
    $$StudentsTableCreateCompanionBuilder,
    $$StudentsTableUpdateCompanionBuilder,
    (Student, $$StudentsTableReferences),
    Student,
    PrefetchHooks Function(
        {bool attendanceRefs, bool gradesRefs, bool pointsRefs})>;
typedef $$AttendanceTableCreateCompanionBuilder = AttendanceCompanion Function({
  Value<int> id,
  required int studentId,
  required String date,
  required String status,
  required String scanMethod,
  Value<DateTime> scannedAt,
  Value<String> synced,
});
typedef $$AttendanceTableUpdateCompanionBuilder = AttendanceCompanion Function({
  Value<int> id,
  Value<int> studentId,
  Value<String> date,
  Value<String> status,
  Value<String> scanMethod,
  Value<DateTime> scannedAt,
  Value<String> synced,
});

final class $$AttendanceTableReferences
    extends BaseReferences<_$AppDatabase, $AttendanceTable, AttendanceData> {
  $$AttendanceTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias(
          $_aliasNameGenerator(db.attendance.studentId, db.students.id));

  $$StudentsTableProcessedTableManager get studentId {
    final manager = $$StudentsTableTableManager($_db, $_db.students)
        .filter((f) => f.id($_item.studentId));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AttendanceTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scanMethod => $composableBuilder(
      column: $table.scanMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scannedAt => $composableBuilder(
      column: $table.scannedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studentId,
        referencedTable: $db.students,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudentsTableFilterComposer(
              $db: $db,
              $table: $db.students,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttendanceTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scanMethod => $composableBuilder(
      column: $table.scanMethod, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scannedAt => $composableBuilder(
      column: $table.scannedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studentId,
        referencedTable: $db.students,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudentsTableOrderingComposer(
              $db: $db,
              $table: $db.students,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttendanceTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get scanMethod => $composableBuilder(
      column: $table.scanMethod, builder: (column) => column);

  GeneratedColumn<DateTime> get scannedAt =>
      $composableBuilder(column: $table.scannedAt, builder: (column) => column);

  GeneratedColumn<String> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studentId,
        referencedTable: $db.students,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudentsTableAnnotationComposer(
              $db: $db,
              $table: $db.students,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttendanceTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AttendanceTable,
    AttendanceData,
    $$AttendanceTableFilterComposer,
    $$AttendanceTableOrderingComposer,
    $$AttendanceTableAnnotationComposer,
    $$AttendanceTableCreateCompanionBuilder,
    $$AttendanceTableUpdateCompanionBuilder,
    (AttendanceData, $$AttendanceTableReferences),
    AttendanceData,
    PrefetchHooks Function({bool studentId})> {
  $$AttendanceTableTableManager(_$AppDatabase db, $AttendanceTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> studentId = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> scanMethod = const Value.absent(),
            Value<DateTime> scannedAt = const Value.absent(),
            Value<String> synced = const Value.absent(),
          }) =>
              AttendanceCompanion(
            id: id,
            studentId: studentId,
            date: date,
            status: status,
            scanMethod: scanMethod,
            scannedAt: scannedAt,
            synced: synced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int studentId,
            required String date,
            required String status,
            required String scanMethod,
            Value<DateTime> scannedAt = const Value.absent(),
            Value<String> synced = const Value.absent(),
          }) =>
              AttendanceCompanion.insert(
            id: id,
            studentId: studentId,
            date: date,
            status: status,
            scanMethod: scanMethod,
            scannedAt: scannedAt,
            synced: synced,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AttendanceTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({studentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (studentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.studentId,
                    referencedTable:
                        $$AttendanceTableReferences._studentIdTable(db),
                    referencedColumn:
                        $$AttendanceTableReferences._studentIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AttendanceTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AttendanceTable,
    AttendanceData,
    $$AttendanceTableFilterComposer,
    $$AttendanceTableOrderingComposer,
    $$AttendanceTableAnnotationComposer,
    $$AttendanceTableCreateCompanionBuilder,
    $$AttendanceTableUpdateCompanionBuilder,
    (AttendanceData, $$AttendanceTableReferences),
    AttendanceData,
    PrefetchHooks Function({bool studentId})>;
typedef $$SubjectsTableCreateCompanionBuilder = SubjectsCompanion Function({
  Value<int> id,
  required String name,
  required String code,
  Value<int?> teacherId,
});
typedef $$SubjectsTableUpdateCompanionBuilder = SubjectsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> code,
  Value<int?> teacherId,
});

final class $$SubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $SubjectsTable, Subject> {
  $$SubjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GradesTable, List<Grade>> _gradesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.grades,
          aliasName: $_aliasNameGenerator(db.subjects.id, db.grades.subjectId));

  $$GradesTableProcessedTableManager get gradesRefs {
    final manager = $$GradesTableTableManager($_db, $_db.grades)
        .filter((f) => f.subjectId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_gradesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get teacherId => $composableBuilder(
      column: $table.teacherId, builder: (column) => ColumnFilters(column));

  Expression<bool> gradesRefs(
      Expression<bool> Function($$GradesTableFilterComposer f) f) {
    final $$GradesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.grades,
        getReferencedColumn: (t) => t.subjectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GradesTableFilterComposer(
              $db: $db,
              $table: $db.grades,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get teacherId => $composableBuilder(
      column: $table.teacherId, builder: (column) => ColumnOrderings(column));
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);

  Expression<T> gradesRefs<T extends Object>(
      Expression<T> Function($$GradesTableAnnotationComposer a) f) {
    final $$GradesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.grades,
        getReferencedColumn: (t) => t.subjectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GradesTableAnnotationComposer(
              $db: $db,
              $table: $db.grades,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SubjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubjectsTable,
    Subject,
    $$SubjectsTableFilterComposer,
    $$SubjectsTableOrderingComposer,
    $$SubjectsTableAnnotationComposer,
    $$SubjectsTableCreateCompanionBuilder,
    $$SubjectsTableUpdateCompanionBuilder,
    (Subject, $$SubjectsTableReferences),
    Subject,
    PrefetchHooks Function({bool gradesRefs})> {
  $$SubjectsTableTableManager(_$AppDatabase db, $SubjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<int?> teacherId = const Value.absent(),
          }) =>
              SubjectsCompanion(
            id: id,
            name: name,
            code: code,
            teacherId: teacherId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String code,
            Value<int?> teacherId = const Value.absent(),
          }) =>
              SubjectsCompanion.insert(
            id: id,
            name: name,
            code: code,
            teacherId: teacherId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SubjectsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({gradesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (gradesRefs) db.grades],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gradesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$SubjectsTableReferences._gradesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SubjectsTableReferences(db, table, p0).gradesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.subjectId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SubjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubjectsTable,
    Subject,
    $$SubjectsTableFilterComposer,
    $$SubjectsTableOrderingComposer,
    $$SubjectsTableAnnotationComposer,
    $$SubjectsTableCreateCompanionBuilder,
    $$SubjectsTableUpdateCompanionBuilder,
    (Subject, $$SubjectsTableReferences),
    Subject,
    PrefetchHooks Function({bool gradesRefs})>;
typedef $$GradesTableCreateCompanionBuilder = GradesCompanion Function({
  Value<int> id,
  required int studentId,
  required int subjectId,
  required double score,
  required String examType,
  required String semester,
  Value<DateTime> createdAt,
});
typedef $$GradesTableUpdateCompanionBuilder = GradesCompanion Function({
  Value<int> id,
  Value<int> studentId,
  Value<int> subjectId,
  Value<double> score,
  Value<String> examType,
  Value<String> semester,
  Value<DateTime> createdAt,
});

final class $$GradesTableReferences
    extends BaseReferences<_$AppDatabase, $GradesTable, Grade> {
  $$GradesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StudentsTable _studentIdTable(_$AppDatabase db) => db.students
      .createAlias($_aliasNameGenerator(db.grades.studentId, db.students.id));

  $$StudentsTableProcessedTableManager get studentId {
    final manager = $$StudentsTableTableManager($_db, $_db.students)
        .filter((f) => f.id($_item.studentId));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SubjectsTable _subjectIdTable(_$AppDatabase db) => db.subjects
      .createAlias($_aliasNameGenerator(db.grades.subjectId, db.subjects.id));

  $$SubjectsTableProcessedTableManager get subjectId {
    final manager = $$SubjectsTableTableManager($_db, $_db.subjects)
        .filter((f) => f.id($_item.subjectId));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GradesTableFilterComposer
    extends Composer<_$AppDatabase, $GradesTable> {
  $$GradesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get examType => $composableBuilder(
      column: $table.examType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get semester => $composableBuilder(
      column: $table.semester, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studentId,
        referencedTable: $db.students,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudentsTableFilterComposer(
              $db: $db,
              $table: $db.students,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subjectId,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableFilterComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GradesTableOrderingComposer
    extends Composer<_$AppDatabase, $GradesTable> {
  $$GradesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get examType => $composableBuilder(
      column: $table.examType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get semester => $composableBuilder(
      column: $table.semester, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studentId,
        referencedTable: $db.students,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudentsTableOrderingComposer(
              $db: $db,
              $table: $db.students,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subjectId,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableOrderingComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GradesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GradesTable> {
  $$GradesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get examType =>
      $composableBuilder(column: $table.examType, builder: (column) => column);

  GeneratedColumn<String> get semester =>
      $composableBuilder(column: $table.semester, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studentId,
        referencedTable: $db.students,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudentsTableAnnotationComposer(
              $db: $db,
              $table: $db.students,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subjectId,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GradesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GradesTable,
    Grade,
    $$GradesTableFilterComposer,
    $$GradesTableOrderingComposer,
    $$GradesTableAnnotationComposer,
    $$GradesTableCreateCompanionBuilder,
    $$GradesTableUpdateCompanionBuilder,
    (Grade, $$GradesTableReferences),
    Grade,
    PrefetchHooks Function({bool studentId, bool subjectId})> {
  $$GradesTableTableManager(_$AppDatabase db, $GradesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GradesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GradesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GradesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> studentId = const Value.absent(),
            Value<int> subjectId = const Value.absent(),
            Value<double> score = const Value.absent(),
            Value<String> examType = const Value.absent(),
            Value<String> semester = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              GradesCompanion(
            id: id,
            studentId: studentId,
            subjectId: subjectId,
            score: score,
            examType: examType,
            semester: semester,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int studentId,
            required int subjectId,
            required double score,
            required String examType,
            required String semester,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              GradesCompanion.insert(
            id: id,
            studentId: studentId,
            subjectId: subjectId,
            score: score,
            examType: examType,
            semester: semester,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$GradesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({studentId = false, subjectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (studentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.studentId,
                    referencedTable:
                        $$GradesTableReferences._studentIdTable(db),
                    referencedColumn:
                        $$GradesTableReferences._studentIdTable(db).id,
                  ) as T;
                }
                if (subjectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.subjectId,
                    referencedTable:
                        $$GradesTableReferences._subjectIdTable(db),
                    referencedColumn:
                        $$GradesTableReferences._subjectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GradesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GradesTable,
    Grade,
    $$GradesTableFilterComposer,
    $$GradesTableOrderingComposer,
    $$GradesTableAnnotationComposer,
    $$GradesTableCreateCompanionBuilder,
    $$GradesTableUpdateCompanionBuilder,
    (Grade, $$GradesTableReferences),
    Grade,
    PrefetchHooks Function({bool studentId, bool subjectId})>;
typedef $$PointsTableCreateCompanionBuilder = PointsCompanion Function({
  Value<int> id,
  required int studentId,
  required String type,
  required String category,
  required int pointValue,
  Value<String?> description,
  required String date,
  Value<DateTime> createdAt,
});
typedef $$PointsTableUpdateCompanionBuilder = PointsCompanion Function({
  Value<int> id,
  Value<int> studentId,
  Value<String> type,
  Value<String> category,
  Value<int> pointValue,
  Value<String?> description,
  Value<String> date,
  Value<DateTime> createdAt,
});

final class $$PointsTableReferences
    extends BaseReferences<_$AppDatabase, $PointsTable, Point> {
  $$PointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StudentsTable _studentIdTable(_$AppDatabase db) => db.students
      .createAlias($_aliasNameGenerator(db.points.studentId, db.students.id));

  $$StudentsTableProcessedTableManager get studentId {
    final manager = $$StudentsTableTableManager($_db, $_db.students)
        .filter((f) => f.id($_item.studentId));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PointsTableFilterComposer
    extends Composer<_$AppDatabase, $PointsTable> {
  $$PointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pointValue => $composableBuilder(
      column: $table.pointValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studentId,
        referencedTable: $db.students,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudentsTableFilterComposer(
              $db: $db,
              $table: $db.students,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PointsTableOrderingComposer
    extends Composer<_$AppDatabase, $PointsTable> {
  $$PointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pointValue => $composableBuilder(
      column: $table.pointValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studentId,
        referencedTable: $db.students,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudentsTableOrderingComposer(
              $db: $db,
              $table: $db.students,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PointsTable> {
  $$PointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get pointValue => $composableBuilder(
      column: $table.pointValue, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studentId,
        referencedTable: $db.students,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudentsTableAnnotationComposer(
              $db: $db,
              $table: $db.students,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PointsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PointsTable,
    Point,
    $$PointsTableFilterComposer,
    $$PointsTableOrderingComposer,
    $$PointsTableAnnotationComposer,
    $$PointsTableCreateCompanionBuilder,
    $$PointsTableUpdateCompanionBuilder,
    (Point, $$PointsTableReferences),
    Point,
    PrefetchHooks Function({bool studentId})> {
  $$PointsTableTableManager(_$AppDatabase db, $PointsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> studentId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<int> pointValue = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PointsCompanion(
            id: id,
            studentId: studentId,
            type: type,
            category: category,
            pointValue: pointValue,
            description: description,
            date: date,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int studentId,
            required String type,
            required String category,
            required int pointValue,
            Value<String?> description = const Value.absent(),
            required String date,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PointsCompanion.insert(
            id: id,
            studentId: studentId,
            type: type,
            category: category,
            pointValue: pointValue,
            description: description,
            date: date,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PointsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({studentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (studentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.studentId,
                    referencedTable:
                        $$PointsTableReferences._studentIdTable(db),
                    referencedColumn:
                        $$PointsTableReferences._studentIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PointsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PointsTable,
    Point,
    $$PointsTableFilterComposer,
    $$PointsTableOrderingComposer,
    $$PointsTableAnnotationComposer,
    $$PointsTableCreateCompanionBuilder,
    $$PointsTableUpdateCompanionBuilder,
    (Point, $$PointsTableReferences),
    Point,
    PrefetchHooks Function({bool studentId})>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db, _db.students);
  $$AttendanceTableTableManager get attendance =>
      $$AttendanceTableTableManager(_db, _db.attendance);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$GradesTableTableManager get grades =>
      $$GradesTableTableManager(_db, _db.grades);
  $$PointsTableTableManager get points =>
      $$PointsTableTableManager(_db, _db.points);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
