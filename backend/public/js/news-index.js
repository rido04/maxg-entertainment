// Initialize Swiper
document.addEventListener("DOMContentLoaded", function () {
    const swiper = new Swiper(".featured-swiper", {
        slidesPerView: 1,
        spaceBetween: 24,
        loop: true,
        autoplay: {
            delay: 6000,
            disableOnInteraction: false,
            pauseOnMouseEnter: true,
        },
        pagination: {
            el: ".swiper-pagination",
            clickable: true,
            dynamicBullets: true,
        },
        navigation: {
            nextEl: ".swiper-button-next",
            prevEl: ".swiper-button-prev",
        },
        breakpoints: {
            640: {
                slidesPerView: 1,
                spaceBetween: 24,
            },
            768: {
                slidesPerView: 2,
                spaceBetween: 24,
            },
            1024: {
                slidesPerView: 3,
                spaceBetween: 24,
            },
        },
        effect: "slide",
        speed: 800,
    });
});

// Enhanced Tab functionality
function showTab(tab, buttonElement) {
    // Update indicator position
    const indicator = document.querySelector(".tab-indicator");
    const buttonRect = buttonElement.getBoundingClientRect();
    const containerRect = buttonElement.parentElement.getBoundingClientRect();
    const leftPosition = buttonRect.left - containerRect.left;

    indicator.style.left = leftPosition + "px";
    indicator.style.width = buttonRect.width + "px";

    // Hide all tab contents with stagger animation
    const allContents = document.querySelectorAll(".tab-content");
    allContents.forEach((content, index) => {
        setTimeout(() => {
            content.style.opacity = "0";
            content.style.transform = "translateY(20px) scale(0.95)";
            setTimeout(() => {
                content.classList.add("hidden");
            }, 200);
        }, index * 50);
    });

    // Show selected tab content with animation
    setTimeout(() => {
        const targetTab = document.querySelector(`#${tab}`);
        if (targetTab) {
            targetTab.classList.remove("hidden");
            setTimeout(() => {
                targetTab.style.opacity = "1";
                targetTab.style.transform = "translateY(0) scale(1)";
            }, 100);
        }
    }, 300);

    // Update button states
    document.querySelectorAll(".tab-button").forEach((button) => {
        button.classList.remove("active");
    });
    buttonElement.classList.add("active");

    // Add ripple effect
    createRipple(buttonElement);
}

// Ripple effect function
function createRipple(element) {
    const ripple = document.createElement("div");
    const rect = element.getBoundingClientRect();
    const size = Math.max(rect.width, rect.height);

    ripple.style.width = ripple.style.height = size + "px";
    ripple.style.left = "50%";
    ripple.style.top = "50%";
    ripple.style.transform = "translate(-50%, -50%) scale(0)";
    ripple.style.borderRadius = "50%";
    ripple.style.background = "rgba(255, 255, 255, 0.3)";
    ripple.style.position = "absolute";
    ripple.style.pointerEvents = "none";
    ripple.style.transition = "transform 0.6s ease-out, opacity 0.6s ease-out";
    ripple.style.zIndex = "1";

    element.style.position = "relative";
    element.style.overflow = "hidden";
    element.appendChild(ripple);

    requestAnimationFrame(() => {
        ripple.style.transform = "translate(-50%, -50%) scale(1)";
        ripple.style.opacity = "0";
    });

    setTimeout(() => {
        ripple.remove();
    }, 600);
}

document.addEventListener("DOMContentLoaded", function () {
    const activeButton = document.querySelector(".tab-button.active");
    if (activeButton) {
        const indicator = document.querySelector(".tab-indicator");
        const buttonRect = activeButton.getBoundingClientRect();
        const containerRect =
            activeButton.parentElement.getBoundingClientRect();

        indicator.style.left = buttonRect.left - containerRect.left + "px";
        indicator.style.width = buttonRect.width + "px";
    }
});

// Handle window resize for indicator repositioning
window.addEventListener("resize", function () {
    const activeButton = document.querySelector(".tab-button.active");
    if (activeButton) {
        const indicator = document.querySelector(".tab-indicator");
        const buttonRect = activeButton.getBoundingClientRect();
        const containerRect =
            activeButton.parentElement.getBoundingClientRect();

        indicator.style.left = buttonRect.left - containerRect.left + "px";
        indicator.style.width = buttonRect.width + "px";
    }
});

// Add smooth scrolling
document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
    anchor.addEventListener("click", function (e) {
        e.preventDefault();
        document.querySelector(this.getAttribute("href")).scrollIntoView({
            behavior: "smooth",
        });
    });
});
