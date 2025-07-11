// artist-player.js
class ArtistPlayer {
    constructor(config = {}) {
        this.currentSongIndex = -1;
        this.currentAudio = null;
        this.isPlaying = false;
        this.playlist = config.playlist || [];
        this.totalSongs = config.totalSongs || 0;
        this.showingAll = false;

        this.init();
    }

    init() {
        this.setupEventListeners();
        this.setupVolumeControl();
        this.setupKeyboardShortcuts();
        this.startPlaybackMonitor();
    }

    setupEventListeners() {
        // Event listeners untuk tombol-tombol player
        const mainPlayBtn = document.getElementById("main-play-btn");
        if (mainPlayBtn) {
            mainPlayBtn.addEventListener("click", () => this.togglePlayPause());
        }

        // Event listeners untuk previous/next
        document
            .querySelectorAll('[onclick*="previousSong"]')
            .forEach((btn) => {
                btn.addEventListener("click", (e) => {
                    e.preventDefault();
                    this.previousSong();
                });
            });

        document.querySelectorAll('[onclick*="nextSong"]').forEach((btn) => {
            btn.addEventListener("click", (e) => {
                e.preventDefault();
                this.nextSong();
            });
        });

        // Event listeners untuk play buttons di song list
        document.querySelectorAll(".play-btn").forEach((btn, index) => {
            btn.addEventListener("click", (e) => {
                e.preventDefault();
                const songIndex = parseInt(
                    btn.closest(".song-row").dataset.songIndex
                );
                this.playSong(songIndex);
            });
        });
    }

    toggleShowMore() {
        const hiddenSongs = document.querySelectorAll(".song-row.hidden");
        const showMoreBtn = document.getElementById("show-more-btn");
        const showMoreText = document.getElementById("show-more-text");

        if (!this.showingAll) {
            // Show all songs
            hiddenSongs.forEach((song) => {
                song.classList.remove("hidden");
                song.style.opacity = "0";
                setTimeout(() => {
                    song.style.transition = "opacity 0.3s ease-in-out";
                    song.style.opacity = "1";
                }, 50);
            });
            showMoreText.textContent = "Show less";
            this.showingAll = true;
        } else {
            // Hide songs after index 4
            const allSongs = document.querySelectorAll(".song-row");
            allSongs.forEach((song, index) => {
                if (index >= 5) {
                    song.style.transition = "opacity 0.3s ease-in-out";
                    song.style.opacity = "0";
                    setTimeout(() => {
                        song.classList.add("hidden");
                        song.style.opacity = "1";
                    }, 300);
                }
            });
            showMoreText.textContent = `Show ${this.totalSongs - 5} more songs`;
            this.showingAll = false;
        }
    }

    playSong(index) {
        if (this.currentAudio && !this.currentAudio.paused) {
            this.currentAudio.pause();
        }

        this.currentSongIndex = index;
        const song = this.playlist[index];

        if (!song || !song.file_path) {
            console.error("Song file not found");
            return;
        }

        this.updatePlayerUI(song);
        this.updatePlayingIndicators();

        // Show player
        const player = document.getElementById("music-player");
        if (player) {
            player.classList.remove("hidden");
        }

        // Create new audio element
        this.currentAudio = new Audio(song.file_path);

        // Set volume from slider
        const volumeSlider = document.getElementById("volume-slider");
        if (volumeSlider) {
            this.currentAudio.volume = volumeSlider.value / 100;
        }

        this.setupAudioEvents();

        this.currentAudio
            .play()
            .then(() => {
                this.isPlaying = true;
                this.updatePlayButtons();
            })
            .catch((error) => {
                console.error("Error playing audio:", error);
            });
    }

    setupAudioEvents() {
        if (!this.currentAudio) return;

        this.currentAudio.addEventListener("loadedmetadata", () => {
            console.log(
                "Audio loaded:",
                this.playlist[this.currentSongIndex].title
            );
        });

        this.currentAudio.addEventListener("timeupdate", () => {
            // Progress bar functionality can be added here
        });

        this.currentAudio.addEventListener("ended", () => {
            this.nextSong();
        });

        this.currentAudio.addEventListener("error", (e) => {
            console.error("Audio error:", e);
        });
    }

    togglePlayPause() {
        if (!this.currentAudio) return;

        if (this.isPlaying) {
            this.currentAudio.pause();
            this.isPlaying = false;
        } else {
            this.currentAudio
                .play()
                .then(() => {
                    this.isPlaying = true;
                })
                .catch((error) => {
                    console.error("Error playing audio:", error);
                });
        }
        this.updatePlayButtons();
    }

    nextSong() {
        if (this.currentSongIndex < this.playlist.length - 1) {
            this.playSong(this.currentSongIndex + 1);
        } else {
            this.playSong(0); // Loop to first song
        }
    }

    previousSong() {
        if (this.currentSongIndex > 0) {
            this.playSong(this.currentSongIndex - 1);
        } else {
            this.playSong(this.playlist.length - 1); // Loop to last song
        }
    }

    updatePlayerUI(song) {
        const titleEl = document.getElementById("current-title");
        const artistEl = document.getElementById("current-artist");
        const thumbnail = document.getElementById("current-thumbnail");
        const defaultIcon = document.getElementById("default-icon");

        if (titleEl) titleEl.textContent = song.title;
        if (artistEl) artistEl.textContent = song.artist;

        if (song.thumbnail && thumbnail && defaultIcon) {
            thumbnail.src = song.thumbnail;
            thumbnail.alt = song.title;
            thumbnail.classList.remove("hidden");
            defaultIcon.classList.add("hidden");
        } else if (thumbnail && defaultIcon) {
            thumbnail.classList.add("hidden");
            defaultIcon.classList.remove("hidden");
        }
    }

    updatePlayButtons() {
        const mainPlayIcon = document.getElementById("main-play-icon");
        const mainPauseIcon = document.getElementById("main-pause-icon");

        if (mainPlayIcon && mainPauseIcon) {
            if (this.isPlaying) {
                mainPlayIcon.classList.add("hidden");
                mainPauseIcon.classList.remove("hidden");
            } else {
                mainPlayIcon.classList.remove("hidden");
                mainPauseIcon.classList.add("hidden");
            }
        }
    }

    updatePlayingIndicators() {
        // Reset all indicators
        document.querySelectorAll(".track-number").forEach((el) => {
            el.classList.remove("hidden");
        });
        document.querySelectorAll(".play-icon").forEach((el) => {
            el.classList.remove("hidden");
        });
        document.querySelectorAll(".pause-icon").forEach((el) => {
            el.classList.add("hidden");
        });

        // Update current song indicator
        const currentRow = document.querySelector(
            `[data-song-index="${this.currentSongIndex}"]`
        );
        if (currentRow) {
            const trackNumber = currentRow.querySelector(".track-number");
            const playIcon = currentRow.querySelector(".play-icon");
            const pauseIcon = currentRow.querySelector(".pause-icon");

            if (trackNumber) trackNumber.classList.add("hidden");
            if (this.isPlaying) {
                if (playIcon) playIcon.classList.add("hidden");
                if (pauseIcon) pauseIcon.classList.remove("hidden");
            } else {
                if (playIcon) playIcon.classList.remove("hidden");
                if (pauseIcon) pauseIcon.classList.add("hidden");
            }
        }
    }

    setupVolumeControl() {
        const volumeSlider = document.getElementById("volume-slider");
        if (volumeSlider) {
            volumeSlider.addEventListener("input", (e) => {
                if (this.currentAudio) {
                    this.currentAudio.volume = e.target.value / 100;
                }
            });
        }
    }

    setupKeyboardShortcuts() {
        document.addEventListener("keydown", (e) => {
            if (e.target.tagName.toLowerCase() === "input") return;

            switch (e.code) {
                case "Space":
                    e.preventDefault();
                    this.togglePlayPause();
                    break;
                case "ArrowLeft":
                    e.preventDefault();
                    this.previousSong();
                    break;
                case "ArrowRight":
                    e.preventDefault();
                    this.nextSong();
                    break;
            }
        });
    }

    startPlaybackMonitor() {
        setInterval(() => {
            if (
                this.currentAudio &&
                !this.currentAudio.paused !== this.isPlaying
            ) {
                this.isPlaying = !this.currentAudio.paused;
                this.updatePlayButtons();
                this.updatePlayingIndicators();
            }
        }, 100);
    }

    // Public method untuk toggle show more
    static toggleShowMore() {
        if (window.artistPlayer) {
            window.artistPlayer.toggleShowMore();
        }
    }
}

// Export untuk penggunaan sebagai module
if (typeof module !== "undefined" && module.exports) {
    module.exports = ArtistPlayer;
}

// Global function untuk backward compatibility
function toggleShowMore() {
    ArtistPlayer.toggleShowMore();
}

function playSong(index) {
    if (window.artistPlayer) {
        window.artistPlayer.playSong(index);
    }
}

function togglePlayPause() {
    if (window.artistPlayer) {
        window.artistPlayer.togglePlayPause();
    }
}

function nextSong() {
    if (window.artistPlayer) {
        window.artistPlayer.nextSong();
    }
}

function previousSong() {
    if (window.artistPlayer) {
        window.artistPlayer.previousSong();
    }
}
