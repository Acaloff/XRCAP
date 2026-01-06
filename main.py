import cv2
import numpy as np
import threading
import os
import sys

# 카메라 설정
CAM_L_IDX = 0
CAM_R_IDX = 2

class XRCamera:
    def __init__(self, idx):
        self.cap = cv2.VideoCapture(idx, cv2.CAP_V4L2)
        # 하드웨어 레벨에서 MJPG 설정
        self.cap.set(cv2.CAP_PROP_FOURCC, cv2.VideoWriter_fourcc(*'MJPG'))
        self.cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
        self.cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
        self.cap.set(cv2.CAP_PROP_BUFFERSIZE, 1) # 버퍼 1로 고정
        
        self.frame = None
        self.ret = False
        self.running = True
        threading.Thread(target=self._update, daemon=True).start()

    def _update(self):
        while self.running:
            # grab/retrieve 구조를 사용하여 버퍼에 쌓인 낡은 프레임을 즉시 버림
            if not self.cap.grab():
                continue
            self.ret, self.frame = self.cap.retrieve()

    def stop(self):
        self.running = False
        self.cap.release()

is_swapped = False
keep_running = True

def terminal_controller():
    global is_swapped, keep_running
    while keep_running:
        cmd = sys.stdin.readline().strip().lower()
        if cmd == 's':
            is_swapped = not is_swapped
        elif cmd == 'q':
            keep_running = False

def main():
    cam_l = XRCamera(CAM_L_IDX)
    cam_r = XRCamera(CAM_R_IDX)
    threading.Thread(target=terminal_controller, daemon=True).start()

    # [핵심] 창 크기를 조절 가능하게 설정하고, 전체 화면으로 넘김
    # 이렇게 하면 파이썬이 리사이즈를 안 해도 GPU가 화면에 맞춰 늘려줍니다.
    cv2.namedWindow('XR_FAST', cv2.WINDOW_NORMAL)
    cv2.setWindowProperty('XR_FAST', cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)

    print("초저지연 모드 가동 중...")

    while keep_running:
        f_l = cam_l.frame
        f_r = cam_r.frame

        if f_l is not None and f_r is not None:
            # 연산량이 큰 1440 캔버스 작업을 버리고 
            # 640x480 두 개를 단순히 옆으로 붙여 1280x480 영상 생성
            if not is_swapped:
                combined = np.concatenate((f_l, f_r), axis=1)
            else:
                combined = np.concatenate((f_r, f_l), axis=1)
            
            cv2.imshow('XR_FAST', combined)

        # waitKey(1)은 이벤트 루프 처리를 위해 필수입니다.
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cam_l.stop()
    cam_r.stop()
    cv2.destroyAllWindows()
    os._exit(0)

if __name__ == "__main__":
    main()