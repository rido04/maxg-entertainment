// Storage Keys
const STORAGE_KEYS = {
    currentSong: "currentPlayingSong",
    playbackState: "audioPlaybackState",
    currentTime: "audioCurrentTime",
};

// Storage Helper (pindahkan ke file ini)
const AudioStorage = {
    save: {
        currentSong: (data) =>
            localStorage.setItem("currentSong", JSON.stringify(data)),
        playbackTime: (time) => localStorage.setItem("playbackTime", time),
        playbackState: (state) => localStorage.setItem("playbackState", state),
    },

    get: {
        currentSong: () =>
            JSON.parse(localStorage.getItem("currentSong") || "null"),
        playbackTime: () =>
            parseFloat(localStorage.getItem("playbackTime") || "0"),
        playbackState: () => localStorage.getItem("playbackState"),
    },

    clear: () => {
        localStorage.removeItem("currentSong");
        localStorage.removeItem("playbackTime");
        localStorage.removeItem("playbackState");
    },
};

// Global Audio Manager
class GlobalAudioManager {
    constructor() {
        this.audio = null;
        this.currentSong = null;
        this.init();
    }

    init() {
        this.setupAudioElement();
        this.restorePlaybackState();
        this.setupPageVisibility();
    }

    setupAudioElement() {
        // Cari audio element yang sudah ada atau buat baru
        this.audio =
            document.getElementById("audioPlayer") ||
            document.getElementById("globalAudioPlayer");

        if (!this.audio) {
            this.audio = document.createElement("audio");
            this.audio.id = "globalAudioPlayer";
            this.audio.preload = "metadata";
            document.body.appendChild(this.audio);
        }
    }

    restorePlaybackState() {
        const savedSong = AudioStorage.get.currentSong();
        const savedTime = AudioStorage.get.playbackTime();
        const savedState = AudioStorage.get.playbackState();

        if (savedSong && savedState === "playing") {
            this.restoreMiniPlayer(savedSong, savedTime);
        }
    }

    setupPageVisibility() {
        // Handle page visibility changes
        document.addEventListener("visibilitychange", function () {
            if (document.hidden) {
                const audioPlayer = document.getElementById("audioPlayer");
                if (
                    audioPlayer &&
                    !audioPlayer.paused &&
                    window.audioManager &&
                    window.audioManager.currentSong
                ) {
                    AudioStorage.save.playbackTime(audioPlayer.currentTime);
                    AudioStorage.save.playbackState(
                        audioPlayer.paused ? "paused" : "playing"
                    );
                }
            }
        });
    }

    restoreMiniPlayer(songData, currentTime) {
        // Implementation untuk restore mini player
        console.log("Restoring:", songData, currentTime);
        // Panggil fungsi yang sudah ada untuk show mini player
        if (typeof showMiniPlayer === "function") {
            showMiniPlayer(songData);
        }
    }

    saveState() {
        if (this.currentSong && this.audio) {
            AudioStorage.save.currentSong(this.currentSong);
            AudioStorage.save.playbackState(
                this.audio.paused ? "paused" : "playing"
            );
            AudioStorage.save.playbackTime(this.audio.currentTime);
        }
    }
}

// Page Load Detection
document.addEventListener("DOMContentLoaded", function () {
    // Initialize audio manager setelah DOM ready
    window.audioManager = new GlobalAudioManager();

    // Check for ongoing playback
    const savedSong = AudioStorage.get.currentSong();
    const savedTime = AudioStorage.get.playbackTime();
    const savedState = AudioStorage.get.playbackState();

    if (savedSong && savedState === "playing") {
        console.log("Found ongoing playback, restoring...");
    }
    setTimeout(() => {
        autoRestoreAudio();
    }, 100);
    setInterval(() => {
        const audioPlayer = document.getElementById("audioPlayer");
        if (
            audioPlayer &&
            !audioPlayer.paused &&
            window.audioManager &&
            window.audioManager.currentSong
        ) {
            AudioStorage.save.playbackTime(audioPlayer.currentTime);
            // Debug log (bisa dihapus nanti)
            console.log("Auto-saved time:", audioPlayer.currentTime);
        }
    }, 500);
});

// Save state before page unload
window.addEventListener("beforeunload", function () {
    const audioPlayer = document.getElementById("audioPlayer");
    if (
        audioPlayer &&
        !audioPlayer.paused &&
        window.audioManager &&
        window.audioManager.currentSong
    ) {
        // Final save before leaving
        AudioStorage.save.playbackTime(audioPlayer.currentTime);
        AudioStorage.save.playbackState("playing");
        console.log("Saved state before page unload");
    }
});

// Auto-restore function yang dipanggil setiap page load
function autoRestoreAudio() {
    const savedSong = AudioStorage.get.currentSong();
    const savedTime = AudioStorage.get.playbackTime();
    const savedState = AudioStorage.get.playbackState();

    if (savedSong && savedState === "playing") {
        console.log("Auto-restoring audio...", savedSong);

        // Restore audio dengan data yang tersimpan
        restoreAudioPlayback(savedSong, savedTime);
    }
}

// Function untuk setup event listeners di setiap halaman
function setupMiniPlayerListeners() {
    const miniPlayBtn = document.getElementById("miniPlayBtn");
    const miniCloseBtn = document.getElementById("miniCloseBtn");
    const audioPlayer = document.getElementById("audioPlayer");

    if (miniPlayBtn) {
        // Remove existing listeners (avoid duplicate)
        miniPlayBtn.replaceWith(miniPlayBtn.cloneNode(true));
        const newMiniPlayBtn = document.getElementById("miniPlayBtn");

        newMiniPlayBtn.addEventListener("click", function () {
            if (audioPlayer) {
                if (audioPlayer.paused) {
                    audioPlayer
                        .play()
                        .then(() => {
                            isPlaying = true;
                            updatePlayButton(true);
                            AudioStorage.save.playbackState("playing");
                        })
                        .catch((error) => {
                            console.error("Error playing:", error);
                        });
                } else {
                    audioPlayer.pause();
                    isPlaying = false;
                    updatePlayButton(false);
                    AudioStorage.save.playbackState("paused");
                }
            }
        });
    }

    if (miniCloseBtn) {
        miniCloseBtn.replaceWith(miniCloseBtn.cloneNode(true));
        const newMiniCloseBtn = document.getElementById("miniCloseBtn");

        newMiniCloseBtn.addEventListener("click", function () {
            if (audioPlayer) {
                audioPlayer.pause();
                audioPlayer.currentTime = 0;
            }
            AudioStorage.clear();
            if (window.audioManager) {
                window.audioManager.currentSong = null;
            }
            hideMiniPlayer();
        });
    }
}

// Update DOMContentLoaded
document.addEventListener("DOMContentLoaded", function () {
    window.audioManager = new GlobalAudioManager();

    // Setup event listeners dulu
    setTimeout(() => {
        setupMiniPlayerListeners();
        autoRestoreAudio();
    }, 100);
});

function restoreAudioPlayback(songData, resumeTime = 0) {
    const audioPlayer = document.getElementById("audioPlayer");
    const audioSource = document.getElementById("audioSource");
    const miniPlayer = document.getElementById("miniPlayer");

    if (!audioPlayer || !audioSource || !miniPlayer) return;

    // Set audio source
    audioSource.src = songData.audioUrl;
    audioPlayer.load();

    // Update mini player info
    document.getElementById("miniTitle").textContent = songData.title;
    document.getElementById("miniArtist").textContent = songData.artist;

    // Handle thumbnail
    const miniThumbnail = document.getElementById("miniThumbnail");
    const miniThumbnailPlaceholder = document.getElementById(
        "miniThumbnailPlaceholder"
    );

    if (songData.thumbnail && miniThumbnail && miniThumbnailPlaceholder) {
        miniThumbnail.src = songData.thumbnail;
        miniThumbnail.classList.remove("hidden");
        miniThumbnailPlaceholder.classList.add("hidden");
    } else if (miniThumbnail && miniThumbnailPlaceholder) {
        miniThumbnail.classList.add("hidden");
        miniThumbnailPlaceholder.classList.remove("hidden");
    }

    // Show mini player
    miniPlayer.classList.remove("hidden");
    miniPlayer.style.transform = "translateY(0)";

    // Set resume time dan play
    audioPlayer.addEventListener(
        "loadeddata",
        function () {
            audioPlayer.currentTime = resumeTime;
            audioPlayer
                .play()
                .then(() => {
                    isPlaying = true;
                    updatePlayButton(true);
                    // Update global manager
                    if (window.audioManager) {
                        window.audioManager.currentSong = songData;
                    }
                })
                .catch((error) => {
                    console.error("Error resuming audio:", error);
                });
        },
        { once: true }
    );
}
function hideMiniPlayer() {
    const miniPlayer = document.getElementById("miniPlayer");
    if (!miniPlayer) return;

    miniPlayer.style.transform = "translateY(100%)";
    setTimeout(() => {
        miniPlayer.classList.add("hidden");
    }, 300);

    if (window.audioManager) {
        window.audioManager.currentSong = null;
    }
}

// Make it global
window.hideMiniPlayer = hideMiniPlayer;
