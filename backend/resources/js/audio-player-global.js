// Storage Keys
const STORAGE_KEYS = {
    currentSong: "currentPlayingSong",
    playbackState: "audioPlaybackState",
    currentTime: "audioCurrentTime",
};

// Global Audio Manager
class GlobalAudioManager {
    constructor() {
        this.audio = null;
        this.init();
    }

    init() {
        // Create or get existing audio element
        this.setupAudioElement();
        // Check if there's ongoing playback
        this.restorePlaybackState();
        // Setup page visibility handling
        this.setupPageVisibility();
    }

    saveState() {
        if (this.currentSong) {
            localStorage.setItem(
                STORAGE_KEYS.currentSong,
                JSON.stringify(this.currentSong)
            );
            localStorage.setItem(
                STORAGE_KEYS.playbackState,
                this.audio.paused ? "paused" : "playing"
            );
            localStorage.setItem(
                STORAGE_KEYS.currentTime,
                this.audio.currentTime
            );
        }
    }

    restorePlaybackState() {
        const savedSong = localStorage.getItem(STORAGE_KEYS.currentSong);
        if (savedSong) {
            // Restore mini player and continue playback
        }
    }
}

// Initialize global manager
window.audioManager = new GlobalAudioManager();
