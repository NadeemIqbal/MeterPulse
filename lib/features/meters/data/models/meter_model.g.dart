// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meter_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMeterModelCollection on Isar {
  IsarCollection<MeterModel> get meterModels => this.collection();
}

const MeterModelSchema = CollectionSchema(
  name: r'MeterModel',
  id: 1595014502171224007,
  properties: {
    r'billReminderFrequencyDays': PropertySchema(
      id: 0,
      name: r'billReminderFrequencyDays',
      type: IsarType.long,
    ),
    r'colorValue': PropertySchema(
      id: 1,
      name: r'colorValue',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'expectedMonthlyUnits': PropertySchema(
      id: 3,
      name: r'expectedMonthlyUnits',
      type: IsarType.double,
    ),
    r'expectedReadingDayOfMonth': PropertySchema(
      id: 4,
      name: r'expectedReadingDayOfMonth',
      type: IsarType.long,
    ),
    r'highUsageThreshold': PropertySchema(
      id: 5,
      name: r'highUsageThreshold',
      type: IsarType.double,
    ),
    r'iconCodePoint': PropertySchema(
      id: 6,
      name: r'iconCodePoint',
      type: IsarType.long,
    ),
    r'isActive': PropertySchema(id: 7, name: r'isActive', type: IsarType.bool),
    r'meterNumber': PropertySchema(
      id: 8,
      name: r'meterNumber',
      type: IsarType.string,
    ),
    r'name': PropertySchema(id: 9, name: r'name', type: IsarType.string),
    r'notes': PropertySchema(id: 10, name: r'notes', type: IsarType.string),
    r'reminderFrequencyDays': PropertySchema(
      id: 11,
      name: r'reminderFrequencyDays',
      type: IsarType.long,
    ),
    r'reminderStartDaysBefore': PropertySchema(
      id: 12,
      name: r'reminderStartDaysBefore',
      type: IsarType.long,
    ),
    r'rolloverValue': PropertySchema(
      id: 13,
      name: r'rolloverValue',
      type: IsarType.double,
    ),
    r'type': PropertySchema(
      id: 14,
      name: r'type',
      type: IsarType.string,
      enumMap: _MeterModeltypeEnumValueMap,
    ),
    r'unit': PropertySchema(id: 15, name: r'unit', type: IsarType.string),
  },

  estimateSize: _meterModelEstimateSize,
  serialize: _meterModelSerialize,
  deserialize: _meterModelDeserialize,
  deserializeProp: _meterModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'isActive': IndexSchema(
      id: 8092228061260947457,
      name: r'isActive',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isActive',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _meterModelGetId,
  getLinks: _meterModelGetLinks,
  attach: _meterModelAttach,
  version: '3.3.2',
);

int _meterModelEstimateSize(
  MeterModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.meterNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.type.name.length * 3;
  bytesCount += 3 + object.unit.length * 3;
  return bytesCount;
}

void _meterModelSerialize(
  MeterModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.billReminderFrequencyDays);
  writer.writeLong(offsets[1], object.colorValue);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeDouble(offsets[3], object.expectedMonthlyUnits);
  writer.writeLong(offsets[4], object.expectedReadingDayOfMonth);
  writer.writeDouble(offsets[5], object.highUsageThreshold);
  writer.writeLong(offsets[6], object.iconCodePoint);
  writer.writeBool(offsets[7], object.isActive);
  writer.writeString(offsets[8], object.meterNumber);
  writer.writeString(offsets[9], object.name);
  writer.writeString(offsets[10], object.notes);
  writer.writeLong(offsets[11], object.reminderFrequencyDays);
  writer.writeLong(offsets[12], object.reminderStartDaysBefore);
  writer.writeDouble(offsets[13], object.rolloverValue);
  writer.writeString(offsets[14], object.type.name);
  writer.writeString(offsets[15], object.unit);
}

MeterModel _meterModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MeterModel();
  object.billReminderFrequencyDays = reader.readLongOrNull(offsets[0]);
  object.colorValue = reader.readLongOrNull(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.expectedMonthlyUnits = reader.readDoubleOrNull(offsets[3]);
  object.expectedReadingDayOfMonth = reader.readLong(offsets[4]);
  object.highUsageThreshold = reader.readDoubleOrNull(offsets[5]);
  object.iconCodePoint = reader.readLongOrNull(offsets[6]);
  object.id = id;
  object.isActive = reader.readBool(offsets[7]);
  object.meterNumber = reader.readStringOrNull(offsets[8]);
  object.name = reader.readString(offsets[9]);
  object.notes = reader.readStringOrNull(offsets[10]);
  object.reminderFrequencyDays = reader.readLongOrNull(offsets[11]);
  object.reminderStartDaysBefore = reader.readLongOrNull(offsets[12]);
  object.rolloverValue = reader.readDoubleOrNull(offsets[13]);
  object.type =
      _MeterModeltypeValueEnumMap[reader.readStringOrNull(offsets[14])] ??
      MeterType.electricity;
  object.unit = reader.readString(offsets[15]);
  return object;
}

P _meterModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readDoubleOrNull(offset)) as P;
    case 14:
      return (_MeterModeltypeValueEnumMap[reader.readStringOrNull(offset)] ??
              MeterType.electricity)
          as P;
    case 15:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MeterModeltypeEnumValueMap = {
  r'electricity': r'electricity',
  r'gas': r'gas',
  r'water': r'water',
  r'other': r'other',
};
const _MeterModeltypeValueEnumMap = {
  r'electricity': MeterType.electricity,
  r'gas': MeterType.gas,
  r'water': MeterType.water,
  r'other': MeterType.other,
};

Id _meterModelGetId(MeterModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _meterModelGetLinks(MeterModel object) {
  return [];
}

void _meterModelAttach(IsarCollection<dynamic> col, Id id, MeterModel object) {
  object.id = id;
}

extension MeterModelQueryWhereSort
    on QueryBuilder<MeterModel, MeterModel, QWhere> {
  QueryBuilder<MeterModel, MeterModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterWhere> anyIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isActive'),
      );
    });
  }
}

extension MeterModelQueryWhere
    on QueryBuilder<MeterModel, MeterModel, QWhereClause> {
  QueryBuilder<MeterModel, MeterModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterWhereClause> isActiveEqualTo(
    bool isActive,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'isActive', value: [isActive]),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterWhereClause> isActiveNotEqualTo(
    bool isActive,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isActive',
                lower: [],
                upper: [isActive],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isActive',
                lower: [isActive],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isActive',
                lower: [isActive],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isActive',
                lower: [],
                upper: [isActive],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension MeterModelQueryFilter
    on QueryBuilder<MeterModel, MeterModel, QFilterCondition> {
  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  billReminderFrequencyDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'billReminderFrequencyDays'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  billReminderFrequencyDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'billReminderFrequencyDays'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  billReminderFrequencyDaysEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'billReminderFrequencyDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  billReminderFrequencyDaysGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'billReminderFrequencyDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  billReminderFrequencyDaysLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'billReminderFrequencyDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  billReminderFrequencyDaysBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'billReminderFrequencyDays',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  colorValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'colorValue'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  colorValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'colorValue'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> colorValueEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'colorValue', value: value),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  colorValueGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'colorValue',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  colorValueLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'colorValue',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> colorValueBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'colorValue',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  expectedMonthlyUnitsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'expectedMonthlyUnits'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  expectedMonthlyUnitsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'expectedMonthlyUnits'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  expectedMonthlyUnitsEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'expectedMonthlyUnits',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  expectedMonthlyUnitsGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'expectedMonthlyUnits',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  expectedMonthlyUnitsLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'expectedMonthlyUnits',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  expectedMonthlyUnitsBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'expectedMonthlyUnits',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  expectedReadingDayOfMonthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'expectedReadingDayOfMonth',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  expectedReadingDayOfMonthGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'expectedReadingDayOfMonth',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  expectedReadingDayOfMonthLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'expectedReadingDayOfMonth',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  expectedReadingDayOfMonthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'expectedReadingDayOfMonth',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  highUsageThresholdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'highUsageThreshold'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  highUsageThresholdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'highUsageThreshold'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  highUsageThresholdEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'highUsageThreshold',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  highUsageThresholdGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'highUsageThreshold',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  highUsageThresholdLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'highUsageThreshold',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  highUsageThresholdBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'highUsageThreshold',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  iconCodePointIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'iconCodePoint'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  iconCodePointIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'iconCodePoint'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  iconCodePointEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'iconCodePoint', value: value),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  iconCodePointGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'iconCodePoint',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  iconCodePointLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'iconCodePoint',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  iconCodePointBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'iconCodePoint',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> isActiveEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isActive', value: value),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  meterNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'meterNumber'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  meterNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'meterNumber'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  meterNumberEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'meterNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  meterNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'meterNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  meterNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'meterNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  meterNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'meterNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  meterNumberStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'meterNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  meterNumberEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'meterNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  meterNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'meterNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  meterNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'meterNumber',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  meterNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'meterNumber', value: ''),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  meterNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'meterNumber', value: ''),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> notesContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> notesMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'notes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  reminderFrequencyDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'reminderFrequencyDays'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  reminderFrequencyDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'reminderFrequencyDays'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  reminderFrequencyDaysEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'reminderFrequencyDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  reminderFrequencyDaysGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reminderFrequencyDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  reminderFrequencyDaysLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reminderFrequencyDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  reminderFrequencyDaysBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reminderFrequencyDays',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  reminderStartDaysBeforeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'reminderStartDaysBefore'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  reminderStartDaysBeforeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'reminderStartDaysBefore'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  reminderStartDaysBeforeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'reminderStartDaysBefore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  reminderStartDaysBeforeGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reminderStartDaysBefore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  reminderStartDaysBeforeLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reminderStartDaysBefore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  reminderStartDaysBeforeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reminderStartDaysBefore',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  rolloverValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'rolloverValue'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  rolloverValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'rolloverValue'),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  rolloverValueEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rolloverValue',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  rolloverValueGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rolloverValue',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  rolloverValueLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rolloverValue',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition>
  rolloverValueBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rolloverValue',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> typeEqualTo(
    MeterType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> typeGreaterThan(
    MeterType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> typeLessThan(
    MeterType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> typeBetween(
    MeterType lower,
    MeterType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> typeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> typeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'type',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> unitEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> unitGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> unitLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> unitBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'unit',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> unitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> unitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> unitContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> unitMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'unit',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> unitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'unit', value: ''),
      );
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterFilterCondition> unitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'unit', value: ''),
      );
    });
  }
}

extension MeterModelQueryObject
    on QueryBuilder<MeterModel, MeterModel, QFilterCondition> {}

extension MeterModelQueryLinks
    on QueryBuilder<MeterModel, MeterModel, QFilterCondition> {}

extension MeterModelQuerySortBy
    on QueryBuilder<MeterModel, MeterModel, QSortBy> {
  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  sortByBillReminderFrequencyDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billReminderFrequencyDays', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  sortByBillReminderFrequencyDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billReminderFrequencyDays', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  sortByExpectedMonthlyUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedMonthlyUnits', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  sortByExpectedMonthlyUnitsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedMonthlyUnits', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  sortByExpectedReadingDayOfMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedReadingDayOfMonth', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  sortByExpectedReadingDayOfMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedReadingDayOfMonth', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  sortByHighUsageThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highUsageThreshold', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  sortByHighUsageThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highUsageThreshold', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCodePoint', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByIconCodePointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCodePoint', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByMeterNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meterNumber', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByMeterNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meterNumber', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  sortByReminderFrequencyDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderFrequencyDays', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  sortByReminderFrequencyDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderFrequencyDays', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  sortByReminderStartDaysBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderStartDaysBefore', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  sortByReminderStartDaysBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderStartDaysBefore', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByRolloverValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rolloverValue', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByRolloverValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rolloverValue', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> sortByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }
}

extension MeterModelQuerySortThenBy
    on QueryBuilder<MeterModel, MeterModel, QSortThenBy> {
  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  thenByBillReminderFrequencyDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billReminderFrequencyDays', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  thenByBillReminderFrequencyDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billReminderFrequencyDays', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  thenByExpectedMonthlyUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedMonthlyUnits', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  thenByExpectedMonthlyUnitsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedMonthlyUnits', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  thenByExpectedReadingDayOfMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedReadingDayOfMonth', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  thenByExpectedReadingDayOfMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedReadingDayOfMonth', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  thenByHighUsageThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highUsageThreshold', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  thenByHighUsageThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highUsageThreshold', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCodePoint', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByIconCodePointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCodePoint', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByMeterNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meterNumber', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByMeterNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meterNumber', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  thenByReminderFrequencyDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderFrequencyDays', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  thenByReminderFrequencyDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderFrequencyDays', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  thenByReminderStartDaysBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderStartDaysBefore', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy>
  thenByReminderStartDaysBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderStartDaysBefore', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByRolloverValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rolloverValue', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByRolloverValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rolloverValue', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QAfterSortBy> thenByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }
}

extension MeterModelQueryWhereDistinct
    on QueryBuilder<MeterModel, MeterModel, QDistinct> {
  QueryBuilder<MeterModel, MeterModel, QDistinct>
  distinctByBillReminderFrequencyDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billReminderFrequencyDays');
    });
  }

  QueryBuilder<MeterModel, MeterModel, QDistinct> distinctByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorValue');
    });
  }

  QueryBuilder<MeterModel, MeterModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MeterModel, MeterModel, QDistinct>
  distinctByExpectedMonthlyUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedMonthlyUnits');
    });
  }

  QueryBuilder<MeterModel, MeterModel, QDistinct>
  distinctByExpectedReadingDayOfMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedReadingDayOfMonth');
    });
  }

  QueryBuilder<MeterModel, MeterModel, QDistinct>
  distinctByHighUsageThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'highUsageThreshold');
    });
  }

  QueryBuilder<MeterModel, MeterModel, QDistinct> distinctByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconCodePoint');
    });
  }

  QueryBuilder<MeterModel, MeterModel, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<MeterModel, MeterModel, QDistinct> distinctByMeterNumber({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'meterNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QDistinct> distinctByNotes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QDistinct>
  distinctByReminderFrequencyDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderFrequencyDays');
    });
  }

  QueryBuilder<MeterModel, MeterModel, QDistinct>
  distinctByReminderStartDaysBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderStartDaysBefore');
    });
  }

  QueryBuilder<MeterModel, MeterModel, QDistinct> distinctByRolloverValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rolloverValue');
    });
  }

  QueryBuilder<MeterModel, MeterModel, QDistinct> distinctByType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MeterModel, MeterModel, QDistinct> distinctByUnit({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unit', caseSensitive: caseSensitive);
    });
  }
}

extension MeterModelQueryProperty
    on QueryBuilder<MeterModel, MeterModel, QQueryProperty> {
  QueryBuilder<MeterModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MeterModel, int?, QQueryOperations>
  billReminderFrequencyDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billReminderFrequencyDays');
    });
  }

  QueryBuilder<MeterModel, int?, QQueryOperations> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorValue');
    });
  }

  QueryBuilder<MeterModel, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MeterModel, double?, QQueryOperations>
  expectedMonthlyUnitsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedMonthlyUnits');
    });
  }

  QueryBuilder<MeterModel, int, QQueryOperations>
  expectedReadingDayOfMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedReadingDayOfMonth');
    });
  }

  QueryBuilder<MeterModel, double?, QQueryOperations>
  highUsageThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'highUsageThreshold');
    });
  }

  QueryBuilder<MeterModel, int?, QQueryOperations> iconCodePointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconCodePoint');
    });
  }

  QueryBuilder<MeterModel, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<MeterModel, String?, QQueryOperations> meterNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'meterNumber');
    });
  }

  QueryBuilder<MeterModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<MeterModel, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<MeterModel, int?, QQueryOperations>
  reminderFrequencyDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderFrequencyDays');
    });
  }

  QueryBuilder<MeterModel, int?, QQueryOperations>
  reminderStartDaysBeforeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderStartDaysBefore');
    });
  }

  QueryBuilder<MeterModel, double?, QQueryOperations> rolloverValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rolloverValue');
    });
  }

  QueryBuilder<MeterModel, MeterType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<MeterModel, String, QQueryOperations> unitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unit');
    });
  }
}
