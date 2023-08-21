#/bin/bash
nvidia-smi -pm 1
nvidia-smi -i 0 -pl 290

nvidia-settings -a [gpu:0]/GPUPowerMizerMode=1
nvidia-settings -a [gpu:0]/GPUMemoryTransferRateOffset[4]=2000
nvidia-settings -a [gpu:0]/GPUGraphicsClockOffset[4]=130
#nvidia-settings -a [gpu:0]/GPUGraphicsClockOffsetAllPerformanceLevels=130
