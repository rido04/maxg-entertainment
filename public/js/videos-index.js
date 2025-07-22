function togglePasswordVisibility() {
    const passwordInput = document.getElementById("password");
    const eyeOpen = document.getElementById("eye-open");
    const eyeClosed = document.getElementById("eye-closed");

    if (passwordInput.type === "password") {
        passwordInput.type = "text";
        eyeOpen.classList.add("hidden");
        eyeClosed.classList.remove("hidden");
    } else {
        passwordInput.type = "password";
        eyeOpen.classList.remove("hidden");
        eyeClosed.classList.add("hidden");
    }
}

document.addEventListener("DOMContentLoaded", function () {
    // Setup untuk layout desktop biasa (bukan scroll container)
    const mainContent = document.querySelector(".main-content");
    if (mainContent) {
        const movieItems = document.querySelectorAll(".movie-item");
        const movieThumbnail = document.getElementById("movie-thumbnail");
        const defaultThumbnail = document.getElementById("default-thumbnail");

        let currentTimeout;
        let hoverTimeout;

        movieItems.forEach((item) => {
            item.addEventListener("mouseenter", function () {
                clearTimeout(currentTimeout);
                clearTimeout(hoverTimeout);

                // Remove active class dari semua items
                movieItems.forEach((movie) => {
                    movie.classList.remove("active-movie");
                });

                // Add active class ke current item
                this.classList.add("active-movie");

                // Update thumbnail content
                const thumbnail = this.dataset.thumbnail;
                const thumbnailBg = document.getElementById("thumbnail-bg");

                if (thumbnailBg && thumbnail) {
                    thumbnailBg.style.backgroundImage = `url('${thumbnail}')`;
                }

                // Show thumbnail dengan fade effect
                hoverTimeout = setTimeout(() => {
                    if (defaultThumbnail) {
                        defaultThumbnail.style.opacity = "0";
                    }
                    if (movieThumbnail) {
                        movieThumbnail.style.opacity = "1";
                    }
                }, 100);
            });

            item.addEventListener("mouseleave", function () {
                clearTimeout(hoverTimeout);

                currentTimeout = setTimeout(() => {
                    movieItems.forEach((movie) => {
                        movie.classList.remove("active-movie");
                    });
                    if (defaultThumbnail) defaultThumbnail.style.opacity = "1";
                    if (movieThumbnail) movieThumbnail.style.opacity = "0";
                }, 1500);
            });
        });

        // Keep thumbnail visible when hovering over thumbnail area
        if (movieThumbnail) {
            movieThumbnail.addEventListener("mouseenter", function () {
                clearTimeout(currentTimeout);
            });

            movieThumbnail.addEventListener("mouseleave", function () {
                currentTimeout = setTimeout(() => {
                    movieItems.forEach((movie) => {
                        movie.classList.remove("active-movie");
                    });
                    if (defaultThumbnail) defaultThumbnail.style.opacity = "1";
                    if (movieThumbnail) movieThumbnail.style.opacity = "0";
                }, 1500);
            });
        }
    }

    // Fungsi untuk update thumbnail content
    function updateThumbnailContent(item, section) {
        const thumbnail = item.dataset.thumbnail;
        const title = item.dataset.title;
        const description = item.dataset.description;
        const category = item.dataset.category;
        const duration = item.dataset.duration;

        // Gunakan selector yang benar tanpa dataset.section
        const thumbnailBg = section.querySelector("#thumbnail-bg");

        if (thumbnailBg && thumbnail) {
            thumbnailBg.style.backgroundImage = `url('${thumbnail}')`;
        } else if (thumbnailBg) {
            thumbnailBg.style.backgroundImage =
                "linear-gradient(135deg, rgba(59, 130, 246, 0.8), rgba(107, 114, 128, 0.8))";
        }
    }

    // Fungsi untuk setup hover events pada setiap section
    function setupSectionHoverEvents(section, sectionIndex) {
        if (!section) return;

        const movieItems = section.querySelectorAll(".movie-item");
        const movieThumbnail = section.querySelector(
            ".movie-thumbnail-section"
        );
        const defaultThumbnail = section.querySelector(
            ".default-thumbnail-section"
        );

        console.log(
            `Setting up section ${sectionIndex} with ${movieItems.length} movies`
        );

        let currentTimeout;
        let hoverTimeout;
        let userInteracting = false;
        let interactionTimeout;

        // Remove existing event listeners dengan cara yang lebih aman
        movieItems.forEach((item) => {
            const newItem = item.cloneNode(true);
            if (item.parentNode) {
                item.parentNode.replaceChild(newItem, item);
            }
        });

        // Get updated movie items after cloning
        const updatedMovieItems = section.querySelectorAll(".movie-item");

        // Set up hover and touch events untuk setiap movie item
        updatedMovieItems.forEach((item) => {
            // Mouseenter event
            item.addEventListener("mouseenter", function () {
                userInteracting = true;
                clearTimeout(currentTimeout);
                clearTimeout(hoverTimeout);
                clearTimeout(interactionTimeout);

                console.log("Mouse enter:", this.dataset.title);

                // Remove active class dari semua items di section ini
                updatedMovieItems.forEach((movie) => {
                    movie.classList.remove("active-movie");
                });

                // Add active class ke current item
                this.classList.add("active-movie");

                // Update thumbnail content dengan parameter section
                updateThumbnailContent(this, section);

                // Show thumbnail dengan fade effect
                hoverTimeout = setTimeout(() => {
                    if (defaultThumbnail) {
                        defaultThumbnail.style.opacity = "0";
                    }
                    if (movieThumbnail) {
                        movieThumbnail.style.opacity = "0.3";
                        setTimeout(() => {
                            if (movieThumbnail && userInteracting) {
                                movieThumbnail.style.opacity = "1";
                            }
                        }, 150);
                    }
                }, 100);
            });

            // Touchstart event (untuk perangkat layar sentuh)
            item.addEventListener("touchstart", function (e) {
                userInteracting = true;
                clearTimeout(currentTimeout);
                clearTimeout(hoverTimeout);
                clearTimeout(interactionTimeout);

                console.log("Touch start:", this.dataset.title);

                // Remove active class dari semua items di section ini
                updatedMovieItems.forEach((movie) => {
                    movie.classList.remove("active-movie");
                });

                // Add active class ke current item
                this.classList.add("active-movie");

                // Update thumbnail content
                updateThumbnailContent(this, section);

                // Show thumbnail
                if (defaultThumbnail) {
                    defaultThumbnail.style.opacity = "0";
                }
                if (movieThumbnail) {
                    movieThumbnail.style.opacity = "1";
                }
            });

            item.addEventListener("mouseleave", function () {
                console.log("Mouse leave:", this.dataset.title);
                clearTimeout(hoverTimeout);

                currentTimeout = setTimeout(() => {
                    if (!userInteracting) {
                        updatedMovieItems.forEach((movie) => {
                            movie.classList.remove("active-movie");
                        });
                        if (defaultThumbnail)
                            defaultThumbnail.style.opacity = "1";
                        if (movieThumbnail) movieThumbnail.style.opacity = "0";
                    }
                }, 1500);
            });
        });

        // Keep thumbnail visible when hovering over thumbnail area
        if (movieThumbnail) {
            movieThumbnail.addEventListener("mouseenter", function () {
                userInteracting = true;
                clearTimeout(currentTimeout);
                clearTimeout(interactionTimeout);
            });

            movieThumbnail.addEventListener("mouseleave", function () {
                currentTimeout = setTimeout(() => {
                    if (!userInteracting) {
                        updatedMovieItems.forEach((movie) => {
                            movie.classList.remove("active-movie");
                        });
                        if (defaultThumbnail)
                            defaultThumbnail.style.opacity = "1";
                        if (movieThumbnail) movieThumbnail.style.opacity = "0";
                    }
                }, 1500);

                interactionTimeout = setTimeout(() => {
                    userInteracting = false;
                }, 3000);
            });
        }
    }
    // Tambahkan fungsi ini setelah setupSectionHoverEvents
    // function setupMobileHoverEvents() {
    //     const mobileMovieItems =
    //         document.querySelectorAll(".mobile-movie-item");
    //     const mobileThumbnail = document.getElementById(
    //         "mobile-movie-thumbnail"
    //     );
    //     const mobileDefaultThumbnail = document.getElementById(
    //         "mobile-default-thumbnail"
    //     );

    //     let touchTimeout;

    //     mobileMovieItems.forEach((item) => {
    //         // Touch events untuk mobile
    //         item.addEventListener("touchstart", function (e) {
    //             clearTimeout(touchTimeout);
    //             updateMobileThumbnail(this);
    //             showMobileThumbnail();
    //         });

    //         // Mouse events untuk tablet/desktop kecil
    //         item.addEventListener("mouseenter", function () {
    //             clearTimeout(touchTimeout);
    //             updateMobileThumbnail(this);
    //             showMobileThumbnail();
    //         });

    //         item.addEventListener("mouseleave", function () {
    //             touchTimeout = setTimeout(() => {
    //                 hideMobileThumbnail();
    //             }, 1500);
    //         });
    //     });

    //     function updateMobileThumbnail(item) {
    //         const thumbnail = item.dataset.thumbnail;
    //         const title = item.dataset.title;
    //         const category = item.dataset.category;
    //         const duration = item.dataset.duration;

    //         document.getElementById(
    //             "mobile-thumbnail-bg"
    //         ).style.backgroundImage = `url('${thumbnail}')`;
    //         document.getElementById("mobile-thumbnail-title").textContent =
    //             title;
    //         document.getElementById("mobile-thumbnail-category").textContent =
    //             category;
    //         document.getElementById("mobile-thumbnail-duration").textContent =
    //             duration ? duration + " min" : "Live";
    //     }

    //     function showMobileThumbnail() {
    //         if (mobileDefaultThumbnail)
    //             mobileDefaultThumbnail.style.opacity = "0";
    //         if (mobileThumbnail) mobileThumbnail.style.opacity = "1";
    //     }

    //     function hideMobileThumbnail() {
    //         if (mobileDefaultThumbnail)
    //             mobileDefaultThumbnail.style.opacity = "1";
    //         if (mobileThumbnail) mobileThumbnail.style.opacity = "0";
    //     }
    // }
    // Initialize scroll container
    const scrollContainer = document.querySelector(".main-content-scroll");
    if (scrollContainer) {
        // Setup hover events untuk semua sections
        const sections = scrollContainer.querySelectorAll(".scroll-section");
        sections.forEach((section, index) => {
            setupSectionHoverEvents(section, index);

            // Initialize first movie in each section
            const firstMovieItem = section.querySelector(".movie-item");
            if (firstMovieItem) {
                firstMovieItem.classList.add("active-movie");
                updateThumbnailContent(firstMovieItem, section);
            }
        });

        // Intersection Observer untuk auto-scroll effect
        const observerOptions = {
            root: null,
            rootMargin: "0px",
            threshold: 0.5,
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach((entry) => {
                if (entry.isIntersecting) {
                    const sectionIndex = entry.target.dataset.section;
                    console.log(`Section ${sectionIndex} is in view`);

                    // Reset other sections dan aktifkan yang terlihat
                    const currentSection = entry.target;
                    const firstMovie =
                        currentSection.querySelector(".movie-item");

                    if (
                        firstMovie &&
                        !currentSection.querySelector(".active-movie")
                    ) {
                        setupSectionHoverEvents(currentSection, sectionIndex);

                        setTimeout(() => {
                            firstMovie.classList.add("active-movie");
                            updateThumbnailContent(firstMovie, currentSection);

                            const defaultThumbnail =
                                currentSection.querySelector(
                                    ".default-thumbnail-section"
                                );
                            const movieThumbnail = currentSection.querySelector(
                                ".movie-thumbnail-section"
                            );

                            if (defaultThumbnail)
                                defaultThumbnail.style.opacity = "0";
                            if (movieThumbnail)
                                movieThumbnail.style.opacity = "1";
                        }, 300);
                    }
                }
            });
        }, observerOptions);

        // Observe all sections
        sections.forEach((section) => {
            observer.observe(section);
        });
    }
    // setupMobileHoverEvents();

    // Update greeting based on time
    function updateGreeting() {
        const hour = new Date().getHours();
        const greetingElement = document.getElementById("greeting");

        if (greetingElement) {
            if (hour < 12) {
                greetingElement.textContent = "Good Morning";
            } else if (hour < 17) {
                greetingElement.textContent = "Good Afternoon";
            } else {
                greetingElement.textContent = "Good Evening";
            }
        }
    }

    // Update time display
    function updateTimeDisplay() {
        const now = new Date();
        const options = {
            timeZone: "Asia/Jakarta",
            hour: "2-digit",
            minute: "2-digit",
            hour12: true,
        };
        const timeString = now
            .toLocaleTimeString("en-US", options)
            .replace(/^0/, "");

        const timeElement = document.getElementById("current-time");
        if (timeElement) {
            timeElement.textContent = timeString;
        }
    }

    // Initialize greeting and time display
    updateGreeting();
    updateTimeDisplay();
    setInterval(updateTimeDisplay, 1000);

    // Search bar functionality
    const searchInput = document.querySelector('input[name="q"]');
    if (searchInput) {
        searchInput.addEventListener("focus", function () {
            this.removeAttribute("readonly");
        });
    }

    // Sync form functionality
    const syncForm = document.getElementById("syncForm");
    if (syncForm) {
        syncForm.addEventListener("submit", function (e) {
            e.preventDefault();

            const password = document.getElementById("password").value;
            const syncBtn = document.getElementById("syncBtn");
            const errorDiv = document.getElementById("error-message");
            const syncBtnText = document.getElementById("sync-btn-text");
            const syncLoading = document.getElementById("sync-loading");
            const errorText = document.getElementById("error-text");
            const successDiv = document.getElementById("success-message");
            const successText = document.getElementById("success-text");

            // Reset error
            if (errorDiv) errorDiv.classList.add("hidden");
            if (successDiv) successDiv.classList.add("hidden");

            // Show loading
            if (syncBtn) {
                syncBtn.disabled = true;
                syncBtn.innerHTML = "Verifying...";
            }
            if (syncLoading) syncLoading.classList.remove("hidden");

            // Verify password first
            fetch("/videos/verify-password", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-TOKEN":
                        document.querySelector('meta[name="csrf-token"]')
                            ?.content || "",
                },
                body: JSON.stringify({ password: password }),
            })
                .then((response) => response.json())
                .then((data) => {
                    if (data.success) {
                        // Password correct, proceed with sync
                        if (syncBtn) syncBtn.innerHTML = "Syncing...";
                        return fetch("/sync-videos", {
                            method: "GET",
                            headers: {
                                "X-CSRF-TOKEN":
                                    document.querySelector(
                                        'meta[name="csrf-token"]'
                                    )?.content || "",
                            },
                        });
                    } else {
                        throw new Error("Invalid password");
                    }
                })
                .then((response) => response.json())
                .then((data) => {
                    if (data.success) {
                        // Show success modal
                        const successModal =
                            document.getElementById("successModal");
                        if (successModal)
                            successModal.classList.remove("hidden");
                    } else {
                        throw new Error(data.message || "Sync failed");
                    }
                })
                .catch((error) => {
                    if (errorDiv) {
                        errorDiv.textContent = error.message;
                        errorDiv.classList.remove("hidden");
                    }
                })
                .finally(() => {
                    if (syncBtn) {
                        syncBtn.disabled = false;
                        syncBtn.innerHTML = "Start Sync";
                    }
                    const passwordInput = document.getElementById("password");
                    if (passwordInput) passwordInput.value = "";
                });
        });
    }
});
