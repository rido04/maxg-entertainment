import "./bootstrap";
import Alpine from "alpinejs";
import Swiper from "swiper";
import {
    Navigation,
    Pagination,
    Autoplay,
    EffectFade,
    Keyboard,
    Mousewheel,
    EffectCards,
    EffectFlip,
    EffectCreative,
} from "swiper/modules";
import "swiper/css";
import "swiper/css/navigation";
import "swiper/css/pagination";
import "swiper/css/effect-fade";
import "swiper/css/effect-cards";
import "swiper/css/effect-flip";

Swiper.use([
    Navigation,
    Pagination,
    Autoplay,
    EffectFade,
    Keyboard,
    Mousewheel,
    EffectCards,
    EffectFlip,
    EffectCreative,
]);
window.Swiper = Swiper;
window.Alpine = Alpine;
Alpine.start();

fetch("/run-scheduler")
    .then((response) => response.json())
    .then((data) => console.log(data.status))
    .catch((error) => console.error("Scheduler trigger error:", error));

window.addEventListener("beforeunload", function () {
    const loader = document.getElementById("loader");
    if (loader) {
        loader.classList.remove("hidden");
    }
});

window.addEventListener("load", function () {
    const loader = document.getElementById("loader");
    if (loader) {
        loader.classList.add("hidden");
    }
});
