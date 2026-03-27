import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../data/thot_provider.dart';
import 'package:thot/l10n/app_strings.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({Key? key}) : super(key: key);

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  String _enteredPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isError = false;

  void _onNumberPressed(String number) {
    if (_isConfirming) {
      if (_confirmPin.length < 6) {
        setState(() {
          _confirmPin += number;
          _isError = false;
        });

        if (_confirmPin.length == 6) {
          _verifyMatch();
        }
      }
    } else {
      if (_enteredPin.length < 6) {
        setState(() {
          _enteredPin += number;
        });

        if (_enteredPin.length == 6) {
          setState(() => _isConfirming = true);
        }
      }
    }
  }

  void _onDeletePressed() {
    setState(() {
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          _isError = false;
        }
      } else {
        if (_enteredPin.isNotEmpty) {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        }
      }
    });
  }

  void _verifyMatch() async {
    if (_enteredPin == _confirmPin) {
      final provider = Provider.of<ThotProvider>(context, listen: false);
      await provider.setPinCode(_enteredPin);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.of(context).pinSetSuccess)),
        );
        context.pop();
      }
    } else {
      setState(() {
        _isError = true;
        _confirmPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    
    final currentPin = _isConfirming ? _confirmPin : _enteredPin;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(strings.configurePinCode),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              Icon(Icons.lock_outline_rounded, size: 64, color: colors.primary),
              const Gap(16),
              Text(
                _isConfirming ? strings.confirmPin : strings.choosePin,
                style: textStyles.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(8),
              Text(
                strings.pin6Digits,
                style: textStyles.bodyMedium?.copyWith(color: colors.secondary),
              ),
              const Gap(48),

              // PIN Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final isFilled = index < currentPin.length;
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
              
              if (_isError) ...[
                const Gap(16),
                Text(
                  strings.pinsDoNotMatch,
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
                        const SizedBox(width: 72),
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
