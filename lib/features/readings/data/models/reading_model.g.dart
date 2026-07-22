// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReadingModelCollection on Isar {
  IsarCollection<ReadingModel> get readingModels => this.collection();
}

const ReadingModelSchema = CollectionSchema(
  name: r'ReadingModel',
  id: -6695297047613984393,
  properties: {
    r'billingCycleId': PropertySchema(
      id: 0,
      name: r'billingCycleId',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isManualEntry': PropertySchema(
      id: 2,
      name: r'isManualEntry',
      type: IsarType.bool,
    ),
    r'meterId': PropertySchema(id: 3, name: r'meterId', type: IsarType.long),
    r'notes': PropertySchema(id: 4, name: r'notes', type: IsarType.string),
    r'ocrConfidence': PropertySchema(
      id: 5,
      name: r'ocrConfidence',
      type: IsarType.double,
    ),
    r'ocrRawText': PropertySchema(
      id: 6,
      name: r'ocrRawText',
      type: IsarType.string,
    ),
    r'photoPath': PropertySchema(
      id: 7,
      name: r'photoPath',
      type: IsarType.string,
    ),
    r'readingDate': PropertySchema(
      id: 8,
      name: r'readingDate',
      type: IsarType.dateTime,
    ),
    r'readingValue': PropertySchema(
      id: 9,
      name: r'readingValue',
      type: IsarType.double,
    ),
  },

  estimateSize: _readingModelEstimateSize,
  serialize: _readingModelSerialize,
  deserialize: _readingModelDeserialize,
  deserializeProp: _readingModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'meterId_readingDate': IndexSchema(
      id: -101806150484735656,
      name: r'meterId_readingDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'meterId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'readingDate',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'billingCycleId': IndexSchema(
      id: -6274544983310915715,
      name: r'billingCycleId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'billingCycleId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _readingModelGetId,
  getLinks: _readingModelGetLinks,
  attach: _readingModelAttach,
  version: '3.3.2',
);

int _readingModelEstimateSize(
  ReadingModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ocrRawText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.photoPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _readingModelSerialize(
  ReadingModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.billingCycleId);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeBool(offsets[2], object.isManualEntry);
  writer.writeLong(offsets[3], object.meterId);
  writer.writeString(offsets[4], object.notes);
  writer.writeDouble(offsets[5], object.ocrConfidence);
  writer.writeString(offsets[6], object.ocrRawText);
  writer.writeString(offsets[7], object.photoPath);
  writer.writeDateTime(offsets[8], object.readingDate);
  writer.writeDouble(offsets[9], object.readingValue);
}

ReadingModel _readingModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReadingModel();
  object.billingCycleId = reader.readLongOrNull(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.isManualEntry = reader.readBool(offsets[2]);
  object.meterId = reader.readLong(offsets[3]);
  object.notes = reader.readStringOrNull(offsets[4]);
  object.ocrConfidence = reader.readDoubleOrNull(offsets[5]);
  object.ocrRawText = reader.readStringOrNull(offsets[6]);
  object.photoPath = reader.readStringOrNull(offsets[7]);
  object.readingDate = reader.readDateTime(offsets[8]);
  object.readingValue = reader.readDouble(offsets[9]);
  return object;
}

P _readingModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _readingModelGetId(ReadingModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _readingModelGetLinks(ReadingModel object) {
  return [];
}

void _readingModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  ReadingModel object,
) {
  object.id = id;
}

extension ReadingModelQueryWhereSort
    on QueryBuilder<ReadingModel, ReadingModel, QWhere> {
  QueryBuilder<ReadingModel, ReadingModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhere>
  anyMeterIdReadingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'meterId_readingDate'),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhere> anyBillingCycleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'billingCycleId'),
      );
    });
  }
}

extension ReadingModelQueryWhere
    on QueryBuilder<ReadingModel, ReadingModel, QWhereClause> {
  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause>
  meterIdEqualToAnyReadingDate(int meterId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'meterId_readingDate',
          value: [meterId],
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause>
  meterIdNotEqualToAnyReadingDate(int meterId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId_readingDate',
                lower: [],
                upper: [meterId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId_readingDate',
                lower: [meterId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId_readingDate',
                lower: [meterId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId_readingDate',
                lower: [],
                upper: [meterId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause>
  meterIdGreaterThanAnyReadingDate(int meterId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'meterId_readingDate',
          lower: [meterId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause>
  meterIdLessThanAnyReadingDate(int meterId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'meterId_readingDate',
          lower: [],
          upper: [meterId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause>
  meterIdBetweenAnyReadingDate(
    int lowerMeterId,
    int upperMeterId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'meterId_readingDate',
          lower: [lowerMeterId],
          includeLower: includeLower,
          upper: [upperMeterId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause>
  meterIdReadingDateEqualTo(int meterId, DateTime readingDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'meterId_readingDate',
          value: [meterId, readingDate],
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause>
  meterIdEqualToReadingDateNotEqualTo(int meterId, DateTime readingDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId_readingDate',
                lower: [meterId],
                upper: [meterId, readingDate],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId_readingDate',
                lower: [meterId, readingDate],
                includeLower: false,
                upper: [meterId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId_readingDate',
                lower: [meterId, readingDate],
                includeLower: false,
                upper: [meterId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId_readingDate',
                lower: [meterId],
                upper: [meterId, readingDate],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause>
  meterIdEqualToReadingDateGreaterThan(
    int meterId,
    DateTime readingDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'meterId_readingDate',
          lower: [meterId, readingDate],
          includeLower: include,
          upper: [meterId],
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause>
  meterIdEqualToReadingDateLessThan(
    int meterId,
    DateTime readingDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'meterId_readingDate',
          lower: [meterId],
          upper: [meterId, readingDate],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause>
  meterIdEqualToReadingDateBetween(
    int meterId,
    DateTime lowerReadingDate,
    DateTime upperReadingDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'meterId_readingDate',
          lower: [meterId, lowerReadingDate],
          includeLower: includeLower,
          upper: [meterId, upperReadingDate],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause>
  billingCycleIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'billingCycleId', value: [null]),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause>
  billingCycleIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'billingCycleId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause>
  billingCycleIdEqualTo(int? billingCycleId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'billingCycleId',
          value: [billingCycleId],
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause>
  billingCycleIdNotEqualTo(int? billingCycleId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'billingCycleId',
                lower: [],
                upper: [billingCycleId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'billingCycleId',
                lower: [billingCycleId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'billingCycleId',
                lower: [billingCycleId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'billingCycleId',
                lower: [],
                upper: [billingCycleId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause>
  billingCycleIdGreaterThan(int? billingCycleId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'billingCycleId',
          lower: [billingCycleId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause>
  billingCycleIdLessThan(int? billingCycleId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'billingCycleId',
          lower: [],
          upper: [billingCycleId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterWhereClause>
  billingCycleIdBetween(
    int? lowerBillingCycleId,
    int? upperBillingCycleId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'billingCycleId',
          lower: [lowerBillingCycleId],
          includeLower: includeLower,
          upper: [upperBillingCycleId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ReadingModelQueryFilter
    on QueryBuilder<ReadingModel, ReadingModel, QFilterCondition> {
  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  billingCycleIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'billingCycleId'),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  billingCycleIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'billingCycleId'),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  billingCycleIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'billingCycleId', value: value),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  billingCycleIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'billingCycleId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  billingCycleIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'billingCycleId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  billingCycleIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'billingCycleId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
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

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  createdAtBetween(
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

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  isManualEntryEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isManualEntry', value: value),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  meterIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'meterId', value: value),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  meterIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'meterId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  meterIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'meterId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  meterIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'meterId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition> notesEqualTo(
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

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  notesGreaterThan(
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

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition> notesLessThan(
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

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition> notesBetween(
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

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  notesStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition> notesEndsWith(
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

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition> notesContains(
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

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition> notesMatches(
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

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  ocrConfidenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'ocrConfidence'),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  ocrConfidenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'ocrConfidence'),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  ocrConfidenceEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ocrConfidence',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  ocrConfidenceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ocrConfidence',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  ocrConfidenceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ocrConfidence',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  ocrConfidenceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ocrConfidence',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  ocrRawTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'ocrRawText'),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  ocrRawTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'ocrRawText'),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  ocrRawTextEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ocrRawText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  ocrRawTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ocrRawText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  ocrRawTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ocrRawText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  ocrRawTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ocrRawText',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  ocrRawTextStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'ocrRawText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  ocrRawTextEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'ocrRawText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  ocrRawTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'ocrRawText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  ocrRawTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'ocrRawText',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  ocrRawTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ocrRawText', value: ''),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  ocrRawTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ocrRawText', value: ''),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  photoPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'photoPath'),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  photoPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'photoPath'),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  photoPathEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'photoPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  photoPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'photoPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  photoPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'photoPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  photoPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'photoPath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  photoPathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'photoPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  photoPathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'photoPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  photoPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'photoPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  photoPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'photoPath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  photoPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'photoPath', value: ''),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  photoPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'photoPath', value: ''),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  readingDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'readingDate', value: value),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  readingDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'readingDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  readingDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'readingDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  readingDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'readingDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  readingValueEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'readingValue',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  readingValueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'readingValue',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  readingValueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'readingValue',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterFilterCondition>
  readingValueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'readingValue',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }
}

extension ReadingModelQueryObject
    on QueryBuilder<ReadingModel, ReadingModel, QFilterCondition> {}

extension ReadingModelQueryLinks
    on QueryBuilder<ReadingModel, ReadingModel, QFilterCondition> {}

extension ReadingModelQuerySortBy
    on QueryBuilder<ReadingModel, ReadingModel, QSortBy> {
  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy>
  sortByBillingCycleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingCycleId', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy>
  sortByBillingCycleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingCycleId', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> sortByIsManualEntry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isManualEntry', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy>
  sortByIsManualEntryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isManualEntry', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> sortByMeterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meterId', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> sortByMeterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meterId', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> sortByOcrConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrConfidence', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy>
  sortByOcrConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrConfidence', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> sortByOcrRawText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrRawText', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy>
  sortByOcrRawTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrRawText', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> sortByPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> sortByPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> sortByReadingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingDate', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy>
  sortByReadingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingDate', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> sortByReadingValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingValue', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy>
  sortByReadingValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingValue', Sort.desc);
    });
  }
}

extension ReadingModelQuerySortThenBy
    on QueryBuilder<ReadingModel, ReadingModel, QSortThenBy> {
  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy>
  thenByBillingCycleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingCycleId', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy>
  thenByBillingCycleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingCycleId', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> thenByIsManualEntry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isManualEntry', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy>
  thenByIsManualEntryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isManualEntry', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> thenByMeterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meterId', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> thenByMeterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meterId', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> thenByOcrConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrConfidence', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy>
  thenByOcrConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrConfidence', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> thenByOcrRawText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrRawText', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy>
  thenByOcrRawTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrRawText', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> thenByPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> thenByPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> thenByReadingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingDate', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy>
  thenByReadingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingDate', Sort.desc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy> thenByReadingValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingValue', Sort.asc);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QAfterSortBy>
  thenByReadingValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingValue', Sort.desc);
    });
  }
}

extension ReadingModelQueryWhereDistinct
    on QueryBuilder<ReadingModel, ReadingModel, QDistinct> {
  QueryBuilder<ReadingModel, ReadingModel, QDistinct>
  distinctByBillingCycleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billingCycleId');
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QDistinct>
  distinctByIsManualEntry() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isManualEntry');
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QDistinct> distinctByMeterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'meterId');
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QDistinct> distinctByNotes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QDistinct>
  distinctByOcrConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ocrConfidence');
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QDistinct> distinctByOcrRawText({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ocrRawText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QDistinct> distinctByPhotoPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QDistinct> distinctByReadingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'readingDate');
    });
  }

  QueryBuilder<ReadingModel, ReadingModel, QDistinct> distinctByReadingValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'readingValue');
    });
  }
}

extension ReadingModelQueryProperty
    on QueryBuilder<ReadingModel, ReadingModel, QQueryProperty> {
  QueryBuilder<ReadingModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReadingModel, int?, QQueryOperations> billingCycleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billingCycleId');
    });
  }

  QueryBuilder<ReadingModel, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ReadingModel, bool, QQueryOperations> isManualEntryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isManualEntry');
    });
  }

  QueryBuilder<ReadingModel, int, QQueryOperations> meterIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'meterId');
    });
  }

  QueryBuilder<ReadingModel, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<ReadingModel, double?, QQueryOperations>
  ocrConfidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ocrConfidence');
    });
  }

  QueryBuilder<ReadingModel, String?, QQueryOperations> ocrRawTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ocrRawText');
    });
  }

  QueryBuilder<ReadingModel, String?, QQueryOperations> photoPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoPath');
    });
  }

  QueryBuilder<ReadingModel, DateTime, QQueryOperations> readingDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'readingDate');
    });
  }

  QueryBuilder<ReadingModel, double, QQueryOperations> readingValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'readingValue');
    });
  }
}
