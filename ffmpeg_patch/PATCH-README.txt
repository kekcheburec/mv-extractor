This is a patched version of FFMPEG library.
The patch exposes several fields of the internal RTPDemuxContext class to the
AVPacket class which is accessible through public APIs. This allows to read out
for example timestamp and sequence number of an RTSP packet.

The following files have been patched:

libavcodec/avcodec.h
libavformat/rtpdec.c
libavformat/utils.c

For a detailed description of the changes refer to "patch_description.docx".

This directory contains patches for FFmpeg n4.1.3 that:

1. Fix motion vector extraction in avcodec.h
2. Fix RTP packet handling in rtpdec.c
3. Fix timestamp handling in utils.c
4. Fix assembling with binutils as >= 2.41 in mathops.h (x86 assembly code)

The patches are applied by the patch.sh script which copies these files to their respective locations in the FFmpeg source tree.

Please ensure FFMPEG_INSTALL_DIR and FFMPEG_PATCH_DIR environment variables are set before running the patch script.
