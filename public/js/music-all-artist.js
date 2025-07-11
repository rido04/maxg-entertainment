document.addEventListener("DOMContentLoaded", function () {
    const searchInput = document.getElementById("artistSearch");
    const searchForm = document.getElementById("searchForm");
    let searchTimeout;

    // Auto-submit search form with debounce
    searchInput.addEventListener("input", function (e) {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            searchForm.submit();
        }, 500); // Wait 500ms after user stops typing
    });

    // Add keyboard navigation
    searchInput.addEventListener("keydown", function (e) {
        if (e.key === "Escape") {
            e.target.value = "";
            clearTimeout(searchTimeout);
            searchForm.submit();
        }
        if (e.key === "Enter") {
            e.preventDefault();
            clearTimeout(searchTimeout);
            searchForm.submit();
        }
    });

    // Scroll to top functionality
    const scrollBtn = document.getElementById("scrollToTop");

    window.addEventListener("scroll", function () {
        if (window.pageYOffset > 300) {
            scrollBtn.classList.remove("opacity-0", "pointer-events-none");
            scrollBtn.classList.add("opacity-100");
        } else {
            scrollBtn.classList.add("opacity-0", "pointer-events-none");
            scrollBtn.classList.remove("opacity-100");
        }
    });

    scrollBtn.addEventListener("click", function () {
        window.scrollTo({
            top: 0,
            behavior: "smooth",
        });
    });
});

// Change items per page
function changePerPage(perPage) {
    const url = new URL(window.location);
    url.searchParams.set("per_page", perPage);
    url.searchParams.delete("page"); // Reset to first page
    window.location.href = url.toString();
}

// Jump to specific page
function jumpToPage(page) {
    const url = new URL(window.location);
    url.searchParams.set("page", page);
    window.location.href = url.toString();
}
