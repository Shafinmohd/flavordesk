import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/presentation/pages/video/play_this_video.dart';
// ignore: depend_on_referenced_packages
import 'package:octo_image/octo_image.dart';

class NetworkDisplay extends StatefulWidget {
  final int cachingHeight, cachingWidth;
  final String url, blurHash;
  final double aspectRatio;

  final double? height;
  const NetworkDisplay({
    Key? key,
    required this.url,
    this.cachingHeight = 720,
    this.cachingWidth = 720,
    this.height,
    this.blurHash = "",
    this.aspectRatio = 0,
  }) : super(key: key);

  @override
  State<NetworkDisplay> createState() => _NetworkDisplayState();
}

class _NetworkDisplayState extends State<NetworkDisplay> {
  late bool isThatVideo;
  @override
  void initState() {
    isThatVideo = widget.url.contains("mp4");
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!isThatVideo && widget.url.isNotEmpty) {
      precacheImage(NetworkImage(widget.url), context);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return widget.aspectRatio == 0 ? whichBuild(height: null) : aspectRatio();
  }

  Widget aspectRatio() {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: whichBuild(),
    );
  }

  Widget whichBuild({double? height = double.infinity}) {
    return isThatVideo
        ? PlayThisVideo(
            play: true,
            videoUrl: widget.url,
            blurHash: widget.blurHash,
          )
        : buildOcto(height);
  }

  Widget buildOcto(height) {
    int cachingHeight = widget.cachingHeight;
    int cachingWidth = widget.cachingWidth;
    if (widget.aspectRatio != 1 && cachingHeight == 720) cachingHeight = 960;
    return OctoImage(
      image: CachedNetworkImageProvider(widget.url,
          maxWidth: cachingWidth, maxHeight: cachingHeight),
      errorBuilder: (context, url, error) => buildError(),
      fit: BoxFit.cover,
      width: double.infinity,
      height: widget.height ?? height,
      placeholderBuilder: widget.blurHash.isNotEmpty
          ? OctoPlaceholder.blurHash(widget.blurHash)
          : (context) => Center(child: loadingWidget()),
    );
  }

  SizedBox buildError() {
    return SizedBox(
      width: double.infinity,
      height: widget.aspectRatio,
      child: Icon(Icons.warning_amber_rounded,
          size: 30, color: Theme.of(context).focusColor),
    );
  }

  Widget loadingWidget() {
    double aspectRatio = widget.aspectRatio;
    return aspectRatio == 0
        ? buildSizedBox()
        : AspectRatio(
            aspectRatio: aspectRatio,
            child: buildSizedBox(),
          );
  }

  Widget buildSizedBox() {
    return Container(
      width: double.infinity,
      color: Theme.of(context).textTheme.bodyMedium!.color,
      child: Center(
          child: CircleAvatar(
        radius: 57,
        backgroundColor: Theme.of(context).textTheme.bodySmall!.color,
        child: Center(
            child: CircleAvatar(
          radius: 56,
          backgroundColor: Theme.of(context).textTheme.bodyMedium!.color,
        )),
      )),
    );
  }
}
