from pyaudio import PyAudio, paFloat32, paContinue
from scipy.signal import lfilter
import numpy as np
from time import sleep
from math import log2
from gpiozero import LED

bot_left = LED(4)
bot_rigt = LED(12)
top_left = LED(6)

fs              = 44100
CHUNK           = 1024
HOLD_FRAMES     = 1
avg_n           = 64

#Filter Coefficients
bass_b = [0.000000000428495, 0.000000001285484, 0.000000000428495, -0.000000002142473, -0.000000002142473, 0.000000000428495, 0.000000001285484, 0.000000000428495 ]
bass_a = [1, -6.9091420424566525, 20.458967667073079, -33.657591906267257, 33.223533863142301, -19.677596165483315, 6.474972286041444, -0.91314370204951234]

bass_avg    = 0
bass_thresh = 0
on_cnt      = 0

def callback(in_data, frame_count, time_info, flag):
        global bass_avg, bass_thresh, on_cnt
        in_data   = np.frombuffer(in_data,dtype=np.float32)
        filt_data = lfilter(bass_b,bass_a,in_data)
        energy    = sum(filt_data**2)/CHUNK
        if(energy > bass_thresh):
                top_left.on()
                on_cnt = 1
        elif(on_cnt > 0):
                on_cnt += 1
                if(on_cnt >= HOLD_FRAMES):
                        on_cnt = 0
        else:
                top_left.off()
        bass_avg    = bass_avg*((avg_n-1)/avg_n) + (1/avg_n)*energy
        bass_thresh = bass_avg*(2-log2(1+bass_avg*40))
        return bytes([]), paContinue

pa = PyAudio()

stream = pa.open(format             = paFloat32,
                 channels           = 1,
                 rate               = fs,
                 input              = True,
                 input_device_index = 2,
                 frames_per_buffer  = CHUNK,
                 stream_callback    = callback)

while stream.is_active():
    sleep(0.1)

stream.close()
pa.terminate()
