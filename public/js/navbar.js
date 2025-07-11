document.addEventListener("DOMContentLoaded", () => {
    const navToggle = document.getElementById("navToggle");
    const toggleContainer = document.getElementById("toggleContainer");
    const navigationMenu = document.getElementById("navigationMenu");
    const toggleIcon = document.getElementById("toggleIcon");
    const navLinks = document.querySelectorAll(".nav-link");
    const currentPath = window.location.pathname;
    let isMenuOpen = false;

    // Toggle navigation menu
    navToggle.addEventListener("click", () => {
        isMenuOpen = !isMenuOpen;

        if (isMenuOpen) {
            // Show menu first
            navigationMenu.classList.remove(
                "opacity-0",
                "translate-x-8",
                "pointer-events-none"
            );
            navigationMenu.classList.add(
                "opacity-100",
                "translate-x-0",
                "pointer-events-auto"
            );

            // Move toggle button to the left after a short delay
            setTimeout(() => {
                const toggleOffset = 80; // Distance to move left (navbar width + spacing)
                toggleContainer.style.transform = `translate(-${toggleOffset}px, -50%)`;
            }, 100);

            // Rotate icon (arrow pointing right)
            toggleIcon.style.transform = "rotate(180deg)";

            // Change button background slightly when active
            navToggle.classList.add("bg-green-500");
        } else {
            // Hide menu
            navigationMenu.classList.remove(
                "opacity-100",
                "translate-x-0",
                "pointer-events-auto"
            );
            navigationMenu.classList.add(
                "opacity-0",
                "translate-x-8",
                "pointer-events-none"
            );

            // Move toggle button back to center
            toggleContainer.style.transform = "translate(0, -50%)";

            // Rotate icon back (arrow pointing left)
            toggleIcon.style.transform = "rotate(0deg)";

            // Remove active background
            navToggle.classList.remove("bg-green-500/20");
        }
    });

    // Close menu when clicking anywhere else
    document.addEventListener("click", (e) => {
        if (
            !navToggle.contains(e.target) &&
            !navigationMenu.contains(e.target) &&
            isMenuOpen
        ) {
            isMenuOpen = false;
            navigationMenu.classList.remove(
                "opacity-100",
                "translate-x-0",
                "pointer-events-auto"
            );
            navigationMenu.classList.add(
                "opacity-0",
                "translate-x-8",
                "pointer-events-none"
            );
            toggleContainer.style.transform = "translate(0, -50%)";
            toggleIcon.style.transform = "rotate(0deg)";
            navToggle.classList.remove("bg-green-500/20");
        }
    });

    // Set active navigation
    function setActiveNav() {
        navLinks.forEach((link) => {
            const href = link.getAttribute("href");
            link.classList.remove("text-green-400", "bg-green-500/20");
            link.classList.add("text-slate-400");

            let isActive = false;
            if (href === "/" && currentPath === "/") {
                isActive = true;
            } else if (
                href.includes("videos") &&
                currentPath.startsWith("/videos")
            ) {
                isActive = true;
            } else if (
                href.includes("music") &&
                currentPath.startsWith("/music")
            ) {
                isActive = true;
            } else if (
                href.includes("games") &&
                currentPath.startsWith("/games")
            ) {
                isActive = true;
            } else if (
                href.includes("about") &&
                currentPath.startsWith("/about")
            ) {
                isActive = true;
            } else if (
                href.includes("news") &&
                currentPath.startsWith("/news")
            ) {
                isActive = true;
            } else if (
                href.includes("shop") &&
                currentPath.startsWith("/shop")
            ) {
                isActive = true;
            } else if (
                href.includes("route") &&
                currentPath.startsWith("/route")
            ) {
                isActive = true;
            }

            if (isActive) {
                link.classList.remove("text-slate-400");
                link.classList.add("text-green-400", "bg-green-500/20");
            }
        });
    }

    setActiveNav();

    // Add smooth hover animation for nav links
    navLinks.forEach((link) => {
        link.addEventListener("mouseenter", () => {
            if (!link.classList.contains("text-green-400")) {
                link.style.transform = "scale(1.1)";
            }
        });

        link.addEventListener("mouseleave", () => {
            if (!link.classList.contains("text-green-400")) {
                link.style.transform = "scale(1)";
            }
        });
    });
});
