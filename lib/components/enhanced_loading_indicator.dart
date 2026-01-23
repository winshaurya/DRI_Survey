import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

enum LoadingType {
  circular,
  linear,
  dots,
  pulse,
  shimmer,
}

class EnhancedLoadingIndicator extends StatefulWidget {
  final LoadingType type;
  final String? message;
  final Color? color;
  final double size;
  final bool showMessage;

  const EnhancedLoadingIndicator({
    super.key,
    this.type = LoadingType.circular,
    this.message,
    this.color,
    this.size = 40.0,
    this.showMessage = true,
  });

  @override
  State<EnhancedLoadingIndicator> createState() => _EnhancedLoadingIndicatorState();
}

class _EnhancedLoadingIndicatorState extends State<EnhancedLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;

    Widget indicator;
    switch (widget.type) {
      case LoadingType.circular:
        indicator = _buildCircularIndicator(color);
        break;
      case LoadingType.linear:
        indicator = _buildLinearIndicator(color);
        break;
      case LoadingType.dots:
        indicator = _buildDotsIndicator(color);
        break;
      case LoadingType.pulse:
        indicator = _buildPulseIndicator(color);
        break;
      case LoadingType.shimmer:
        indicator = _buildShimmerIndicator(color);
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeIn(
          duration: const Duration(milliseconds: 300),
          child: indicator,
        ),
        if (widget.showMessage && widget.message != null) ...[
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              widget.message!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCircularIndicator(Color color) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildLinearIndicator(Color color) {
    return SizedBox(
      width: widget.size * 2,
      height: 4,
      child: LinearProgressIndicator(
        backgroundColor: color.withOpacity(0.2),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  Widget _buildDotsIndicator(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(animationValue),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildPulseIndicator(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3 + (_animation.value * 0.7)),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.sync,
            color: Colors.white,
            size: widget.size * 0.6,
          ),
        );
      },
    );
  }

  Widget _buildShimmerIndicator(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size * 2,
          height: widget.size * 0.3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.8),
                color.withOpacity(0.2),
              ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}

// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final LoadingType type;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.type = LoadingType.circular,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          FadeIn(
            duration: const Duration(milliseconds: 200),
            child: Container(
              color: backgroundColor ?? Colors.black.withOpacity(0.5),
              child: Center(
                child: EnhancedLoadingIndicator(
                  type: type,
                  message: message,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Button with loading state
class LoadingButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final LoadingType loadingType;
  final Color? color;
  final Color? disabledColor;
  final double? width;
  final double height;

  const LoadingButton({
    super.key,
    this.onPressed,
    required this.text,
    this.isLoading = false,
    this.loadingType = LoadingType.circular,
    this.color,
    this.disabledColor,
    this.width,
    this.height = 48,
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = widget.color ?? theme.primaryColor;

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isLoading
              ? (widget.disabledColor ?? buttonColor.withOpacity(0.6))
              : buttonColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: widget.isLoading ? 0 : 2,
        ),
        child: widget.isLoading
            ? EnhancedLoadingIndicator(
                type: widget.loadingType,
                color: Colors.white,
                size: 24,
                showMessage: false,
              )
            : Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
