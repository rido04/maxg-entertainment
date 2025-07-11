document.addEventListener("DOMContentLoaded", function () {
    const video = document.querySelector("#routeVideo");
    const playButton = document.querySelector("#playButton");

    // Handle video play/pause
    function toggleVideo() {
        if (video.paused) {
            video.play().catch((error) => {
                console.log("Video play failed:", error);
            });
        } else {
            video.pause();
        }
    }

    // Try to autoplay video
    video.play().catch((error) => {
        console.log("Autoplay was prevented:", error);
        // Show play button if autoplay fails
        playButton.classList.remove("hidden");
    });

    // Play button click handler
    playButton.addEventListener("click", function () {
        toggleVideo();
        this.classList.add("hidden");
    });

    // Remove controls entirely
    video.removeAttribute("controls");

    // Handle video events
    video.addEventListener("play", function () {
        playButton.classList.add("hidden");
    });

    video.addEventListener("pause", function () {
        playButton.classList.remove("hidden");
    });

    // Smooth scroll animation for feature cards
    const observer = new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = "1";
                entry.target.style.transform = "translateY(0)";
            }
        });
    });

    document.querySelectorAll(".feature-card").forEach((card) => {
        card.style.opacity = "0";
        card.style.transform = "translateY(20px)";
        card.style.transition = "opacity 0.6s ease, transform 0.6s ease";
        observer.observe(card);
    });
});
