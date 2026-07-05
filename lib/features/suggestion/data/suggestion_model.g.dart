// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggestion_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSuggestionCollection on Isar {
  IsarCollection<Suggestion> get suggestions => this.collection();
}

const SuggestionSchema = CollectionSchema(
  name: r'Suggestion',
  id: 5284624339343369337,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'feedback': PropertySchema(
      id: 1,
      name: r'feedback',
      type: IsarType.string,
    ),
    r'mealType': PropertySchema(
      id: 2,
      name: r'mealType',
      type: IsarType.string,
    ),
    r'suggestedDish': PropertySchema(
      id: 3,
      name: r'suggestedDish',
      type: IsarType.string,
    ),
    r'targetDate': PropertySchema(
      id: 4,
      name: r'targetDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _suggestionEstimateSize,
  serialize: _suggestionSerialize,
  deserialize: _suggestionDeserialize,
  deserializeProp: _suggestionDeserializeProp,
  idName: r'id',
  indexes: {
    r'targetDate': IndexSchema(
      id: 5284734288444860006,
      name: r'targetDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'targetDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _suggestionGetId,
  getLinks: _suggestionGetLinks,
  attach: _suggestionAttach,
  version: '3.1.0+1',
);

int _suggestionEstimateSize(
  Suggestion object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.feedback;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.mealType.length * 3;
  bytesCount += 3 + object.suggestedDish.length * 3;
  return bytesCount;
}

void _suggestionSerialize(
  Suggestion object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.feedback);
  writer.writeString(offsets[2], object.mealType);
  writer.writeString(offsets[3], object.suggestedDish);
  writer.writeDateTime(offsets[4], object.targetDate);
}

Suggestion _suggestionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Suggestion();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.feedback = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.mealType = reader.readString(offsets[2]);
  object.suggestedDish = reader.readString(offsets[3]);
  object.targetDate = reader.readDateTime(offsets[4]);
  return object;
}

P _suggestionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _suggestionGetId(Suggestion object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _suggestionGetLinks(Suggestion object) {
  return [];
}

void _suggestionAttach(IsarCollection<dynamic> col, Id id, Suggestion object) {
  object.id = id;
}

extension SuggestionQueryWhereSort
    on QueryBuilder<Suggestion, Suggestion, QWhere> {
  QueryBuilder<Suggestion, Suggestion, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterWhere> anyTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'targetDate'),
      );
    });
  }
}

extension SuggestionQueryWhere
    on QueryBuilder<Suggestion, Suggestion, QWhereClause> {
  QueryBuilder<Suggestion, Suggestion, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Suggestion, Suggestion, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterWhereClause> targetDateEqualTo(
      DateTime targetDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'targetDate',
        value: [targetDate],
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterWhereClause> targetDateNotEqualTo(
      DateTime targetDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetDate',
              lower: [],
              upper: [targetDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetDate',
              lower: [targetDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetDate',
              lower: [targetDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetDate',
              lower: [],
              upper: [targetDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterWhereClause> targetDateGreaterThan(
    DateTime targetDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'targetDate',
        lower: [targetDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterWhereClause> targetDateLessThan(
    DateTime targetDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'targetDate',
        lower: [],
        upper: [targetDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterWhereClause> targetDateBetween(
    DateTime lowerTargetDate,
    DateTime upperTargetDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'targetDate',
        lower: [lowerTargetDate],
        includeLower: includeLower,
        upper: [upperTargetDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SuggestionQueryFilter
    on QueryBuilder<Suggestion, Suggestion, QFilterCondition> {
  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> feedbackIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'feedback',
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      feedbackIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'feedback',
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> feedbackEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'feedback',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      feedbackGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'feedback',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> feedbackLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'feedback',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> feedbackBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'feedback',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      feedbackStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'feedback',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> feedbackEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'feedback',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> feedbackContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'feedback',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> feedbackMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'feedback',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      feedbackIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'feedback',
        value: '',
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      feedbackIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'feedback',
        value: '',
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> mealTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      mealTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mealType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> mealTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mealType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> mealTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mealType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      mealTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mealType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> mealTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mealType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> mealTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mealType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> mealTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mealType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      mealTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealType',
        value: '',
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      mealTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mealType',
        value: '',
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      suggestedDishEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'suggestedDish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      suggestedDishGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'suggestedDish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      suggestedDishLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'suggestedDish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      suggestedDishBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'suggestedDish',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      suggestedDishStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'suggestedDish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      suggestedDishEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'suggestedDish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      suggestedDishContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'suggestedDish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      suggestedDishMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'suggestedDish',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      suggestedDishIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'suggestedDish',
        value: '',
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      suggestedDishIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'suggestedDish',
        value: '',
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> targetDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      targetDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition>
      targetDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterFilterCondition> targetDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SuggestionQueryObject
    on QueryBuilder<Suggestion, Suggestion, QFilterCondition> {}

extension SuggestionQueryLinks
    on QueryBuilder<Suggestion, Suggestion, QFilterCondition> {}

extension SuggestionQuerySortBy
    on QueryBuilder<Suggestion, Suggestion, QSortBy> {
  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> sortByFeedback() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedback', Sort.asc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> sortByFeedbackDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedback', Sort.desc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> sortByMealType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealType', Sort.asc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> sortByMealTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealType', Sort.desc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> sortBySuggestedDish() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedDish', Sort.asc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> sortBySuggestedDishDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedDish', Sort.desc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> sortByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.asc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> sortByTargetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.desc);
    });
  }
}

extension SuggestionQuerySortThenBy
    on QueryBuilder<Suggestion, Suggestion, QSortThenBy> {
  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> thenByFeedback() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedback', Sort.asc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> thenByFeedbackDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedback', Sort.desc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> thenByMealType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealType', Sort.asc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> thenByMealTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealType', Sort.desc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> thenBySuggestedDish() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedDish', Sort.asc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> thenBySuggestedDishDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedDish', Sort.desc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> thenByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.asc);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QAfterSortBy> thenByTargetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.desc);
    });
  }
}

extension SuggestionQueryWhereDistinct
    on QueryBuilder<Suggestion, Suggestion, QDistinct> {
  QueryBuilder<Suggestion, Suggestion, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Suggestion, Suggestion, QDistinct> distinctByFeedback(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feedback', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QDistinct> distinctByMealType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mealType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QDistinct> distinctBySuggestedDish(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'suggestedDish',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Suggestion, Suggestion, QDistinct> distinctByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetDate');
    });
  }
}

extension SuggestionQueryProperty
    on QueryBuilder<Suggestion, Suggestion, QQueryProperty> {
  QueryBuilder<Suggestion, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Suggestion, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Suggestion, String?, QQueryOperations> feedbackProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feedback');
    });
  }

  QueryBuilder<Suggestion, String, QQueryOperations> mealTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mealType');
    });
  }

  QueryBuilder<Suggestion, String, QQueryOperations> suggestedDishProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'suggestedDish');
    });
  }

  QueryBuilder<Suggestion, DateTime, QQueryOperations> targetDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetDate');
    });
  }
}
