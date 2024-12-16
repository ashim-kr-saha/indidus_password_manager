// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'financial_card_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FinancialCardModel _$FinancialCardModelFromJson(Map<String, dynamic> json) {
  return _FinancialCardModel.fromJson(json);
}

/// @nodoc
mixin _$FinancialCardModel {
  String? get id => throw _privateConstructorUsedError;
  int? get createdAt => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  int? get updatedAt => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;
  String get cardHolderName => throw _privateConstructorUsedError;
  String get cardNumber => throw _privateConstructorUsedError;
  String? get cardProviderName => throw _privateConstructorUsedError;
  String? get cardType => throw _privateConstructorUsedError;
  String? get cvv => throw _privateConstructorUsedError;
  String? get expiryDate => throw _privateConstructorUsedError;
  String? get issueDate => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String? get pin => throw _privateConstructorUsedError;
  bool? get isFavorite => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;

  /// Serializes this FinancialCardModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FinancialCardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FinancialCardModelCopyWith<FinancialCardModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FinancialCardModelCopyWith<$Res> {
  factory $FinancialCardModelCopyWith(
          FinancialCardModel value, $Res Function(FinancialCardModel) then) =
      _$FinancialCardModelCopyWithImpl<$Res, FinancialCardModel>;
  @useResult
  $Res call(
      {String? id,
      int? createdAt,
      String? createdBy,
      int? updatedAt,
      String? updatedBy,
      String cardHolderName,
      String cardNumber,
      String? cardProviderName,
      String? cardType,
      String? cvv,
      String? expiryDate,
      String? issueDate,
      String name,
      String? note,
      String? pin,
      bool? isFavorite,
      List<String>? tags});
}

/// @nodoc
class _$FinancialCardModelCopyWithImpl<$Res, $Val extends FinancialCardModel>
    implements $FinancialCardModelCopyWith<$Res> {
  _$FinancialCardModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FinancialCardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? createdAt = freezed,
    Object? createdBy = freezed,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
    Object? cardHolderName = null,
    Object? cardNumber = null,
    Object? cardProviderName = freezed,
    Object? cardType = freezed,
    Object? cvv = freezed,
    Object? expiryDate = freezed,
    Object? issueDate = freezed,
    Object? name = null,
    Object? note = freezed,
    Object? pin = freezed,
    Object? isFavorite = freezed,
    Object? tags = freezed,
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
      cardHolderName: null == cardHolderName
          ? _value.cardHolderName
          : cardHolderName // ignore: cast_nullable_to_non_nullable
              as String,
      cardNumber: null == cardNumber
          ? _value.cardNumber
          : cardNumber // ignore: cast_nullable_to_non_nullable
              as String,
      cardProviderName: freezed == cardProviderName
          ? _value.cardProviderName
          : cardProviderName // ignore: cast_nullable_to_non_nullable
              as String?,
      cardType: freezed == cardType
          ? _value.cardType
          : cardType // ignore: cast_nullable_to_non_nullable
              as String?,
      cvv: freezed == cvv
          ? _value.cvv
          : cvv // ignore: cast_nullable_to_non_nullable
              as String?,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as String?,
      issueDate: freezed == issueDate
          ? _value.issueDate
          : issueDate // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      pin: freezed == pin
          ? _value.pin
          : pin // ignore: cast_nullable_to_non_nullable
              as String?,
      isFavorite: freezed == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FinancialCardModelImplCopyWith<$Res>
    implements $FinancialCardModelCopyWith<$Res> {
  factory _$$FinancialCardModelImplCopyWith(_$FinancialCardModelImpl value,
          $Res Function(_$FinancialCardModelImpl) then) =
      __$$FinancialCardModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      int? createdAt,
      String? createdBy,
      int? updatedAt,
      String? updatedBy,
      String cardHolderName,
      String cardNumber,
      String? cardProviderName,
      String? cardType,
      String? cvv,
      String? expiryDate,
      String? issueDate,
      String name,
      String? note,
      String? pin,
      bool? isFavorite,
      List<String>? tags});
}

/// @nodoc
class __$$FinancialCardModelImplCopyWithImpl<$Res>
    extends _$FinancialCardModelCopyWithImpl<$Res, _$FinancialCardModelImpl>
    implements _$$FinancialCardModelImplCopyWith<$Res> {
  __$$FinancialCardModelImplCopyWithImpl(_$FinancialCardModelImpl _value,
      $Res Function(_$FinancialCardModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of FinancialCardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? createdAt = freezed,
    Object? createdBy = freezed,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
    Object? cardHolderName = null,
    Object? cardNumber = null,
    Object? cardProviderName = freezed,
    Object? cardType = freezed,
    Object? cvv = freezed,
    Object? expiryDate = freezed,
    Object? issueDate = freezed,
    Object? name = null,
    Object? note = freezed,
    Object? pin = freezed,
    Object? isFavorite = freezed,
    Object? tags = freezed,
  }) {
    return _then(_$FinancialCardModelImpl(
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
      cardHolderName: null == cardHolderName
          ? _value.cardHolderName
          : cardHolderName // ignore: cast_nullable_to_non_nullable
              as String,
      cardNumber: null == cardNumber
          ? _value.cardNumber
          : cardNumber // ignore: cast_nullable_to_non_nullable
              as String,
      cardProviderName: freezed == cardProviderName
          ? _value.cardProviderName
          : cardProviderName // ignore: cast_nullable_to_non_nullable
              as String?,
      cardType: freezed == cardType
          ? _value.cardType
          : cardType // ignore: cast_nullable_to_non_nullable
              as String?,
      cvv: freezed == cvv
          ? _value.cvv
          : cvv // ignore: cast_nullable_to_non_nullable
              as String?,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as String?,
      issueDate: freezed == issueDate
          ? _value.issueDate
          : issueDate // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      pin: freezed == pin
          ? _value.pin
          : pin // ignore: cast_nullable_to_non_nullable
              as String?,
      isFavorite: freezed == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FinancialCardModelImpl implements _FinancialCardModel {
  const _$FinancialCardModelImpl(
      {this.id,
      this.createdAt,
      this.createdBy,
      this.updatedAt,
      this.updatedBy,
      required this.cardHolderName,
      required this.cardNumber,
      this.cardProviderName,
      this.cardType,
      this.cvv,
      this.expiryDate,
      this.issueDate,
      required this.name,
      this.note,
      this.pin,
      this.isFavorite,
      final List<String>? tags})
      : _tags = tags;

  factory _$FinancialCardModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FinancialCardModelImplFromJson(json);

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
  final String cardHolderName;
  @override
  final String cardNumber;
  @override
  final String? cardProviderName;
  @override
  final String? cardType;
  @override
  final String? cvv;
  @override
  final String? expiryDate;
  @override
  final String? issueDate;
  @override
  final String name;
  @override
  final String? note;
  @override
  final String? pin;
  @override
  final bool? isFavorite;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'FinancialCardModel(id: $id, createdAt: $createdAt, createdBy: $createdBy, updatedAt: $updatedAt, updatedBy: $updatedBy, cardHolderName: $cardHolderName, cardNumber: $cardNumber, cardProviderName: $cardProviderName, cardType: $cardType, cvv: $cvv, expiryDate: $expiryDate, issueDate: $issueDate, name: $name, note: $note, pin: $pin, isFavorite: $isFavorite, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FinancialCardModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            (identical(other.cardHolderName, cardHolderName) ||
                other.cardHolderName == cardHolderName) &&
            (identical(other.cardNumber, cardNumber) ||
                other.cardNumber == cardNumber) &&
            (identical(other.cardProviderName, cardProviderName) ||
                other.cardProviderName == cardProviderName) &&
            (identical(other.cardType, cardType) ||
                other.cardType == cardType) &&
            (identical(other.cvv, cvv) || other.cvv == cvv) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.issueDate, issueDate) ||
                other.issueDate == issueDate) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.pin, pin) || other.pin == pin) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
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
      cardHolderName,
      cardNumber,
      cardProviderName,
      cardType,
      cvv,
      expiryDate,
      issueDate,
      name,
      note,
      pin,
      isFavorite,
      const DeepCollectionEquality().hash(_tags));

  /// Create a copy of FinancialCardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FinancialCardModelImplCopyWith<_$FinancialCardModelImpl> get copyWith =>
      __$$FinancialCardModelImplCopyWithImpl<_$FinancialCardModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FinancialCardModelImplToJson(
      this,
    );
  }
}

abstract class _FinancialCardModel implements FinancialCardModel {
  const factory _FinancialCardModel(
      {final String? id,
      final int? createdAt,
      final String? createdBy,
      final int? updatedAt,
      final String? updatedBy,
      required final String cardHolderName,
      required final String cardNumber,
      final String? cardProviderName,
      final String? cardType,
      final String? cvv,
      final String? expiryDate,
      final String? issueDate,
      required final String name,
      final String? note,
      final String? pin,
      final bool? isFavorite,
      final List<String>? tags}) = _$FinancialCardModelImpl;

  factory _FinancialCardModel.fromJson(Map<String, dynamic> json) =
      _$FinancialCardModelImpl.fromJson;

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
  String get cardHolderName;
  @override
  String get cardNumber;
  @override
  String? get cardProviderName;
  @override
  String? get cardType;
  @override
  String? get cvv;
  @override
  String? get expiryDate;
  @override
  String? get issueDate;
  @override
  String get name;
  @override
  String? get note;
  @override
  String? get pin;
  @override
  bool? get isFavorite;
  @override
  List<String>? get tags;

  /// Create a copy of FinancialCardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FinancialCardModelImplCopyWith<_$FinancialCardModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
