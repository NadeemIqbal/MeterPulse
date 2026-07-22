// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_cycle_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBillingCycleModelCollection on Isar {
  IsarCollection<BillingCycleModel> get billingCycleModels => this.collection();
}

const BillingCycleModelSchema = CollectionSchema(
  name: r'BillingCycleModel',
  id: -1200449416973308250,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'cycleEndDate': PropertySchema(
      id: 1,
      name: r'cycleEndDate',
      type: IsarType.dateTime,
    ),
    r'cycleStartDate': PropertySchema(
      id: 2,
      name: r'cycleStartDate',
      type: IsarType.dateTime,
    ),
    r'endReadingId': PropertySchema(
      id: 3,
      name: r'endReadingId',
      type: IsarType.long,
    ),
    r'expectedReadingDate': PropertySchema(
      id: 4,
      name: r'expectedReadingDate',
      type: IsarType.dateTime,
    ),
    r'isClosed': PropertySchema(id: 5, name: r'isClosed', type: IsarType.bool),
    r'meterId': PropertySchema(id: 6, name: r'meterId', type: IsarType.long),
    r'startReadingId': PropertySchema(
      id: 7,
      name: r'startReadingId',
      type: IsarType.long,
    ),
  },

  estimateSize: _billingCycleModelEstimateSize,
  serialize: _billingCycleModelSerialize,
  deserialize: _billingCycleModelDeserialize,
  deserializeProp: _billingCycleModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'meterId_isClosed': IndexSchema(
      id: -4347385730910132086,
      name: r'meterId_isClosed',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'meterId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'isClosed',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _billingCycleModelGetId,
  getLinks: _billingCycleModelGetLinks,
  attach: _billingCycleModelAttach,
  version: '3.3.2',
);

int _billingCycleModelEstimateSize(
  BillingCycleModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _billingCycleModelSerialize(
  BillingCycleModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.cycleEndDate);
  writer.writeDateTime(offsets[2], object.cycleStartDate);
  writer.writeLong(offsets[3], object.endReadingId);
  writer.writeDateTime(offsets[4], object.expectedReadingDate);
  writer.writeBool(offsets[5], object.isClosed);
  writer.writeLong(offsets[6], object.meterId);
  writer.writeLong(offsets[7], object.startReadingId);
}

BillingCycleModel _billingCycleModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BillingCycleModel();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.cycleEndDate = reader.readDateTimeOrNull(offsets[1]);
  object.cycleStartDate = reader.readDateTime(offsets[2]);
  object.endReadingId = reader.readLongOrNull(offsets[3]);
  object.expectedReadingDate = reader.readDateTimeOrNull(offsets[4]);
  object.id = id;
  object.isClosed = reader.readBool(offsets[5]);
  object.meterId = reader.readLong(offsets[6]);
  object.startReadingId = reader.readLongOrNull(offsets[7]);
  return object;
}

P _billingCycleModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _billingCycleModelGetId(BillingCycleModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _billingCycleModelGetLinks(
  BillingCycleModel object,
) {
  return [];
}

void _billingCycleModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  BillingCycleModel object,
) {
  object.id = id;
}

extension BillingCycleModelQueryWhereSort
    on QueryBuilder<BillingCycleModel, BillingCycleModel, QWhere> {
  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterWhere>
  anyMeterIdIsClosed() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'meterId_isClosed'),
      );
    });
  }
}

extension BillingCycleModelQueryWhere
    on QueryBuilder<BillingCycleModel, BillingCycleModel, QWhereClause> {
  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterWhereClause>
  idBetween(
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

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterWhereClause>
  meterIdEqualToAnyIsClosed(int meterId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'meterId_isClosed',
          value: [meterId],
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterWhereClause>
  meterIdNotEqualToAnyIsClosed(int meterId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId_isClosed',
                lower: [],
                upper: [meterId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId_isClosed',
                lower: [meterId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId_isClosed',
                lower: [meterId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId_isClosed',
                lower: [],
                upper: [meterId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterWhereClause>
  meterIdGreaterThanAnyIsClosed(int meterId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'meterId_isClosed',
          lower: [meterId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterWhereClause>
  meterIdLessThanAnyIsClosed(int meterId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'meterId_isClosed',
          lower: [],
          upper: [meterId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterWhereClause>
  meterIdBetweenAnyIsClosed(
    int lowerMeterId,
    int upperMeterId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'meterId_isClosed',
          lower: [lowerMeterId],
          includeLower: includeLower,
          upper: [upperMeterId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterWhereClause>
  meterIdIsClosedEqualTo(int meterId, bool isClosed) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'meterId_isClosed',
          value: [meterId, isClosed],
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterWhereClause>
  meterIdEqualToIsClosedNotEqualTo(int meterId, bool isClosed) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId_isClosed',
                lower: [meterId],
                upper: [meterId, isClosed],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId_isClosed',
                lower: [meterId, isClosed],
                includeLower: false,
                upper: [meterId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId_isClosed',
                lower: [meterId, isClosed],
                includeLower: false,
                upper: [meterId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId_isClosed',
                lower: [meterId],
                upper: [meterId, isClosed],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension BillingCycleModelQueryFilter
    on QueryBuilder<BillingCycleModel, BillingCycleModel, QFilterCondition> {
  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
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

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
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

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
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

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  cycleEndDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'cycleEndDate'),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  cycleEndDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'cycleEndDate'),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  cycleEndDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cycleEndDate', value: value),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  cycleEndDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cycleEndDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  cycleEndDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cycleEndDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  cycleEndDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cycleEndDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  cycleStartDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cycleStartDate', value: value),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  cycleStartDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cycleStartDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  cycleStartDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cycleStartDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  cycleStartDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cycleStartDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  endReadingIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'endReadingId'),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  endReadingIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'endReadingId'),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  endReadingIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endReadingId', value: value),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  endReadingIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'endReadingId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  endReadingIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'endReadingId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  endReadingIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'endReadingId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  expectedReadingDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'expectedReadingDate'),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  expectedReadingDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'expectedReadingDate'),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  expectedReadingDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'expectedReadingDate', value: value),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  expectedReadingDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'expectedReadingDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  expectedReadingDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'expectedReadingDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  expectedReadingDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'expectedReadingDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  idBetween(
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

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  isClosedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isClosed', value: value),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  meterIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'meterId', value: value),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
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

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
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

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
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

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  startReadingIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'startReadingId'),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  startReadingIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'startReadingId'),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  startReadingIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startReadingId', value: value),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  startReadingIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startReadingId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  startReadingIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startReadingId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterFilterCondition>
  startReadingIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startReadingId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension BillingCycleModelQueryObject
    on QueryBuilder<BillingCycleModel, BillingCycleModel, QFilterCondition> {}

extension BillingCycleModelQueryLinks
    on QueryBuilder<BillingCycleModel, BillingCycleModel, QFilterCondition> {}

extension BillingCycleModelQuerySortBy
    on QueryBuilder<BillingCycleModel, BillingCycleModel, QSortBy> {
  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  sortByCycleEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleEndDate', Sort.asc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  sortByCycleEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleEndDate', Sort.desc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  sortByCycleStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleStartDate', Sort.asc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  sortByCycleStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleStartDate', Sort.desc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  sortByEndReadingId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endReadingId', Sort.asc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  sortByEndReadingIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endReadingId', Sort.desc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  sortByExpectedReadingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedReadingDate', Sort.asc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  sortByExpectedReadingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedReadingDate', Sort.desc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  sortByIsClosed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isClosed', Sort.asc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  sortByIsClosedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isClosed', Sort.desc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  sortByMeterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meterId', Sort.asc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  sortByMeterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meterId', Sort.desc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  sortByStartReadingId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startReadingId', Sort.asc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  sortByStartReadingIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startReadingId', Sort.desc);
    });
  }
}

extension BillingCycleModelQuerySortThenBy
    on QueryBuilder<BillingCycleModel, BillingCycleModel, QSortThenBy> {
  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  thenByCycleEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleEndDate', Sort.asc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  thenByCycleEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleEndDate', Sort.desc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  thenByCycleStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleStartDate', Sort.asc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  thenByCycleStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleStartDate', Sort.desc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  thenByEndReadingId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endReadingId', Sort.asc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  thenByEndReadingIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endReadingId', Sort.desc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  thenByExpectedReadingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedReadingDate', Sort.asc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  thenByExpectedReadingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedReadingDate', Sort.desc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  thenByIsClosed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isClosed', Sort.asc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  thenByIsClosedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isClosed', Sort.desc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  thenByMeterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meterId', Sort.asc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  thenByMeterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meterId', Sort.desc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  thenByStartReadingId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startReadingId', Sort.asc);
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QAfterSortBy>
  thenByStartReadingIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startReadingId', Sort.desc);
    });
  }
}

extension BillingCycleModelQueryWhereDistinct
    on QueryBuilder<BillingCycleModel, BillingCycleModel, QDistinct> {
  QueryBuilder<BillingCycleModel, BillingCycleModel, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QDistinct>
  distinctByCycleEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cycleEndDate');
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QDistinct>
  distinctByCycleStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cycleStartDate');
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QDistinct>
  distinctByEndReadingId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endReadingId');
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QDistinct>
  distinctByExpectedReadingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedReadingDate');
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QDistinct>
  distinctByIsClosed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isClosed');
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QDistinct>
  distinctByMeterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'meterId');
    });
  }

  QueryBuilder<BillingCycleModel, BillingCycleModel, QDistinct>
  distinctByStartReadingId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startReadingId');
    });
  }
}

extension BillingCycleModelQueryProperty
    on QueryBuilder<BillingCycleModel, BillingCycleModel, QQueryProperty> {
  QueryBuilder<BillingCycleModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BillingCycleModel, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<BillingCycleModel, DateTime?, QQueryOperations>
  cycleEndDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cycleEndDate');
    });
  }

  QueryBuilder<BillingCycleModel, DateTime, QQueryOperations>
  cycleStartDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cycleStartDate');
    });
  }

  QueryBuilder<BillingCycleModel, int?, QQueryOperations>
  endReadingIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endReadingId');
    });
  }

  QueryBuilder<BillingCycleModel, DateTime?, QQueryOperations>
  expectedReadingDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedReadingDate');
    });
  }

  QueryBuilder<BillingCycleModel, bool, QQueryOperations> isClosedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isClosed');
    });
  }

  QueryBuilder<BillingCycleModel, int, QQueryOperations> meterIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'meterId');
    });
  }

  QueryBuilder<BillingCycleModel, int?, QQueryOperations>
  startReadingIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startReadingId');
    });
  }
}
