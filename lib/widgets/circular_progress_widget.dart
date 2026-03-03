import 'package:flutter/material.dart';

class CircularProgressWidget extends StatefulWidget {
  final double progress;
  final String fileName;
  final String? speed;
  final String? eta;
  final VoidCallback? onCancel;

  const CircularProgressWidget({
    super.key,
    required this.progress,
    required this.fileName,
    this.speed,
    this.eta,
    this.onCancel,
  });

  @override
  State<CircularProgressWidget> createState() => _CircularProgressWidgetState();
}

class _CircularProgressWidgetState extends State<CircularProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation =
        Tween<double>(begin: 0, end: widget.progress / 100).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(CircularProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: oldWidget.progress / 100,
        end: widget.progress / 100,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 8,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey[300]!,
                    ),
                  ),
                  // Progress circle with smooth animation
                  CircularProgressIndicator(
                    value: _animation.value,
                    strokeWidth: 8,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(_animation.value),
                    ),
                  ),
                  // Center content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(_animation.value * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.fileName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        if (widget.speed != null || widget.eta != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (widget.speed != null)
                Column(
                  children: [
                    const Text(
                      'Speed',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.speed!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              if (widget.eta != null)
                Column(
                  children: [
                    const Text(
                      'ETA',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.eta!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        const SizedBox(height: 24),
        if (widget.onCancel != null)
          ElevatedButton.icon(
            onPressed: widget.onCancel,
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.33) {
      return Colors.red;
    } else if (progress < 0.66) {
      return Colors.orange;
    } else if (progress < 0.99) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }
}
