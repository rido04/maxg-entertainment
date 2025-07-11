document.addEventListener("DOMContentLoaded", function () {
    // Initialize Main Swiper
    const mainSwiper = new Swiper(".aboutSwiper", {
        // Basic settings
        slidesPerView: 1,
        spaceBetween: 30,
        centeredSlides: true,
        // Loop - disabled to prevent the error
        loop: false,
        // Auto height
        autoHeight: true,
        // Speed
        speed: 800,
        // Effects
        effect: "slide",

        // Navigation
        navigation: {
            nextEl: ".main-next",
            prevEl: ".main-prev",
        },
        // Autoplay
        autoplay: {
            delay: 12000,
            disableOnInteraction: true,
            pauseOnMouseEnter: true,
        },
        // Pagination
        pagination: {
            el: ".main-pagination",
            clickable: true,
        },
        // Keyboard control
        keyboard: {
            enabled: true,
            onlyInViewport: true,
        },
        // Touch settings
        touchRatio: 1,
        touchAngle: 45,
    });

    // Fix untuk horizontal scroll di subsidiaries
    const horizontalScrollContainer =
        document.querySelector(".horizontal-scroll");
    if (horizontalScrollContainer) {
        // Pastikan smooth scrolling bekerja
        horizontalScrollContainer.style.scrollBehavior = "smooth";

        // Touch support untuk mobile
        let isDown = false;
        let startX;
        let scrollLeft;

        horizontalScrollContainer.addEventListener("mousedown", (e) => {
            isDown = true;
            horizontalScrollContainer.classList.add("active");
            startX = e.pageX - horizontalScrollContainer.offsetLeft;
            scrollLeft = horizontalScrollContainer.scrollLeft;
        });

        horizontalScrollContainer.addEventListener("mouseleave", () => {
            isDown = false;
            horizontalScrollContainer.classList.remove("active");
        });

        horizontalScrollContainer.addEventListener("mouseup", () => {
            isDown = false;
            horizontalScrollContainer.classList.remove("active");
        });

        horizontalScrollContainer.addEventListener("mousemove", (e) => {
            if (!isDown) return;
            e.preventDefault();
            const x = e.pageX - horizontalScrollContainer.offsetLeft;
            const walk = (x - startX) * 2;
            horizontalScrollContainer.scrollLeft = scrollLeft - walk;
        });
    }
});
