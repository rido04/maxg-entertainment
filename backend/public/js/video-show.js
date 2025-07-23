// Real-time clock function
function updateClock() {
    const now = new Date();

    // Format time (12-hour format with AM/PM)
    let hours = now.getHours();
    const minutes = now.getMinutes().toString().padStart(2, "0");
    const ampm = hours >= 12 ? "PM" : "AM";
    hours = hours % 12;
    hours = hours ? hours : 12; // 0 should be 12
    const timeString = `${hours}:${minutes} ${ampm}`;

    // Format date
    const options = {
        weekday: "short",
        day: "numeric",
        month: "short",
    };
    const dateString = now.toLocaleDateString("id-ID", options) + " WIB";

    // Update display
    document.getElementById("currentTime").textContent = timeString;
    document.getElementById("currentDate").textContent = dateString;
}

// Update clock immediately and then every second
updateClock();
setInterval(updateClock, 1000);

function playFullscreen(videoUrl) {
    const modal = document.getElementById("fullscreenModal");
    const video = document.getElementById("fullscreenVideo");
    const loader = document.getElementById("videoLoader");
    const source = video.querySelector("source");

    // Show modal and loader
    modal.classList.remove("hidden");
    loader.style.display = "flex";

    // Set video source
    source.src = videoUrl;
    video.load();

    // Hide loader when video can play
    video.addEventListener("canplay", function () {
        loader.style.display = "none";
    });

    // Handle video load error
    video.addEventListener("error", function () {
        loader.style.display = "none";
        alert("Error loading video. Please try again.");
        closeFullscreen();
    });

    // Auto-hide controls after 3 seconds when playing
    let controlsTimeout;
    video.addEventListener("play", function () {
        clearTimeout(controlsTimeout);
        controlsTimeout = setTimeout(() => {
            video.controls = false;
            setTimeout(() => {
                video.controls = true;
            }, 100);
        }, 3000);
    });

    // Show controls on mouse move
    video.addEventListener("mousemove", function () {
        video.controls = true;
        clearTimeout(controlsTimeout);
        controlsTimeout = setTimeout(() => {
            video.controls = false;
            setTimeout(() => {
                video.controls = true;
            }, 100);
        }, 3000);
    });
}

function closeFullscreen() {
    const modal = document.getElementById("fullscreenModal");
    const video = document.getElementById("fullscreenVideo");

    // Pause video
    video.pause();
    video.currentTime = 0;

    // Hide modal
    modal.classList.add("hidden");

    // Clear video source
    video.querySelector("source").src = "";
    video.load();
}

// Close fullscreen on Escape key
document.addEventListener("keydown", function (e) {
    if (e.key === "Escape") {
        closeFullscreen();
    }
});

// Close fullscreen when clicking outside video
document
    .getElementById("fullscreenModal")
    .addEventListener("click", function (e) {
        if (e.target === this) {
            closeFullscreen();
        }
    });

// Smooth scroll behavior
document.documentElement.style.scrollBehavior = "smooth";
