import { defineConfig } from "vite";
import laravel from "laravel-vite-plugin";

export default defineConfig({
    plugins: [laravel(["resources/css/app.css", "resources/js/app.js"])],
    server: {
        host: true, // penting: agar bisa diakses dari IP publik
        hmr: {
            host: "localhost", // bisa juga ganti dengan IP internal
            clientPort: 5173, // default port Vite
        },
    },
});
