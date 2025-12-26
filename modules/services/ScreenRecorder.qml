pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property bool isRecording: false
    property string duration: ""
    property string lastError: ""

    property string videosDir: ""

    // Resolve XDG_VIDEOS_DIR
    property Process xdgVideosProcess: Process {
        id: xdgVideosProcess
        command: ["bash", "-c", "xdg-user-dir VIDEOS"]
        running: true // Run on startup
        stdout: StdioCollector {
            onTextChanged: {
                // Not strictly necessary here as we read in onExited
            }
        }
        onExited: exitCode => {
            if (exitCode === 0) {
                var dir = xdgVideosProcess.stdout.text.trim();
                if (dir === "") {
                    dir = Quickshell.env("HOME") + "/Videos";
                }
                root.videosDir = dir + "/Recordings";
            } else {
                root.videosDir = Quickshell.env("HOME") + "/Videos/Recordings";
            }
        }
    }

    // Poll status
    property Timer statusTimer: Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            checkProcess.running = true
        }
    }

    property Process checkProcess: Process {
        id: checkProcess
        // Use -f to match against full command line (handles wrappers/scripts)
        // grep -v to ensure we don't match the check process itself just in case
        command: ["bash", "-c", "pgrep -f 'gpu-screen-recorder' | grep -v $$ > /dev/null"]
        stdout: StdioCollector {
            onTextChanged: {
                // If output not empty, it's running
            }
        }
        onExited: exitCode => {
            // Only update status if we are not in the middle of starting/stopping manually
            // to avoid flickering state, though polling is authoritative.
            var wasRecording = root.isRecording;
            root.isRecording = (exitCode === 0);
            
            if (root.isRecording && !wasRecording) {
                console.log("[ScreenRecorder] Detected running instance.");
            }

            if (root.isRecording) {
                timeProcess.running = true;
            } else {
                root.duration = "";
            }
        }
    }

    property Process timeProcess: Process {
        id: timeProcess
        // Get elapsed time of the oldest matching process
        command: ["bash", "-c", "pid=$(pgrep -f 'gpu-screen-recorder' | head -n 1); if [ -n \"$pid\" ]; then ps -o etime= -p \"$pid\"; fi"]
        stdout: StdioCollector {
            onTextChanged: {
                root.duration = text.trim();
            }
        }
    }

    function toggleRecording() {
        if (isRecording) {
            stopProcess.running = true;
        } else {
            prepareProcess.running = true;
        }
    }
    
    // 1. Ensure directory exists
    property Process prepareProcess: Process {
        id: prepareProcess
        command: ["mkdir", "-p", root.videosDir]
        onExited: exitCode => {
            notifyStartProcess.running = true;
            startProcess.running = true;
        }
    }

    // 2. Notify start
    property Process notifyStartProcess: Process {
        id: notifyStartProcess
        command: ["notify-send", "Screen Recorder", "Starting recording..."]
    }

    // 3. Start recording (Foreground)
    property Process startProcess: Process {
        id: startProcess
        // Removed '&' to keep process alive and capture output
        command: ["bash", "-c", "gpu-screen-recorder -w portal -q ultra -k h265 -ac opus -cr full -f 60 -o \"" + root.videosDir + "/$(date +%Y-%m-%d-%H-%M-%S).mp4\""]
        
        stdout: StdioCollector {
            onTextChanged: console.log("[ScreenRecorder] OUT: " + text)
        }
        stderr: StdioCollector {
            id: stderrCollector
            onTextChanged: {
                console.warn("[ScreenRecorder] ERR: " + text)
                root.lastError = text
            }
        }
        
        onExited: exitCode => {
            console.log("[ScreenRecorder] Exited with code: " + exitCode)
            // 0 = Success (usually not for infinite record unless killed nicely?)
            // 130 = SIGINT (Ctrl+C), which is how we stop it usually, so it's a "Success"
            // 2 = Error
            
            if (exitCode !== 0 && exitCode !== 130) {
                root.isRecording = false
                notifyErrorProcess.running = true
            } else {
                notifySavedProcess.running = true
            }
        }
    }

    property Process notifyErrorProcess: Process {
        id: notifyErrorProcess
        command: ["notify-send", "-u", "critical", "Screen Recorder Error", "Failed to start. Check logs."]
    }

    property Process notifySavedProcess: Process {
        id: notifySavedProcess
        command: ["notify-send", "Screen Recorder", "Recording saved to " + root.videosDir]
    }
    
    property Process stopProcess: Process {
        id: stopProcess
        command: ["killall", "-SIGINT", "gpu-screen-recorder"]
    }
}
