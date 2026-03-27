import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../data/thot_provider.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _enteredPin = '';
  bool _isError = false;
  bool _isLockedOut = false;

  @override
  void initState() {
    super.initState();
    _checkLockoutAndMaybeAuth();
  }

  Future<void> _checkLockoutAndMaybeAuth() async {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final locked = await provider.isPinLocked;
    if (!mounted) return;

    if (locked) {
      setState(() {
        _isLockedOut = true;
      });
      return;
    }

    _tryBiometricAuth();
  }

  Future<void> _tryBiometricAuth() async {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    if (!provider.biometricEnabled) {
      return;
    }

    final authenticated = await provider.authenticateWithBiometric();

    if (!mounted) {
      return;
    }

    if (authenticated) {
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible d\'utiliser l\'authentification biométrique. Vérifiez la configuration de votre empreinte ou de FaceID.',
          ),
        ),
      );
    }
  }

  void _onNumberPressed(String number) {
    if (_isLockedOut) return;
    if (_enteredPin.length < 6) {
      setState(() {
        _enteredPin += number;
        _isError = false;
      });

      if (_enteredPin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_isLockedOut) return;
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _isError = false;
      });
    }
  }

  void _verifyPin() async {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final isCorrect = await provider.verifyPin(_enteredPin);

    if (isCorrect) {
      if (mounted) {
        context.go('/');
      }
    } else {
      final locked = await provider.isPinLocked;
      if (!mounted) return;

      setState(() {
        _isLockedOut = locked;
        _isError = !locked;
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // App Logo/Title
              Icon(Icons.lock_rounded, size: 64, color: colors.primary),
              const Gap(16),
              Text(
                'THOT',
                style: textStyles.headlineLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(8),
              Text(
                'Entrez votre code PIN à 6 chiffres',
                style: textStyles.bodyMedium?.copyWith(color: colors.secondary),
              ),
              const Gap(48),

              // PIN Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final isFilled = index < _enteredPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? (_isError ? colors.error : colors.primary)
                          : colors.surface,
                      border: Border.all(
                        color: _isError ? colors.error : colors.outline,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              
              if (_isLockedOut) ...[
                const Gap(16),
                Text(
                  'Trop de tentatives. Réessayez dans 30 minutes.',
                  style: textStyles.bodySmall?.copyWith(color: colors.error),
                  textAlign: TextAlign.center,
                ),
              ] else if (_isError) ...[
                const Gap(16),
                Text(
                  'Code incorrect',
                  style: textStyles.bodySmall?.copyWith(color: colors.error),
                ),
              ],

              const Gap(48),

              // Number Pad
              SizedBox(
                width: 300,
                child: Column(
                  children: [
                    _buildNumberRow(['1', '2', '3']),
                    const Gap(16),
                    _buildNumberRow(['4', '5', '6']),
                    const Gap(16),
                    _buildNumberRow(['7', '8', '9']),
                    const Gap(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Consumer<ThotProvider>(
                          builder: (context, provider, _) {
                            if (provider.biometricEnabled) {
                              return _NumberButton(
                                icon: Icons.fingerprint_rounded,
                                onPressed: _tryBiometricAuth,
                              );
                            }
                            return const SizedBox(width: 72);
                          },
                        ),
                        _NumberButton(label: '0', onPressed: () => _onNumberPressed('0')),
                        _NumberButton(
                          icon: Icons.backspace_outlined,
                          onPressed: _onDeletePressed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers
          .map((num) => _NumberButton(label: num, onPressed: () => _onNumberPressed(num)))
          .toList(),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;

  const _NumberButton({this.label, this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colors.outline),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: colors.onSurface, size: 28)
              : Text(
                  label!,
                  style: textStyles.headlineMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
