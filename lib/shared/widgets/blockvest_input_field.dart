import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

enum BlockVestInputType {
  text,
  email,
  password,
  number,
  phone,
  multiline,
}

class BlockVestInputField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final BlockVestInputType type;
  final bool isRequired;
  final bool isEnabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  const BlockVestInputField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.type = BlockVestInputType.text,
    this.isRequired = false,
    this.isEnabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.maxLines,
    this.maxLength,
    this.textInputAction,
    this.focusNode,
  });

  @override
  State<BlockVestInputField> createState() => _BlockVestInputFieldState();
}

class _BlockVestInputFieldState extends State<BlockVestInputField> {
  bool _obscureText = true;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          _buildLabel(),
          const SizedBox(height: AppTheme.spacingS),
        ],
        _buildTextField(),
        if (widget.helperText != null && widget.errorText == null) ...[
          const SizedBox(height: AppTheme.spacingXS),
          _buildHelperText(),
        ],
      ],
    );
  }

  Widget _buildLabel() {
    return RichText(
      text: TextSpan(
        text: widget.label!,
        style: AppTheme.labelLarge.copyWith(
          color: AppTheme.textPrimary,
        ),
        children: [
          if (widget.isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      enabled: widget.isEnabled,
      obscureText: widget.type == BlockVestInputType.password && _obscureText,
      keyboardType: _getKeyboardType(),
      textInputAction: widget.textInputAction ?? _getTextInputAction(),
      maxLines: _getMaxLines(),
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters ?? _getInputFormatters(),
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator ?? _getDefaultValidator(),
      style: AppTheme.bodyLarge.copyWith(
        color: widget.isEnabled ? AppTheme.textPrimary : AppTheme.textSecondary,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTheme.bodyLarge.copyWith(
          color: AppTheme.textSecondary,
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: _focusNode.hasFocus
                    ? AppTheme.primaryGreen
                    : AppTheme.textSecondary,
              )
            : null,
        suffixIcon: _buildSuffixIcon(),
        errorText: widget.errorText,
        errorStyle: AppTheme.bodyMedium.copyWith(
          color: AppTheme.errorColor,
        ),
        border: _buildBorder(AppTheme.dividerColor),
        enabledBorder: _buildBorder(AppTheme.dividerColor),
        focusedBorder: _buildBorder(AppTheme.primaryGreen),
        errorBorder: _buildBorder(AppTheme.errorColor),
        focusedErrorBorder: _buildBorder(AppTheme.errorColor),
        disabledBorder: _buildBorder(AppTheme.dividerColor.withOpacity(0.5)),
        filled: true,
        fillColor: widget.isEnabled
            ? AppTheme.backgroundLight
            : AppTheme.dividerColor.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingM,
        ),
        counterText: '', // Hide character counter
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.type == BlockVestInputType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: AppTheme.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: AppTheme.textSecondary,
        ),
        onPressed: widget.onSuffixIconPressed,
      );
    }

    return null;
  }

  Widget _buildHelperText() {
    return Text(
      widget.helperText!,
      style: AppTheme.bodyMedium.copyWith(
        color: AppTheme.textSecondary,
      ),
    );
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      borderSide: BorderSide(
        color: color,
        width: 1.5,
      ),
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case BlockVestInputType.email:
        return TextInputType.emailAddress;
      case BlockVestInputType.number:
        return TextInputType.number;
      case BlockVestInputType.phone:
        return TextInputType.phone;
      case BlockVestInputType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  TextInputAction _getTextInputAction() {
    switch (widget.type) {
      case BlockVestInputType.multiline:
        return TextInputAction.newline;
      default:
        return TextInputAction.next;
    }
  }

  int _getMaxLines() {
    if (widget.maxLines != null) return widget.maxLines!;
    
    switch (widget.type) {
      case BlockVestInputType.multiline:
        return 4;
      default:
        return 1;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (widget.type) {
      case BlockVestInputType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case BlockVestInputType.phone:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(15),
        ];
      default:
        return null;
    }
  }

  String? Function(String?)? _getDefaultValidator() {
    if (!widget.isRequired) return null;

    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '${widget.label ?? 'This field'} is required';
      }

      switch (widget.type) {
        case BlockVestInputType.email:
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) {
            return 'Please enter a valid email address';
          }
          break;
        case BlockVestInputType.password:
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          break;
        case BlockVestInputType.phone:
          if (value.length < 10) {
            return 'Please enter a valid phone number';
          }
          break;
        default:
          break;
      }

      return null;
    };
  }
}
