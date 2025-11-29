// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_detail_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(comments)
const commentsProvider = CommentsFamily._();

final class CommentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Comment>>,
          List<Comment>,
          FutureOr<List<Comment>>
        >
    with $FutureModifier<List<Comment>>, $FutureProvider<List<Comment>> {
  const CommentsProvider._({
    required CommentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'commentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$commentsHash();

  @override
  String toString() {
    return r'commentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Comment>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Comment>> create(Ref ref) {
    final argument = this.argument as String;
    return comments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CommentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentsHash() => r'57cee8377e0eabf871cda3dbae0b3a04c6373190';

final class CommentsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Comment>>, String> {
  const CommentsFamily._()
    : super(
        retry: null,
        name: r'commentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CommentsProvider call(String postId) =>
      CommentsProvider._(argument: postId, from: this);

  @override
  String toString() => r'commentsProvider';
}
