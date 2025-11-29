// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_users_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(savedUsers)
const savedUsersProvider = SavedUsersProvider._();

final class SavedUsersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserProfile>>,
          List<UserProfile>,
          FutureOr<List<UserProfile>>
        >
    with
        $FutureModifier<List<UserProfile>>,
        $FutureProvider<List<UserProfile>> {
  const SavedUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedUsersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedUsersHash();

  @$internal
  @override
  $FutureProviderElement<List<UserProfile>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserProfile>> create(Ref ref) {
    return savedUsers(ref);
  }
}

String _$savedUsersHash() => r'0d062c542489669f3220cb548f164bb7344636df';
