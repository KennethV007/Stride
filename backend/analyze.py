import cv2
import mediapipe as mp
import json
import os
import sys

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
fourcc = cv2.VideoWriter_fourcc(*'mp4v')
out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))

frame_count = 0
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

print(json.dumps({
    "input_video": input_path,
    "output_video": output_path,
    "status": "skeleton_overlay_complete"
}))