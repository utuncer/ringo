// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userProfile)
const userProfileProvider = UserProfileFamily._();

final class UserProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserProfile>,
          UserProfile,
          FutureOr<UserProfile>
        >
    with $FutureModifier<UserProfile>, $FutureProvider<UserProfile> {
  const UserProfileProvider._({
    required UserProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userProfileHash();

  @override
  String toString() {
    return r'userProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<UserProfile> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UserProfile> create(Ref ref) {
    final argument = this.argument as String;
    return userProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userProfileHash() => r'fd9afeae437c4644f87fb84aa17e262a57c7a35c';

final class UserProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<UserProfile>, String> {
  const UserProfileFamily._()
    : super(
        retry: null,
        name: r'userProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserProfileProvider call(String userId) =>
      UserProfileProvider._(argument: userId, from: this);

  @override
  String toString() => r'userProfileProvider';
}

@ProviderFor(userPosts)
const userPostsProvider = UserPostsFamily._();

final class UserPostsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>
        >
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  const UserPostsProvider._({
    required UserPostsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userPostsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userPostsHash();

  @override
  String toString() {
    return r'userPostsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<dynamic>> create(Ref ref) {
    final argument = this.argument as String;
    return userPosts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userPostsHash() => r'5adbfaca5b1d1a74475240a7a81ab9adbb845b40';

final class UserPostsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<dynamic>>, String> {
  const UserPostsFamily._()
    : super(
        retry: null,
        name: r'userPostsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserPostsProvider call(String userId) =>
      UserPostsProvider._(argument: userId, from: this);

  @override
  String toString() => r'userPostsProvider';
}

@ProviderFor(teamMembers)
const teamMembersProvider = TeamMembersFamily._();

final class TeamMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserProfile>>,
          List<UserProfile>,
          FutureOr<List<UserProfile>>
        >
    with
        $FutureModifier<List<UserProfile>>,
        $FutureProvider<List<UserProfile>> {
  const TeamMembersProvider._({
    required TeamMembersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'teamMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teamMembersHash();

  @override
  String toString() {
    return r'teamMembersProvider'
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
    return teamMembers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teamMembersHash() => r'cab2499bdefd6616b40cec7aa9ed5bb862e7bb24';

final class TeamMembersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<UserProfile>>, String> {
  const TeamMembersFamily._()
    : super(
        retry: null,
        name: r'teamMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TeamMembersProvider call(String teamId) =>
      TeamMembersProvider._(argument: teamId, from: this);

  @override
  String toString() => r'teamMembersProvider';
}
