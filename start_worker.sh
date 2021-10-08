#!/bin/bash

MASTER="stt.visionnote.io"
YAML="/opt/models/korean_nnet3.yaml"

export GST_PLUGIN_PATH=/opt/gst-kaldi-nnet2-online/src/:/opt/kaldi/src/gst-plugin/

python /opt/kaldi-gstreamer-server/kaldigstserver/worker.py -c $YAML -u wss://$MASTER/worker/ws/speech 2>> /opt/worker.log &