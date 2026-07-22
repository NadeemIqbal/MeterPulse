// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBillModelCollection on Isar {
  IsarCollection<BillModel> get billModels => this.collection();
}

const BillModelSchema = CollectionSchema(
  name: r'BillModel',
  id: 7819431562807030620,
  properties: {
    r'billAmount': PropertySchema(
      id: 0,
      name: r'billAmount',
      type: IsarType.double,
    ),
    r'billDate': PropertySchema(
      id: 1,
      name: r'billDate',
      type: IsarType.dateTime,
    ),
    r'billingCycleId': PropertySchema(
      id: 2,
      name: r'billingCycleId',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dueDate': PropertySchema(
      id: 4,
      name: r'dueDate',
      type: IsarType.dateTime,
    ),
    r'isPaid': PropertySchema(id: 5, name: r'isPaid', type: IsarType.bool),
    r'meterId': PropertySchema(id: 6, name: r'meterId', type: IsarType.long),
    r'notes': PropertySchema(id: 7, name: r'notes', type: IsarType.string),
    r'paidDate': PropertySchema(
      id: 8,
      name: r'paidDate',
      type: IsarType.dateTime,
    ),
    r'photoPath': PropertySchema(
      id: 9,
      name: r'photoPath',
      type: IsarType.string,
    ),
    r'unitsBilled': PropertySchema(
      id: 10,
      name: r'unitsBilled',
      type: IsarType.double,
    ),
  },

  estimateSize: _billModelEstimateSize,
  serialize: _billModelSerialize,
  deserialize: _billModelDeserialize,
  deserializeProp: _billModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'meterId': IndexSchema(
      id: -1596511903527871468,
      name: r'meterId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'meterId',
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

  getId: _billModelGetId,
  getLinks: _billModelGetLinks,
  attach: _billModelAttach,
  version: '3.3.2',
);

int _billModelEstimateSize(
  BillModel object,
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
    final value = object.photoPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _billModelSerialize(
  BillModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.billAmount);
  writer.writeDateTime(offsets[1], object.billDate);
  writer.writeLong(offsets[2], object.billingCycleId);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeDateTime(offsets[4], object.dueDate);
  writer.writeBool(offsets[5], object.isPaid);
  writer.writeLong(offsets[6], object.meterId);
  writer.writeString(offsets[7], object.notes);
  writer.writeDateTime(offsets[8], object.paidDate);
  writer.writeString(offsets[9], object.photoPath);
  writer.writeDouble(offsets[10], object.unitsBilled);
}

BillModel _billModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BillModel();
  object.billAmount = reader.readDouble(offsets[0]);
  object.billDate = reader.readDateTime(offsets[1]);
  object.billingCycleId = reader.readLongOrNull(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.dueDate = reader.readDateTimeOrNull(offsets[4]);
  object.id = id;
  object.isPaid = reader.readBool(offsets[5]);
  object.meterId = reader.readLong(offsets[6]);
  object.notes = reader.readStringOrNull(offsets[7]);
  object.paidDate = reader.readDateTimeOrNull(offsets[8]);
  object.photoPath = reader.readStringOrNull(offsets[9]);
  object.unitsBilled = reader.readDoubleOrNull(offsets[10]);
  return object;
}

P _billModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _billModelGetId(BillModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _billModelGetLinks(BillModel object) {
  return [];
}

void _billModelAttach(IsarCollection<dynamic> col, Id id, BillModel object) {
  object.id = id;
}

extension BillModelQueryWhereSort
    on QueryBuilder<BillModel, BillModel, QWhere> {
  QueryBuilder<BillModel, BillModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhere> anyMeterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'meterId'),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhere> anyBillingCycleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'billingCycleId'),
      );
    });
  }
}

extension BillModelQueryWhere
    on QueryBuilder<BillModel, BillModel, QWhereClause> {
  QueryBuilder<BillModel, BillModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> meterIdEqualTo(
    int meterId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'meterId', value: [meterId]),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> meterIdNotEqualTo(
    int meterId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId',
                lower: [],
                upper: [meterId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId',
                lower: [meterId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId',
                lower: [meterId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'meterId',
                lower: [],
                upper: [meterId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> meterIdGreaterThan(
    int meterId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'meterId',
          lower: [meterId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> meterIdLessThan(
    int meterId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'meterId',
          lower: [],
          upper: [meterId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> meterIdBetween(
    int lowerMeterId,
    int upperMeterId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'meterId',
          lower: [lowerMeterId],
          includeLower: includeLower,
          upper: [upperMeterId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> billingCycleIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'billingCycleId', value: [null]),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause>
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

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> billingCycleIdEqualTo(
    int? billingCycleId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'billingCycleId',
          value: [billingCycleId],
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause>
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

  QueryBuilder<BillModel, BillModel, QAfterWhereClause>
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

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> billingCycleIdLessThan(
    int? billingCycleId, {
    bool include = false,
  }) {
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

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> billingCycleIdBetween(
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

extension BillModelQueryFilter
    on QueryBuilder<BillModel, BillModel, QFilterCondition> {
  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> billAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'billAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
  billAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'billAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> billAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'billAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> billAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'billAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> billDateEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'billDate', value: value),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> billDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'billDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> billDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'billDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> billDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'billDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
  billingCycleIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'billingCycleId'),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
  billingCycleIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'billingCycleId'),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
  billingCycleIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'billingCycleId', value: value),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> dueDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'dueDate'),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> dueDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'dueDate'),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> dueDateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dueDate', value: value),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> dueDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dueDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> dueDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dueDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> dueDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dueDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> isPaidEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isPaid', value: value),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> meterIdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'meterId', value: value),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> meterIdGreaterThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> meterIdLessThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> meterIdBetween(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> notesEqualTo(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> notesGreaterThan(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> notesLessThan(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> notesBetween(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> notesStartsWith(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> notesEndsWith(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> notesContains(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> notesMatches(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> paidDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'paidDate'),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
  paidDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'paidDate'),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> paidDateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'paidDate', value: value),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> paidDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'paidDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> paidDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'paidDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> paidDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'paidDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> photoPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'photoPath'),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
  photoPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'photoPath'),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> photoPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> photoPathLessThan(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> photoPathBetween(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> photoPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> photoPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> photoPathContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> photoPathMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> photoPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'photoPath', value: ''),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
  photoPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'photoPath', value: ''),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
  unitsBilledIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'unitsBilled'),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
  unitsBilledIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'unitsBilled'),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> unitsBilledEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'unitsBilled',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
  unitsBilledGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'unitsBilled',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> unitsBilledLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'unitsBilled',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> unitsBilledBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'unitsBilled',
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

extension BillModelQueryObject
    on QueryBuilder<BillModel, BillModel, QFilterCondition> {}

extension BillModelQueryLinks
    on QueryBuilder<BillModel, BillModel, QFilterCondition> {}

extension BillModelQuerySortBy on QueryBuilder<BillModel, BillModel, QSortBy> {
  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByBillAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billAmount', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByBillAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billAmount', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByBillDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billDate', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByBillDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billDate', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByBillingCycleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingCycleId', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByBillingCycleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingCycleId', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByIsPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaid', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByIsPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaid', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByMeterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meterId', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByMeterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meterId', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByPaidDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidDate', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByPaidDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidDate', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByUnitsBilled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitsBilled', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByUnitsBilledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitsBilled', Sort.desc);
    });
  }
}

extension BillModelQuerySortThenBy
    on QueryBuilder<BillModel, BillModel, QSortThenBy> {
  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByBillAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billAmount', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByBillAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billAmount', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByBillDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billDate', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByBillDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billDate', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByBillingCycleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingCycleId', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByBillingCycleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingCycleId', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByIsPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaid', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByIsPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaid', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByMeterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meterId', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByMeterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meterId', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByPaidDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidDate', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByPaidDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidDate', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByUnitsBilled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitsBilled', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByUnitsBilledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitsBilled', Sort.desc);
    });
  }
}

extension BillModelQueryWhereDistinct
    on QueryBuilder<BillModel, BillModel, QDistinct> {
  QueryBuilder<BillModel, BillModel, QDistinct> distinctByBillAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billAmount');
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctByBillDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billDate');
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctByBillingCycleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billingCycleId');
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueDate');
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctByIsPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPaid');
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctByMeterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'meterId');
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctByNotes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctByPaidDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paidDate');
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctByPhotoPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctByUnitsBilled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unitsBilled');
    });
  }
}

extension BillModelQueryProperty
    on QueryBuilder<BillModel, BillModel, QQueryProperty> {
  QueryBuilder<BillModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BillModel, double, QQueryOperations> billAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billAmount');
    });
  }

  QueryBuilder<BillModel, DateTime, QQueryOperations> billDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billDate');
    });
  }

  QueryBuilder<BillModel, int?, QQueryOperations> billingCycleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billingCycleId');
    });
  }

  QueryBuilder<BillModel, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<BillModel, DateTime?, QQueryOperations> dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueDate');
    });
  }

  QueryBuilder<BillModel, bool, QQueryOperations> isPaidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPaid');
    });
  }

  QueryBuilder<BillModel, int, QQueryOperations> meterIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'meterId');
    });
  }

  QueryBuilder<BillModel, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<BillModel, DateTime?, QQueryOperations> paidDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paidDate');
    });
  }

  QueryBuilder<BillModel, String?, QQueryOperations> photoPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoPath');
    });
  }

  QueryBuilder<BillModel, double?, QQueryOperations> unitsBilledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unitsBilled');
    });
  }
}
