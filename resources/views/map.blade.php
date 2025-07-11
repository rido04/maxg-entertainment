<!DOCTYPE html>
<html>
<head>
    <title>Peta Hiburan Mobil Grab</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Leaflet CDN -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <style>
        #map { height: 100vh; }
    </style>
</head>
<body>
    <div id="map"></div>

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        const map = L.map('map').setView([-6.200000, 106.816666], 15); // pusat Jakarta

        // Tile layer dari OpenStreetMap
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors'
        }).addTo(map);

        // Custom icon mobil
        const carIcon = L.icon({
            iconUrl: 'https://cdn-icons-png.flaticon.com/512/854/854894.png',
            iconSize: [40, 40],
            iconAnchor: [20, 20],
        });

        // Dummy marker mobil
        const marker = L.marker([-6.200000, 106.816666], { icon: carIcon }).addTo(map);

        // Gerakkan marker dummy setiap 2 detik
        let lat = -6.200000;
        let lng = 106.816666;

        setInterval(() => {
            lat += 0.0001;
            lng += 0.0001;
            marker.setLatLng([lat, lng]);
            map.panTo([lat, lng]);
        }, 2000);
    </script>
</body>
</html>
