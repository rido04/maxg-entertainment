// Navbar Functionality
document.addEventListener("DOMContentLoaded", function () {
    const navbar = document.getElementById("navbar");
    const mobileMenuBtn = document.getElementById("mobile-menu-btn");
    const mobileMenu = document.getElementById("mobile-menu");
    const navbarLogo = document.getElementById("navbar-logo");

    // Mobile menu toggle
    mobileMenuBtn.addEventListener("click", function () {
        mobileMenu.classList.toggle("hidden");

        // Toggle hamburger to X
        const icon = this.querySelector("svg");
        if (mobileMenu.classList.contains("hidden")) {
            icon.innerHTML =
                '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>';
        } else {
            icon.innerHTML =
                '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>';
        }
    });

    // Navbar scroll effect
    let lastScrollTop = 0;
    const scrollThreshold = 100;

    window.addEventListener("scroll", function () {
        const scrollTop =
            window.pageYOffset || document.documentElement.scrollTop;

        if (scrollTop > scrollThreshold) {
            // Add condensed style when scrolled
            navbar.classList.add("shadow-2xl");
            navbar.classList.remove("shadow-lg");
            navbarLogo.classList.add("h-6");
            navbarLogo.classList.remove("h-8");

            // Hide/show navbar based on scroll direction
            if (scrollTop > lastScrollTop && scrollTop > 200) {
                // Scrolling down
                navbar.style.transform = "translateY(-100%)";
            } else {
                // Scrolling up
                navbar.style.transform = "translateY(0)";
            }
        } else {
            // Reset to normal style
            navbar.classList.remove("shadow-2xl");
            navbar.classList.add("shadow-lg");
            navbarLogo.classList.remove("h-6");
            navbarLogo.classList.add("h-8");
            navbar.style.transform = "translateY(0)";
        }

        lastScrollTop = scrollTop;
    });

    // Close mobile menu when clicking outside
    document.addEventListener("click", function (event) {
        if (
            !navbar.contains(event.target) &&
            !mobileMenu.classList.contains("hidden")
        ) {
            mobileMenu.classList.add("hidden");
            const icon = mobileMenuBtn.querySelector("svg");
            icon.innerHTML =
                '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>';
        }
    });

    // Close mobile menu on window resize
    window.addEventListener("resize", function () {
        if (window.innerWidth >= 1024) {
            mobileMenu.classList.add("hidden");
            const icon = mobileMenuBtn.querySelector("svg");
            icon.innerHTML =
                '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>';
        }
    });
});
// Fungsi untuk mengganti gambar utama
function changeMainImage(src) {
    document.getElementById("mainImage").src = src;

    // Update thumbnail active state
    document.querySelectorAll(".flex-shrink-0").forEach((thumb) => {
        thumb.classList.remove("border-teal-500");
        thumb.classList.add("border-transparent");
    });
    event.target.parentElement.classList.add("border-teal-500");
    event.target.parentElement.classList.remove("border-transparent");
}

// Fungsi untuk menampilkan pesan
function showMessage(text, type = "info") {
    const messageDiv = document.getElementById("message");
    const messageText = document.getElementById("messageText");
    const messageContainer = messageDiv.querySelector("div");

    messageText.textContent = text;

    // Change color based on type
    switch (type) {
        case "error":
            messageContainer.className =
                "bg-red-500 text-white px-6 py-3 rounded-lg shadow-lg flex items-center space-x-2";
            break;
        case "success":
            messageContainer.className =
                "bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg flex items-center space-x-2";
            break;
        default:
            messageContainer.className =
                "bg-blue-500 text-white px-6 py-3 rounded-lg shadow-lg flex items-center space-x-2";
    }

    messageDiv.classList.remove("hidden");

    setTimeout(() => {
        messageDiv.classList.add("hidden");
    }, 4000);
}

// Fungsi untuk menampilkan pesan pembelian
function showPurchaseMessage() {
    showMessage(
        "This is a demo version. Visit the official GarudaShop website to make a purchase!",
        "info"
    );
}
