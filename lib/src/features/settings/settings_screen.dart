import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import 'providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStockThreshold = ref.watch(settingsProvider);
    final businessId = ref.watch(businessIdProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.language),
            subtitle: Text(l10n.selectLanguage),
            trailing: DropdownButton<String>(
              value: locale.languageCode,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(newValue));
                }
              },
              items: const [
                DropdownMenuItem(value: 'es', child: Text('Español')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
            ),
          ),
          const Divider(),
          if (businessId != null)
            ListTile(
              title: Text(l10n.businessId),
              subtitle: Text(businessId),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: businessId));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.idCopied)));
                },
              ),
            ),
          const Divider(),
          ListTile(
            title: Text(l10n.lowStock),
            subtitle: Text(
              '${l10n.lowStockThresholdSetting} $lowStockThreshold',
            ),
            trailing: SizedBox(
              width: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      if (lowStockThreshold > 1) {
                        ref
                            .read(settingsProvider.notifier)
                            .setLowStockThreshold(lowStockThreshold - 1);
                      }
                    },
                  ),
                  Text(
                    lowStockThreshold.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      ref
                          .read(settingsProvider.notifier)
                          .setLowStockThreshold(lowStockThreshold + 1);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
