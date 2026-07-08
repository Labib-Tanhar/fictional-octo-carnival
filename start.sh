#!/bin/bash

echo "Setting up Android 17 emulator..."

# Install Android SDK tools
sudo apt-get update -qq
sudo apt-get install -y wget unzip openjdk-17-jdk x11vnc xvfb novnc \
  libgl1-mesa-dev libpulse0 2>/dev/null

# Download command line tools
mkdir -p ~/android-sdk/cmdline-tools
cd ~/android-sdk/cmdline-tools

wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip -q commandlinetools-linux-11076708_latest.zip
mv cmdline-tools latest

export ANDROID_SDK_ROOT=~/android-sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools

# Accept licenses
yes | sdkmanager --licenses > /dev/null 2>&1

echo "Downloading Android 17 (API 37) system image..."
sdkmanager "platform-tools" \
  "emulator" \
  "platforms;android-37" \
  "system-images;android-37;google_apis;x86_64"

echo "Creating Android 17 AVD..."
echo "no" | avdmanager create avd \
  -n Android17 \
  -k "system-images;android-37;google_apis;x86_64" \
  -d "pixel_6"

echo "Starting virtual display..."
Xvfb :1 -screen 0 1280x720x24 &
export DISPLAY=:1

echo "Starting Android 17 emulator..."
$ANDROID_SDK_ROOT/emulator/emulator \
  -avd Android17 \
  -no-audio \
  -gpu swiftshader_indirect \
  -no-snapshot \
  -wipe-data &

echo "Starting noVNC on port 6080..."
x11vnc -display :1 -nopw -listen localhost -xkb -forever &
websockify --web /usr/share/novnc 6080 localhost:5900 &

echo ""
echo "✅ Android 17 starting! Open port 6080 from the PORTS tab"
echo "⏳ Takes 3-5 minutes to fully boot"
wait
