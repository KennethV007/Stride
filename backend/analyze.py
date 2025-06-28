import sys
import json

if __name__ == "__main__":
    video_path = sys.argv[1]
    # Dummy analysis logic
    result = {
        "video": video_path,
        "status": "analyzed",
        "metrics": {
            "stride_length": 1.2,
            "cadence": 180
        }
    }
    print(json.dumps(result)) 