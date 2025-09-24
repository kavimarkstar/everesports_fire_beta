import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/home/service/like_service.dart';
import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String? currentUserId;
  final bool initiallyLiked;
  final int initialCount;
  final ValueChanged<bool>? onLikeChanged;
  final ValueChanged<int>? onCountChanged;

  const LikeButton({
    Key? key,
    required this.postId,
    required this.postOwnerId,
    required this.currentUserId,
    required this.initiallyLiked,
    required this.initialCount,
    this.onLikeChanged,
    this.onCountChanged,
  }) : super(key: key);

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late bool _liked;
  late int _count;

  @override
  void initState() {
    super.initState();
    _liked = widget.initiallyLiked;
    _count = widget.initialCount;
  }

  @override
  void didUpdateWidget(covariant LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyLiked != widget.initiallyLiked) {
      _liked = widget.initiallyLiked;
    }
    if (oldWidget.initialCount != widget.initialCount) {
      _count = widget.initialCount;
    }
  }

  Future<void> _toggleLike() async {
    if (widget.currentUserId == null ||
        widget.postId.isEmpty ||
        widget.postOwnerId.isEmpty)
      return;
    final prevLiked = _liked;
    final prevCount = _count;
    setState(() {
      _liked = !prevLiked;
      _count = !prevLiked ? prevCount + 1 : (prevCount > 0 ? prevCount - 1 : 0);
    });
    widget.onLikeChanged?.call(_liked);
    widget.onCountChanged?.call(_count);

    final result = await LikeService.likePost(
      widget.currentUserId!,
      widget.postId,
      widget.postOwnerId,
    );

    if (result != !prevLiked && mounted) {
      setState(() {
        _liked = result;
        _count = result
            ? (prevCount + (prevLiked ? 0 : 1))
            : (prevCount - (prevLiked ? 1 : 0)).clamp(0, 1 << 30);
      });
      widget.onLikeChanged?.call(_liked);
      widget.onCountChanged?.call(_count);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconAsset = _liked
        ? "assets/icons/favorited.png"
        : "assets/icons/favorite.png";

    return Row(
      children: [
        IconButton(
          onPressed: _toggleLike,
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: const CircleBorder(),
            splashFactory: InkRipple.splashFactory,
          ),
          icon: Image.asset(
            iconAsset,
            height: 30,
            color: _liked
                ? mainColor
                : (isDarkMode ? mainWhiteColor : mainBlackColor),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          _count.toString(),
          style: TextStyle(
            color: isDarkMode ? mainWhiteColor : mainBlackColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 2),
      ],
    );
  }
}
