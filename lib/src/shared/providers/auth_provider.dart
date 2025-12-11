import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../../features/admin/providers/admin_provider.dart';

final authProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map(
    (event) => event.session?.user,
  );
});

// Cached profile to avoid repeated database queries
Profile? _cachedProfile;
String? _cachedUserId;

final profileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) {
    _cachedProfile = null;
    _cachedUserId = null;
    return null;
  }

  // Return cached profile if same user
  if (_cachedUserId == user.id && _cachedProfile != null) {
    return _cachedProfile;
  }

  try {
    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;

    _cachedProfile = Profile.fromJson(response);
    _cachedUserId = user.id;
    return _cachedProfile;
  } catch (e) {
    return _cachedProfile; // Return cached on error
  }
});

// Provider to force refresh profile from database
final refreshProfileProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    _cachedProfile = null;
    _cachedUserId = null;
    ref.invalidate(profileProvider);
  };
});

final businessIdProvider = Provider<String?>((ref) {
  // 1. Check if Superadmin is impersonating a business
  final impersonatedId = ref.watch(impersonatedBusinessIdProvider);
  if (impersonatedId != null) {
    return impersonatedId;
  }

  // 2. Otherwise, return the user's own business_id
  final profile = ref.watch(profileProvider).value;
  return profile?.businessId;
});
