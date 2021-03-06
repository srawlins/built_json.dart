// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:built_collection/built_collection.dart';
import 'package:built_json/built_json.dart';

class BuiltListSerializer implements Serializer<BuiltList> {
  final bool structured = true;
  final Iterable<Type> types = new BuiltList<Type>([BuiltList]);
  final String wireName = 'list';

  @override
  Object serialize(Serializers serializers, BuiltList builtList,
      {FullType specifiedType: FullType.unspecified}) {
    final isUnderspecified =
        specifiedType.isUnspecified || specifiedType.parameters.isEmpty;

    final elementType = specifiedType.parameters.isEmpty
        ? FullType.unspecified
        : specifiedType.parameters[0];

    if (!isUnderspecified && !serializers.hasBuilder(specifiedType)) {
      throw new StateError(
          'No builder for $specifiedType, cannot serialize.');
    }

    return builtList.map(
        (item) => serializers.serialize(item, specifiedType: elementType));
  }

  @override
  BuiltList deserialize(Serializers serializers, Object serialized,
      {FullType specifiedType: FullType.unspecified}) {
    final isUnderspecified =
        specifiedType.isUnspecified || specifiedType.parameters.isEmpty;

    final elementType = specifiedType.parameters.isEmpty
        ? FullType.unspecified
        : specifiedType.parameters[0];

    final result = isUnderspecified
        ? new ListBuilder<Object>()
        : serializers.newBuilder(specifiedType) as ListBuilder;
    if (result == null) {
      throw new StateError(
          'No builder for $specifiedType, cannot deserialize.');
    }
    result.addAll((serialized as Iterable).map((item) =>
        serializers.deserialize(item, specifiedType: elementType)));
    return result.build();
  }
}
