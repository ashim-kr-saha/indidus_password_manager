// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LoginModel _$LoginModelFromJson(Map<String, dynamic> json) {
  return _LoginModel.fromJson(json);
}

/// @nodoc
mixin _$LoginModel {
  String? get id => throw _privateConstructorUsedError;
  int? get createdAt => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  int? get updatedAt => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  String? get password => throw _privateConstructorUsedError;
  String? get passwordHint => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  List<APIKey>? get apiKeys => throw _privateConstructorUsedError;

  /// Serializes this LoginModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginModelCopyWith<LoginModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginModelCopyWith<$Res> {
  factory $LoginModelCopyWith(
          LoginModel value, $Res Function(LoginModel) then) =
      _$LoginModelCopyWithImpl<$Res, LoginModel>;
  @useResult
  $Res call(
      {String? id,
      int? createdAt,
      String? createdBy,
      int? updatedAt,
      String? updatedBy,
      String name,
      String? note,
      String username,
      String? url,
      String? password,
      String? passwordHint,
      bool isFavorite,
      List<String>? tags,
      List<APIKey>? apiKeys});
}

/// @nodoc
class _$LoginModelCopyWithImpl<$Res, $Val extends LoginModel>
    implements $LoginModelCopyWith<$Res> {
  _$LoginModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? createdAt = freezed,
    Object? createdBy = freezed,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
    Object? name = null,
    Object? note = freezed,
    Object? username = null,
    Object? url = freezed,
    Object? password = freezed,
    Object? passwordHint = freezed,
    Object? isFavorite = null,
    Object? tags = freezed,
    Object? apiKeys = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as int?,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      password: freezed == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
      passwordHint: freezed == passwordHint
          ? _value.passwordHint
          : passwordHint // ignore: cast_nullable_to_non_nullable
              as String?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      apiKeys: freezed == apiKeys
          ? _value.apiKeys
          : apiKeys // ignore: cast_nullable_to_non_nullable
              as List<APIKey>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoginModelImplCopyWith<$Res>
    implements $LoginModelCopyWith<$Res> {
  factory _$$LoginModelImplCopyWith(
          _$LoginModelImpl value, $Res Function(_$LoginModelImpl) then) =
      __$$LoginModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      int? createdAt,
      String? createdBy,
      int? updatedAt,
      String? updatedBy,
      String name,
      String? note,
      String username,
      String? url,
      String? password,
      String? passwordHint,
      bool isFavorite,
      List<String>? tags,
      List<APIKey>? apiKeys});
}

/// @nodoc
class __$$LoginModelImplCopyWithImpl<$Res>
    extends _$LoginModelCopyWithImpl<$Res, _$LoginModelImpl>
    implements _$$LoginModelImplCopyWith<$Res> {
  __$$LoginModelImplCopyWithImpl(
      _$LoginModelImpl _value, $Res Function(_$LoginModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoginModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? createdAt = freezed,
    Object? createdBy = freezed,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
    Object? name = null,
    Object? note = freezed,
    Object? username = null,
    Object? url = freezed,
    Object? password = freezed,
    Object? passwordHint = freezed,
    Object? isFavorite = null,
    Object? tags = freezed,
    Object? apiKeys = freezed,
  }) {
    return _then(_$LoginModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as int?,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      password: freezed == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
      passwordHint: freezed == passwordHint
          ? _value.passwordHint
          : passwordHint // ignore: cast_nullable_to_non_nullable
              as String?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      apiKeys: freezed == apiKeys
          ? _value._apiKeys
          : apiKeys // ignore: cast_nullable_to_non_nullable
              as List<APIKey>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginModelImpl implements _LoginModel {
  const _$LoginModelImpl(
      {this.id,
      this.createdAt,
      this.createdBy,
      this.updatedAt,
      this.updatedBy,
      required this.name,
      this.note,
      required this.username,
      this.url,
      this.password,
      this.passwordHint,
      required this.isFavorite,
      final List<String>? tags,
      final List<APIKey>? apiKeys})
      : _tags = tags,
        _apiKeys = apiKeys;

  factory _$LoginModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginModelImplFromJson(json);

  @override
  final String? id;
  @override
  final int? createdAt;
  @override
  final String? createdBy;
  @override
  final int? updatedAt;
  @override
  final String? updatedBy;
  @override
  final String name;
  @override
  final String? note;
  @override
  final String username;
  @override
  final String? url;
  @override
  final String? password;
  @override
  final String? passwordHint;
  @override
  final bool isFavorite;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<APIKey>? _apiKeys;
  @override
  List<APIKey>? get apiKeys {
    final value = _apiKeys;
    if (value == null) return null;
    if (_apiKeys is EqualUnmodifiableListView) return _apiKeys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'LoginModel(id: $id, createdAt: $createdAt, createdBy: $createdBy, updatedAt: $updatedAt, updatedBy: $updatedBy, name: $name, note: $note, username: $username, url: $url, password: $password, passwordHint: $passwordHint, isFavorite: $isFavorite, tags: $tags, apiKeys: $apiKeys)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.passwordHint, passwordHint) ||
                other.passwordHint == passwordHint) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(other._apiKeys, _apiKeys));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      createdBy,
      updatedAt,
      updatedBy,
      name,
      note,
      username,
      url,
      password,
      passwordHint,
      isFavorite,
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_apiKeys));

  /// Create a copy of LoginModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginModelImplCopyWith<_$LoginModelImpl> get copyWith =>
      __$$LoginModelImplCopyWithImpl<_$LoginModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginModelImplToJson(
      this,
    );
  }
}

abstract class _LoginModel implements LoginModel {
  const factory _LoginModel(
      {final String? id,
      final int? createdAt,
      final String? createdBy,
      final int? updatedAt,
      final String? updatedBy,
      required final String name,
      final String? note,
      required final String username,
      final String? url,
      final String? password,
      final String? passwordHint,
      required final bool isFavorite,
      final List<String>? tags,
      final List<APIKey>? apiKeys}) = _$LoginModelImpl;

  factory _LoginModel.fromJson(Map<String, dynamic> json) =
      _$LoginModelImpl.fromJson;

  @override
  String? get id;
  @override
  int? get createdAt;
  @override
  String? get createdBy;
  @override
  int? get updatedAt;
  @override
  String? get updatedBy;
  @override
  String get name;
  @override
  String? get note;
  @override
  String get username;
  @override
  String? get url;
  @override
  String? get password;
  @override
  String? get passwordHint;
  @override
  bool get isFavorite;
  @override
  List<String>? get tags;
  @override
  List<APIKey>? get apiKeys;

  /// Create a copy of LoginModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginModelImplCopyWith<_$LoginModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

APIKey _$APIKeyFromJson(Map<String, dynamic> json) {
  return _APIKey.fromJson(json);
}

/// @nodoc
mixin _$APIKey {
  String get name => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;

  /// Serializes this APIKey to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of APIKey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $APIKeyCopyWith<APIKey> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $APIKeyCopyWith<$Res> {
  factory $APIKeyCopyWith(APIKey value, $Res Function(APIKey) then) =
      _$APIKeyCopyWithImpl<$Res, APIKey>;
  @useResult
  $Res call({String name, String value});
}

/// @nodoc
class _$APIKeyCopyWithImpl<$Res, $Val extends APIKey>
    implements $APIKeyCopyWith<$Res> {
  _$APIKeyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of APIKey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$APIKeyImplCopyWith<$Res> implements $APIKeyCopyWith<$Res> {
  factory _$$APIKeyImplCopyWith(
          _$APIKeyImpl value, $Res Function(_$APIKeyImpl) then) =
      __$$APIKeyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String value});
}

/// @nodoc
class __$$APIKeyImplCopyWithImpl<$Res>
    extends _$APIKeyCopyWithImpl<$Res, _$APIKeyImpl>
    implements _$$APIKeyImplCopyWith<$Res> {
  __$$APIKeyImplCopyWithImpl(
      _$APIKeyImpl _value, $Res Function(_$APIKeyImpl) _then)
      : super(_value, _then);

  /// Create a copy of APIKey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? value = null,
  }) {
    return _then(_$APIKeyImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$APIKeyImpl implements _APIKey {
  const _$APIKeyImpl({required this.name, required this.value});

  factory _$APIKeyImpl.fromJson(Map<String, dynamic> json) =>
      _$$APIKeyImplFromJson(json);

  @override
  final String name;
  @override
  final String value;

  @override
  String toString() {
    return 'APIKey(name: $name, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$APIKeyImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, value);

  /// Create a copy of APIKey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$APIKeyImplCopyWith<_$APIKeyImpl> get copyWith =>
      __$$APIKeyImplCopyWithImpl<_$APIKeyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$APIKeyImplToJson(
      this,
    );
  }
}

abstract class _APIKey implements APIKey {
  const factory _APIKey(
      {required final String name, required final String value}) = _$APIKeyImpl;

  factory _APIKey.fromJson(Map<String, dynamic> json) = _$APIKeyImpl.fromJson;

  @override
  String get name;
  @override
  String get value;

  /// Create a copy of APIKey
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$APIKeyImplCopyWith<_$APIKeyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
