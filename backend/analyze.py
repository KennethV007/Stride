import cv2
import mediapipe as mp
import json
import os
import sys
import math
import numpy as np

# Parse command-line arguments for input and output paths
if len(sys.argv) < 2:
    print(json.dumps({"error": "No input video path provided."}))
    sys.exit(1)
input_path = sys.argv[1]
if len(sys.argv) > 2:
    output_path = sys.argv[2]
else:
    output_path = f"skeleton_{os.path.basename(input_path)}"

print(f"Processing video: {input_path} -> {output_path}")

# Initialize MediaPipe Pose.
mp_pose = mp.solutions.pose
pose = mp_pose.Pose(static_image_mode=False, model_complexity=1, enable_segmentation=False)
mp_drawing = mp.solutions.drawing_utils

# Open video file.
cap = cv2.VideoCapture(input_path)
if not cap.isOpened():
    print(json.dumps({"error": f"Failed to open input video: {input_path}"}))
    sys.exit(1)

# Get video properties.
width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
fps = cap.get(cv2.CAP_PROP_FPS)
if not fps or fps == 0:
    print("Warning: FPS not detected, defaulting to 30.")
    fps = 30
print(f"Video properties - Width: {width}, Height: {height}, FPS: {fps}")

# Use a widely supported codec for mp4
fourcc = cv2.VideoWriter_fourcc(*'avc1')
out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))

frame_count = 0

def calculate_angle(a, b, c):
    """Calculate the angle (in degrees) at point b given three points a, b, c."""
    a = [a.x, a.y]
    b = [b.x, b.y]
    c = [c.x, c.y]
    ab = [a[0] - b[0], a[1] - b[1]]
    cb = [c[0] - b[0], c[1] - b[1]]
    dot = ab[0]*cb[0] + ab[1]*cb[1]
    norm_ab = math.sqrt(ab[0]**2 + ab[1]**2)
    norm_cb = math.sqrt(cb[0]**2 + cb[1]**2)
    if norm_ab * norm_cb == 0:
        return None
    angle = math.acos(dot / (norm_ab * norm_cb))
    return math.degrees(angle)

# Store per-frame analysis
angles_data = {
    'left_knee': [],
    'right_knee': [],
    'left_hip': [],
    'right_hip': [],
    'torso_lean': []
}

try:
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        frame_count += 1
        # Ensure frame size matches
        if frame.shape[1] != width or frame.shape[0] != height:
            print(f"Frame {frame_count} size mismatch: resizing from {frame.shape[1]}x{frame.shape[0]} to {width}x{height}")
            frame = cv2.resize(frame, (width, height))
        # Convert the BGR image to RGB.
        image_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        # Process the image and find pose landmarks.
        results = pose.process(image_rgb)
        # Draw pose landmarks on the frame.
        if results.pose_landmarks:
            mp_drawing.draw_landmarks(
                frame,
                results.pose_landmarks,
                mp_pose.POSE_CONNECTIONS,
                mp_drawing.DrawingSpec(color=(0, 255, 0), thickness=2, circle_radius=2),
                mp_drawing.DrawingSpec(color=(0, 0, 255), thickness=2, circle_radius=2)
            )
            # --- Analysis ---
            lm = results.pose_landmarks.landmark
            # Knee angles
            left_knee = calculate_angle(lm[mp_pose.PoseLandmark.LEFT_HIP], lm[mp_pose.PoseLandmark.LEFT_KNEE], lm[mp_pose.PoseLandmark.LEFT_ANKLE])
            right_knee = calculate_angle(lm[mp_pose.PoseLandmark.RIGHT_HIP], lm[mp_pose.PoseLandmark.RIGHT_KNEE], lm[mp_pose.PoseLandmark.RIGHT_ANKLE])
            # Hip angles (thigh-torso)
            left_hip = calculate_angle(lm[mp_pose.PoseLandmark.LEFT_SHOULDER], lm[mp_pose.PoseLandmark.LEFT_HIP], lm[mp_pose.PoseLandmark.LEFT_KNEE])
            right_hip = calculate_angle(lm[mp_pose.PoseLandmark.RIGHT_SHOULDER], lm[mp_pose.PoseLandmark.RIGHT_HIP], lm[mp_pose.PoseLandmark.RIGHT_KNEE])
            # Torso lean (angle between vertical and shoulder-hip vector)
            def torso_lean_angle(shoulder, hip):
                dx = shoulder.x - hip.x
                dy = shoulder.y - hip.y
                angle = math.atan2(dx, dy)  # vertical is dy
                return math.degrees(angle)
            torso_lean = torso_lean_angle(lm[mp_pose.PoseLandmark.LEFT_SHOULDER], lm[mp_pose.PoseLandmark.LEFT_HIP])
            # Store
            if left_knee: angles_data['left_knee'].append(left_knee)
            if right_knee: angles_data['right_knee'].append(right_knee)
            if left_hip: angles_data['left_hip'].append(left_hip)
            if right_hip: angles_data['right_hip'].append(right_hip)
            if torso_lean: angles_data['torso_lean'].append(torso_lean)
        # Write the frame with landmarks.
        out.write(frame)
except Exception as e:
    print(json.dumps({"error": f"Exception during processing: {str(e)}"}))
    cap.release()
    out.release()
    sys.exit(1)

# Release resources.
cap.release()
out.release()
cv2.destroyAllWindows()

# Aggregate statistics
def stats(arr):
    arr = np.array(arr)
    return {
        'min': float(np.min(arr)) if arr.size else None,
        'max': float(np.max(arr)) if arr.size else None,
        'mean': float(np.mean(arr)) if arr.size else None
    }

analysis = {
    'left_knee_angle': stats(angles_data['left_knee']),
    'right_knee_angle': stats(angles_data['right_knee']),
    'left_hip_angle': stats(angles_data['left_hip']),
    'right_hip_angle': stats(angles_data['right_hip']),
    'torso_lean_angle': stats(angles_data['torso_lean'])
}

# --- Generate tips/feedback ---
tips = []

# Overstriding: high mean knee angle (extension)
mean_knee = max(analysis['left_knee_angle']['mean'] or 0, analysis['right_knee_angle']['mean'] or 0)
if mean_knee > 160:
    tips.append("You may be overstriding. Try to land with your foot closer to your center of mass.")
else:
    tips.append("Your stride length looks good!")

# Torso lean: high absolute mean
mean_torso_lean = abs(analysis['torso_lean_angle']['mean'] or 0)
if mean_torso_lean > 30:
    tips.append("You may be leaning too far forward or backward. Aim for a slight forward lean from the ankles.")
else:
    tips.append("Your torso posture looks efficient!")

# Hip angle: low mean could indicate insufficient hip extension
mean_hip = min(analysis['left_hip_angle']['mean'] or 180, analysis['right_hip_angle']['mean'] or 180)
if mean_hip < 100:
    tips.append("Try to extend your hips more fully during your stride for better propulsion.")
else:
    tips.append("Good hip extension during your stride!")

print(json.dumps({
    "tips": tips,
    "left_knee_angle": analysis['left_knee_angle'],
    "right_knee_angle": analysis['right_knee_angle'],
    "left_hip_angle": analysis['left_hip_angle'],
    "right_hip_angle": analysis['right_hip_angle'],
    "torso_lean_angle": analysis['torso_lean_angle']
}))