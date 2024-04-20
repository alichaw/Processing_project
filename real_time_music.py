import sounddevice as sd
import numpy as np
import librosa
from sklearn.preprocessing import StandardScaler
from joblib import load
import socket
import traceback

UDP_IP = "127.0.0.1"
UDP_PORT = 5005
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

def send_prediction_to_processing(prediction):
    message = str(prediction)
    sock.sendto(message.encode(), (UDP_IP, UDP_PORT))

# Load preprocessing tools and models
scaler = load('scaler.joblib')
selector_arousal = load('selector_arousal.joblib')
selector_valence = load('selector_valence.joblib')
model_arousal = load('random_forest_model.joblib')
model_valence = load('random_forest_model.joblib')

# Parameter settings
sr = 22050  # Sampling rate
duration = 0.5  # Length of audio processed each time, in seconds
frame_length = int(sr * duration)  # Frame length

# Function to extract audio features
def extract_features(data):
    # Calculate MFCC features using librosa
    mfcc = librosa.feature.mfcc(y=data, sr=sr, n_mfcc=10).mean(axis=1)
    return mfcc

# Callback function called each time an audio frame is processed
def callback(indata, frames, time, status):
    try:
        if status:
            print("Status:", status)
        
        if not any(indata):
            return  # Skip processing if the input data is empty

        features = extract_features(indata[:, 0])
        features = np.expand_dims(features, axis=0)
        features_scaled = scaler.transform(features)

        # Arousal and valence predictions
        features_arousal = selector_arousal.transform(features_scaled)
        prediction_arousal = model_arousal.predict(features_arousal)
        features_valence = selector_valence.transform(features_scaled)
        prediction_valence = model_valence.predict(features_valence)

        print(f"Predicted Arousal Score: {prediction_arousal[0]}, Predicted Valence Score: {prediction_valence[0]}")
        send_prediction_to_processing(f"{prediction_arousal[0]},{prediction_valence[0]}")
        #send_prediction_to_processing(prediction_valence[0])

    except Exception as e:
        print("An error occurred:", e)
        traceback.print_exc()

# Start recording and real-time processing
with sd.InputStream(callback=callback, channels=1, samplerate=sr, blocksize=frame_length):
    print("Start real-time audio emotion analysis, press Ctrl+C to end...")
    while True:
        sd.sleep(int(duration * 1000))  # Wait for a certain time, keep listening