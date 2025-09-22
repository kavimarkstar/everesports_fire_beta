import 'package:everesports/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PostsViewLoading extends StatefulWidget {
  const PostsViewLoading({super.key});

  @override
  State<PostsViewLoading> createState() => _PostsViewLoadingState();
}

class _PostsViewLoadingState extends State<PostsViewLoading> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _buildUserAvatar(),
              SizedBox(width: getResponsiveSpacing(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Animate(
                      onPlay: (controller) =>
                          controller.repeat(), // loop shimmer
                      effects: [ShimmerEffect(duration: 1800.ms)],
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        // ignore: sort_child_properties_last
                        child: Text(
                          "       ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: getResponsiveFontSize(
                              context,
                              mobile: 14,
                              tablet: 16,
                              desktop: 18,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          shape: BoxShape.rectangle,
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                        ),
                        alignment: Alignment.center,
                      ),
                    ),

                    SizedBox(height: getResponsiveSpacing(context) * 0.5),
                    Animate(
                      onPlay: (controller) =>
                          controller.repeat(), // loop shimmer
                      effects: [ShimmerEffect(duration: 1800.ms)],
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        // ignore: sort_child_properties_last
                        child: Text(
                          "     ",
                          style: TextStyle(
                            fontSize: getResponsiveFontSize(
                              context,
                              mobile: 11,
                              tablet: 12,
                              desktop: 13,
                            ),
                            color: Colors.grey[600],
                          ),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          shape: BoxShape.rectangle,
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                        ),
                        alignment: Alignment.center,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),

              // this is a users fallow button
              CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 15,
                child: Animate(
                  onPlay: (controller) => controller.repeat(), // loop shimmer
                  effects: [ShimmerEffect(duration: 1800.ms)],
                  child: Container(
                    // ignore: sort_child_properties_last
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                    ),
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: getResponsiveSpacing(context)),

          // Post title and description
          Animate(
            onPlay: (controller) => controller.repeat(), // loop shimmer
            effects: [ShimmerEffect(duration: 1800.ms)],
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              // ignore: sort_child_properties_last
              child: Text(
                "  ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: getResponsiveFontSize(
                    context,
                    mobile: 13,
                    tablet: 14,
                    desktop: 16,
                  ),

                  height: 1.4,
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                shape: BoxShape.rectangle,
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              ),
              alignment: Alignment.center,
            ),
          ),

          SizedBox(height: getResponsiveSpacing(context)),

          // Images/Videos
          SizedBox(
            width: double.infinity,
            height: getResponsiveImageHeight(context),
            child: Animate(
              onPlay: (controller) => controller.repeat(), // loop shimmer
              effects: [ShimmerEffect(duration: 1800.ms)],
              child: Container(
                width: MediaQuery.of(context).size.width * 0.3,
                // ignore: sort_child_properties_last
                child: Text(
                  "  ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: getResponsiveFontSize(
                      context,
                      mobile: 13,
                      tablet: 14,
                      desktop: 16,
                    ),

                    height: 1.4,
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  shape: BoxShape.rectangle,
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
                alignment: Alignment.center,
              ),
            ),
          ),
          SizedBox(height: getResponsiveSpacing(context)),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _postActionButton(context),
              _postActionButton(context),
              _postActionButton(context),
              const Spacer(),
              _postActionBookmarkButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CircleAvatar(
      radius: 25,
      backgroundColor: Colors.transparent,

      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Animate(
          onPlay: (controller) => controller.repeat(), // loop shimmer
          effects: [ShimmerEffect(duration: 1800.ms)],
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            ),
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  Widget _postActionButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 20,
        child: Animate(
          onPlay: (controller) => controller.repeat(), // loop shimmer
          effects: [ShimmerEffect(duration: 1800.ms)],
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            ),
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  Widget _postActionBookmarkButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 20,
      child: Animate(
        onPlay: (controller) => controller.repeat(), // loop shimmer
        effects: [ShimmerEffect(duration: 1800.ms)],
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
