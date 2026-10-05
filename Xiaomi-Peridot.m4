# SPDX-License-Identifier: BSD-3-Clause
include(`audioreach/audioreach.m4')
include(`audioreach/stream-subgraph.m4')
include(`audioreach/device-subgraph.m4')
include(`util/route.m4')
include(`util/mixer.m4')
include(`audioreach/tokens.m4')
#
# Stream SubGraph for MultiMedia Playback
#
#  ______________________________________________
# |               Sub Graph 1                    |
# | [WR_SH] -> [PCM DEC] -> [PCM CONV] -> [LOG]  |- Kcontrol
# |______________________________________________|
#
dnl Playback MultiMedia1
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA1,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004001, 0x00004001, 0x00006001, `110000')
dnl Capture MultiMedia2
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA2,
	`S16_LE', 48000, 48000, 1, 2,
	0x00004002, 0x00004002, 0x00006010, `110000')
#
# Device SubGraph for the speaker amplifiers on the Quinary TDM interface,
# routed to the LPASS low power island (LPAIF_VA, interface 0).
#
#         ___________________
#        |   Sub Graph 2     |
# Mixer -| [LOG] -> [TDM EP] |
#        |___________________|
#
dnl Four 32-bit slots, speakers on slots 0 and 1, short frame sync with
dnl one bit clock data delay, as in the vendor calibration.
define(`TDM_SYNC_SRC', `1') dnl
define(`TDM_DATA_OUT_ENABLE', `1') dnl
define(`TDM_SLOT_MASK', `0x3') dnl
define(`TDM_NSLOTS', `4') dnl
define(`TDM_SLOT_WIDTH', `32') dnl
define(`TDM_SYNC_MODE', `0') dnl
define(`TDM_INVERT_SYNC', `0') dnl
define(`TDM_SYNC_DATA_DELAY', `1') dnl
DEVICE_SG_ADD(audioreach/subgraph-device-tdm-playback.m4, `Quinary TDM0', QUINARY_TDM_RX_0,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_VA, 0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004005, 0x00004005, 0x00006050, `QUINARY_TDM_RX_0')

STREAM_DEVICE_PLAYBACK_MIXER(QUINARY_TDM_RX_0, ``QUINARY_TDM_RX_0'', ``MultiMedia1'')
STREAM_DEVICE_PLAYBACK_ROUTE(QUINARY_TDM_RX_0, ``QUINARY_TDM_RX_0 Audio Mixer'', ``MultiMedia1, stream0.logger1'')
#
# Device SubGraph for the WCD937x microphones (TX macro, codec DMA TX3)
#
DEVICE_SG_ADD(audioreach/subgraph-device-codec-dma-capture.m4, `TX_CODEC_DMA_TX_3', TX_CODEC_DMA_TX_3,
	`S16_LE', 48000, 48000, 1, 2,
	LPAIF_INTF_TYPE_RXTX, CODEC_INTF_IDX_TX3, 0, DATA_FORMAT_FIXED_POINT,
	0x00004006, 0x00004006, 0x00006060)

STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA2, ``TX_CODEC_DMA_TX_3'')
STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA2, ``MultiMedia2 Mixer'', ``TX_CODEC_DMA_TX_3, device120.logger1'')
