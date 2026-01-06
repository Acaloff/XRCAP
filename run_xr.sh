#!/bin/bash
# 카메라 노출 설정

v4l2-ctl -d /dev/video0 -c auto_exposure=1 -c exposure_time_absolute=120
v4l2-ctl -d /dev/video2 -c auto_exposure=1 -c exposure_time_absolute=120
gst-launch-1.0 -v \
    glvideomixer name=mix \
    sink_0::xpos=0 sink_0::width=1440 sink_0::height=1440 \
    sink_1::xpos=1440 sink_1::width=1440 sink_1::height=1440 ! \
    "video/x-raw(memory:GLMemory),width=2880,height=1440" ! \
    glimagesink sync=false \
    v4l2src device=/dev/video0 ! "image/jpeg,width=640,height=480,framerate=30/1" ! jpegdec ! \
    videocrop left=80 right=80 ! videoconvert ! glupload ! \
    glshader fragment="varying vec2 v_texcoord; uniform sampler2D tex; void main(){float k=0.2;vec2 v=v_texcoord;vec2 c=v*2.0-1.0;float r2=dot(c,c);vec2 d=c*(1.0+k*r2);vec2 f=(d+1.0)/2.0;if(f.x<0.0||f.x>1.0||f.y<0.0||f.y>1.0)gl_FragColor=vec4(0.0,0.0,0.0,1.0);else gl_FragColor=texture2D(tex,f);}" ! \
    queue leaky=2 max-size-buffers=1 ! mix.sink_0 \
    v4l2src device=/dev/video2 ! "image/jpeg,width=640,height=480,framerate=30/1" ! jpegdec ! \
    videocrop left=80 right=80 ! videoconvert ! glupload ! \
    glshader fragment="varying vec2 v_texcoord; uniform sampler2D tex; void main(){float k=0.2;vec2 v=v_texcoord;vec2 c=v*2.0-1.0;float r2=dot(c,c);vec2 d=c*(1.0+k*r2);vec2 f=(d+1.0)/2.0;if(f.x<0.0||f.x>1.0||f.y<0.0||f.y>1.0)gl_FragColor=vec4(0.0,0.0,0.0,1.0);else gl_FragColor=texture2D(tex,f);}" ! \
    queue leaky=2 max-size-buffers=1 ! mix.sink_1

# # # 카메라 노출 설정 (레이턴시 제거 핵심)
# v4l2-ctl -d /dev/video0 -c auto_exposure=1 -c exposure_time_absolute=120
# v4l2-ctl -d /dev/video2 -c auto_exposure=1 -c exposure_time_absolute=120

# # 다른 건 건드리지 말고 queue 부분만 바꿨습니다.
# gst-launch-1.0 -v \
#     glvideomixer name=mix \
#     sink_0::xpos=0 sink_0::width=1440 sink_0::height=1440 \
#     sink_1::xpos=1440 sink_1::width=1440 sink_1::height=1440 ! \
#     "video/x-raw(memory:GLMemory),width=2880,height=1440" ! \
#     glimagesink sync=false \
#     v4l2src device=/dev/video0 ! "image/jpeg,width=640,height=480,framerate=30/1" ! jpegdec ! videoconvert ! glupload ! \
#     glshader fragment="varying vec2 v_texcoord; uniform sampler2D tex; void main(){float k=0.2;vec2 v=v_texcoord;vec2 c=v*2.0-1.0;float r2=dot(c,c);vec2 d=c*(1.0+k*r2);vec2 f=(d+1.0)/2.0;if(f.x<0.0||f.x>1.0||f.y<0.0||f.y>1.0)gl_FragColor=vec4(0.0,0.0,0.0,1.0);else gl_FragColor=texture2D(tex,f);}" ! \
#     queue leaky=2 max-size-buffers=1 ! mix.sink_0 \
#     v4l2src device=/dev/video2 ! "image/jpeg,width=640,height=480,framerate=30/1" ! jpegdec ! videoconvert ! glupload ! \
#     glshader fragment="varying vec2 v_texcoord; uniform sampler2D tex; void main(){float k=0.2;vec2 v=v_texcoord;vec2 c=v*2.0-1.0;float r2=dot(c,c);vec2 d=c*(1.0+k*r2);vec2 f=(d+1.0)/2.0;if(f.x<0.0||f.x>1.0||f.y<0.0||f.y>1.0)gl_FragColor=vec4(0.0,0.0,0.0,1.0);else gl_FragColor=texture2D(tex,f);}" ! \
#     queue leaky=2 max-size-buffers=1 ! mix.sink_1
