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
