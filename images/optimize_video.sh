#!/bin/bash

INPUT="herobanner_video.MP4"
OUTPUT_H264="herobanner_video_web.mp4"
OUTPUT_WEBM="herobanner_video_web.webm"

echo "=== Optimizing hero banner video for web ==="

# H.264/MP4 — best browser compatibility, fast load
# - Scale to 1080p (plenty for a hero banner)
# - CRF 23: excellent quality/size balance (lower = better quality, range 0-51)
# - preset slow: maximizes compression without sacrificing quality
# - movflags +faststart: moves metadata to start of file for instant playback before full download
# - Strip all non-video streams (no audio/data needed for a hero banner)
echo "→ Generating MP4 (H.264, 1080p)..."
ffmpeg -i "$INPUT" \
  -vf "scale=1920:1080:flags=lanczos" \
  -c:v libx264 \
  -crf 23 \
  -preset slow \
  -profile:v high \
  -level:v 4.0 \
  -movflags +faststart \
  -an \
  -map 0:v:0 \
  "$OUTPUT_H264"

echo ""

# WebM/VP9 — better compression than H.264, supported by all modern browsers
# Use alongside MP4 with <source> fallback for best results
# - crf 33: good quality for VP9 (range 0-63, lower = better)
# - b:v 0: enables pure CRF mode (no bitrate cap)
# - deadline best: maximizes compression (use "good" for faster encoding)
echo "→ Generating WebM (VP9, 1080p)..."
ffmpeg -i "$INPUT" \
  -vf "scale=1920:1080:flags=lanczos" \
  -c:v libvpx-vp9 \
  -crf 33 \
  -b:v 0 \
  -deadline best \
  -an \
  -map 0:v:0 \
  "$OUTPUT_WEBM"

echo ""
echo "=== Done ==="
echo ""
echo "File sizes:"
ls -lh "$INPUT" "$OUTPUT_H264" "$OUTPUT_WEBM" 2>/dev/null | awk '{print $5, $9}'

echo ""
echo "Usage in HTML:"
echo '<video autoplay muted loop playsinline>'
echo "  <source src=\"/images/$OUTPUT_WEBM\" type=\"video/webm\">"
echo "  <source src=\"/images/$OUTPUT_H264\" type=\"video/mp4\">"
echo '</video>'
