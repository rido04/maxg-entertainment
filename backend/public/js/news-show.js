// Smooth scroll for back button
document.addEventListener("DOMContentLoaded", function () {
    // Add reading progress indicator
    const progressBar = document.createElement("div");
    progressBar.className =
        "fixed top-0 left-0 w-0 h-1 bg-gradient-to-r from-blue-800 to-purple-500 z-50 transition-all duration-300";
    document.body.appendChild(progressBar);

    window.addEventListener("scroll", function () {
        const scrollTop = window.pageYOffset;
        const docHeight = document.body.scrollHeight - window.innerHeight;
        const scrollPercent = (scrollTop / docHeight) * 100;
        progressBar.style.width = scrollPercent + "%";
    });

    // Lazy loading for recommendation images
    const observerOptions = {
        root: null,
        rootMargin: "50px",
        threshold: 0.1,
    };

    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach((entry) => {
            if (entry.isIntersecting) {
                const img = entry.target;
                const src = img.getAttribute("data-src");
                if (src) {
                    img.src = src;
                    img.removeAttribute("data-src");
                    observer.unobserve(img);
                }
            }
        });
    }, observerOptions);

    document.querySelectorAll("img[data-src]").forEach((img) => {
        imageObserver.observe(img);
    });

    // Add animation to elements when they come into view
    const animateOnScroll = new IntersectionObserver(
        (entries) => {
            entries.forEach((entry) => {
                if (entry.isIntersecting) {
                    entry.target.classList.add("animate-fadeInUp");
                    animateOnScroll.unobserve(entry.target);
                }
            });
        },
        {
            threshold: 0.1,
        }
    );

    document.querySelectorAll(".article-content > *").forEach((el) => {
        el.classList.add(
            "opacity-0",
            "translate-y-6",
            "transition-all",
            "duration-500",
            "ease-out"
        );
        animateOnScroll.observe(el);
    });
});

// Add smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
    anchor.addEventListener("click", function (e) {
        e.preventDefault();
        document.querySelector(this.getAttribute("href")).scrollIntoView({
            behavior: "smooth",
        });
    });
});
