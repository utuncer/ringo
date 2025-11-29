// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchResults)
const searchResultsProvider = SearchResultsFamily._();

final class SearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserProfile>>,
          List<UserProfile>,
          FutureOr<List<UserProfile>>
        >
    with
        $FutureModifier<List<UserProfile>>,
        $FutureProvider<List<UserProfile>> {
  const SearchResultsProvider._({
    required SearchResultsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @override
  String toString() {
    return r'searchResultsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<UserProfile>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserProfile>> create(Ref ref) {
    final argument = this.argument as String;
    return searchResults(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchResultsHash() => r'84f10491ffc55a54c88e11f8233427642c1dae9d';

final class SearchResultsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<UserProfile>>, String> {
  const SearchResultsFamily._()
    : super(
        retry: null,
        name: r'searchResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchResultsProvider call(String query) =>
      SearchResultsProvider._(argument: query, from: this);

  @override
  String toString() => r'searchResultsProvider';
}
