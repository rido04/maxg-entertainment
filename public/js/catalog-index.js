/**
 * Catalog Module - Modular JavaScript for product catalog functionality
 */

class CatalogManager {
    constructor(options = {}) {
        this.options = {
            heroSwiperSelector: ".hero-swiper",
            gridViewSelector: "#gridView",
            listViewSelector: "#listView",
            productsContainerSelector: "#productsContainer",
            viewButtonsSelector: ".view-btn",
            cartApiEndpoint: "/products/{id}/add-to-cart",
            csrfTokenSelector: 'meta[name="csrf-token"]',
            ...options,
        };

        this.heroSwiper = null;
        this.init();
    }

    init() {
        // Langsung panggil tanpa DOMContentLoaded
        this.initHeroSwiper();
        this.initViewToggle();
        this.bindEvents();
    }

    initHeroSwiper(hasBanners = true) {
        if (!hasBanners) return;

        const swiperElement = document.querySelector(
            this.options.heroSwiperSelector
        );
        if (!swiperElement) return;

        this.heroSwiper = new Swiper(this.options.heroSwiperSelector, {
            loop: true,
            autoplay: {
                delay: 5000,
                disableOnInteraction: false,
            },
            effect: "fade",
            fadeEffect: {
                crossFade: true,
            },
            pagination: {
                el: ".swiper-pagination",
                clickable: true,
            },
            navigation: {
                nextEl: ".swiper-button-next",
                prevEl: ".swiper-button-prev",
            },
        });
    }

    initViewToggle() {
        const gridView = document.querySelector(this.options.gridViewSelector);
        const listView = document.querySelector(this.options.listViewSelector);
        const productsContainer = document.querySelector(
            this.options.productsContainerSelector
        );
        const viewButtons = document.querySelectorAll(
            this.options.viewButtonsSelector
        );

        if (!gridView || !listView || !productsContainer) return;

        gridView.addEventListener("click", () => {
            this.setActiveView(viewButtons, gridView);
            this.setGridView(productsContainer);
        });

        listView.addEventListener("click", () => {
            this.setActiveView(viewButtons, listView);
            this.setListView(productsContainer);
        });
    }

    setActiveView(buttons, activeButton) {
        buttons.forEach((btn) => btn.classList.remove("active"));
        activeButton.classList.add("active");
    }

    setGridView(container) {
        container.className =
            "grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-6 transition-all duration-300";

        // Reset product cards aspect ratio
        document.querySelectorAll(".product-card").forEach((card) => {
            const aspectElement = card.querySelector(
                ".aspect-video, .aspect-square"
            );
            if (aspectElement) {
                aspectElement.classList.remove("aspect-video");
                aspectElement.classList.add("aspect-square");
            }
        });
    }

    setListView(container) {
        container.className =
            "grid grid-cols-1 md:grid-cols-2 gap-6 transition-all duration-300";

        // Update product cards for list view
        document.querySelectorAll(".product-card").forEach((card) => {
            const aspectElement = card.querySelector(".aspect-square");
            if (aspectElement) {
                aspectElement.classList.remove("aspect-square");
                aspectElement.classList.add("aspect-video");
            }
        });
    }

    bindEvents() {
        // Bind wishlist and cart events globally
        document.addEventListener("click", (e) => {
            // Wishlist toggle
            if (e.target.matches("[data-wishlist-toggle]")) {
                e.preventDefault();
                const productId = e.target.getAttribute("data-product");
                const productName =
                    e.target.getAttribute("data-product-name") || "Product";
                this.toggleWishlist(productId, productName, e.target);
            }

            // Add to cart
            if (e.target.matches("[data-add-to-cart]")) {
                e.preventDefault();
                const productId = e.target.getAttribute("data-product");
                const productName =
                    e.target.getAttribute("data-product-name") || "Product";
                this.addToCart(productId, productName);
            }
        });
    }

    toggleWishlist(productId, productName, button) {
        if (button.classList.contains("active")) {
            button.classList.remove("active");
            this.showNotification(
                `Removed ${productName} from wishlist`,
                "info"
            );
        } else {
            button.classList.add("active");
            this.showNotification(
                `Added ${productName} to wishlist`,
                "success"
            );
        }

        // Optional: Send to server
        this.sendWishlistUpdate(productId, button.classList.contains("active"));
    }

    async sendWishlistUpdate(productId, isAdding) {
        try {
            const response = await fetch(`/wishlist/${productId}`, {
                method: isAdding ? "POST" : "DELETE",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-TOKEN": this.getCSRFToken(),
                },
            });

            const data = await response.json();
            if (!data.success) {
                console.warn("Wishlist update failed:", data.message);
            }
        } catch (error) {
            console.error("Wishlist error:", error);
        }
    }

    async addToCart(productId, productName) {
        try {
            const endpoint = this.options.cartApiEndpoint.replace(
                "{id}",
                productId
            );
            const response = await fetch(endpoint, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-TOKEN": this.getCSRFToken(),
                },
                body: JSON.stringify({
                    quantity: 1,
                }),
            });

            const data = await response.json();

            if (data.success) {
                this.showNotification(data.message, "success");
                this.updateCartCount(data.cart_count);
            } else {
                this.showNotification(data.message, "error");
            }
        } catch (error) {
            console.error("Cart error:", error);
            this.showNotification("Failed to add product to cart", "error");
        }
    }

    updateCartCount(count) {
        const cartCounter = document.querySelector(".cart-counter");
        if (cartCounter) {
            cartCounter.textContent = count;

            // Add animation
            cartCounter.classList.add("animate-pulse");
            setTimeout(() => {
                cartCounter.classList.remove("animate-pulse");
            }, 1000);
        }
    }

    showNotification(message, type = "info") {
        const notification = document.createElement("div");
        const typeClasses = {
            success: "bg-green-500",
            error: "bg-red-500",
            info: "bg-blue-500",
            warning: "bg-yellow-500",
        };

        notification.className = `fixed top-4 right-4 z-50 px-6 py-3 rounded-lg shadow-lg text-white transform translate-x-full transition-transform duration-300 ${
            typeClasses[type] || typeClasses.info
        }`;
        notification.textContent = message;

        document.body.appendChild(notification);

        // Show notification
        setTimeout(() => {
            notification.classList.remove("translate-x-full");
        }, 100);

        // Hide notification
        setTimeout(() => {
            notification.classList.add("translate-x-full");
            setTimeout(() => {
                if (notification.parentNode) {
                    document.body.removeChild(notification);
                }
            }, 300);
        }, 3000);
    }

    getCSRFToken() {
        const tokenElement = document.querySelector(
            this.options.csrfTokenSelector
        );
        return tokenElement ? tokenElement.getAttribute("content") : "";
    }

    // Public methods for external control
    destroySwiper() {
        if (this.heroSwiper) {
            this.heroSwiper.destroy(true, true);
            this.heroSwiper = null;
        }
    }

    refreshSwiper() {
        if (this.heroSwiper) {
            this.heroSwiper.update();
        }
    }
}

// Export for module usage
if (typeof module !== "undefined" && module.exports) {
    module.exports = CatalogManager;
}

// Global instance for direct usage
window.CatalogManager = CatalogManager;
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
