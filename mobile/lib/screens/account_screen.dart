import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/auth_session.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_look.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({
    super.key,
    required this.session,
    required this.onLogout,
  });

  final AuthSession session;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final initial = session.greetingName.characters.first.toUpperCase();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F1E8),
        body: Stack(
          children: [
            const AuthSkyBackdrop(),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(28, 4, 28, 28),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      key: const Key('account-back'),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      color: AuthLook.ink,
                    ),
                  ),
                  const AuthBrand(planeSize: 40),
                  const SizedBox(height: 22),
                  const Text(
                    'Your account',
                    textAlign: TextAlign.center,
                    style: AuthLook.headline,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Preview session on this device only',
                    textAlign: TextAlign.center,
                    style: AuthLook.subtitle,
                  ),
                  const SizedBox(height: 28),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AuthLook.ink.withValues(alpha: 0.07),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: AppTheme.introTeal,
                            foregroundColor: Colors.white,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                fontSize: 30,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            session.displayName?.trim().isNotEmpty == true
                                ? session.displayName!
                                : session.greetingName,
                            style: const TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontStyle: FontStyle.italic,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AuthLook.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(session.email, style: AuthLook.subtitle),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  AuthPrimaryButton(
                    key: const Key('account-logout'),
                    label: 'Log out',
                    onPressed: () async {
                      await onLogout();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
