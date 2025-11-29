// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$teamRepositoryHash() => r'ac0de0ffe8f07ccbdebde2b699fc820080b0099a';

/// See also [teamRepository].
@ProviderFor(teamRepository)
final teamRepositoryProvider = AutoDisposeProvider<TeamRepository>.internal(
  teamRepository,
  name: r'teamRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$teamRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TeamRepositoryRef = AutoDisposeProviderRef<TeamRepository>;
String _$teamMembersHash() => r'7afa0bb5c05f6715551ec988e9db5562508262e8';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [teamMembers].
@ProviderFor(teamMembers)
const teamMembersProvider = TeamMembersFamily();

/// See also [teamMembers].
class TeamMembersFamily extends Family<AsyncValue<List<UserProfile>>> {
  /// See also [teamMembers].
  const TeamMembersFamily();

  /// See also [teamMembers].
  TeamMembersProvider call(
    String teamId,
  ) {
    return TeamMembersProvider(
      teamId,
    );
  }

  @override
  TeamMembersProvider getProviderOverride(
    covariant TeamMembersProvider provider,
  ) {
    return call(
      provider.teamId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'teamMembersProvider';
}

/// See also [teamMembers].
class TeamMembersProvider extends AutoDisposeFutureProvider<List<UserProfile>> {
  /// See also [teamMembers].
  TeamMembersProvider(
    String teamId,
  ) : this._internal(
          (ref) => teamMembers(
            ref as TeamMembersRef,
            teamId,
          ),
          from: teamMembersProvider,
          name: r'teamMembersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$teamMembersHash,
          dependencies: TeamMembersFamily._dependencies,
          allTransitiveDependencies:
              TeamMembersFamily._allTransitiveDependencies,
          teamId: teamId,
        );

  TeamMembersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.teamId,
  }) : super.internal();

  final String teamId;

  @override
  Override overrideWith(
    FutureOr<List<UserProfile>> Function(TeamMembersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TeamMembersProvider._internal(
        (ref) => create(ref as TeamMembersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        teamId: teamId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<UserProfile>> createElement() {
    return _TeamMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamMembersProvider && other.teamId == teamId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, teamId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TeamMembersRef on AutoDisposeFutureProviderRef<List<UserProfile>> {
  /// The parameter `teamId` of this provider.
  String get teamId;
}

class _TeamMembersProviderElement
    extends AutoDisposeFutureProviderElement<List<UserProfile>>
    with TeamMembersRef {
  _TeamMembersProviderElement(super.provider);

  @override
  String get teamId => (origin as TeamMembersProvider).teamId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
