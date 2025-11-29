// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_dashboard_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myTeamId)
const myTeamIdProvider = MyTeamIdProvider._();

final class MyTeamIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  const MyTeamIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myTeamIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myTeamIdHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return myTeamId(ref);
  }
}

String _$myTeamIdHash() => r'0587f74ef9fb36025a79df9fc5c861dd25b9375a';
