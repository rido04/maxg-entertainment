<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Route Map</title>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            overflow: hidden;
        }

        #mapContainer {
            width: 100%;
            height: 100vh;
            position: relative;
        }

        #map {
            width: 100%;
            height: 100%;
        }

        .car-icon {
            width: 30px;
            height: 30px;
            background: #4CAF50;
            border: 3px solid white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.3);
            transform: translate(-50%, -50%);
        }

        .car-icon::before {
            content: "🚗";
            font-size: 18px;
        }

        #gpsStatus {
            position: absolute;
            top: 10px;
            right: 10px;
            background: rgba(0, 0, 0, 0.8);
            color: white;
            padding: 10px;
            border-radius: 5px;
            font-family: Arial, sans-serif;
            z-index: 1000;
        }

        #gpsButton {
            position: absolute;
            bottom: 20px;
            right: 20px;
            background: #4CAF50;
            color: white;
            border: none;
            padding: 15px;
            border-radius: 50%;
            font-size: 16px;
            cursor: pointer;
            z-index: 1000;
            box-shadow: 0 2px 10px rgba(0,0,0,0.3);
        }

        #gpsButton:hover {
            background: #45a049;
        }

        #gpsButton:disabled {
            background: #cccccc;
            cursor: not-allowed;
        }

        #directionInfo {
            position: absolute;
            top: 70px;
            right: 10px;
            background: rgba(0, 0, 0, 0.8);
            color: white;
            padding: 10px;
            border-radius: 5px;
            font-family: Arial, sans-serif;
            z-index: 1000;
            font-size: 12px;
        }

        /* Peek mode adjustments */
        .peek-mode #gpsStatus {
            font-size: 10px;
            padding: 4px 8px;
            top: 5px;
            right: 5px;
        }

        .peek-mode #gpsButton {
            bottom: 10px;
            right: 10px;
            padding: 8px;
            font-size: 12px;
        }

        .peek-mode #directionInfo {
            top: 35px;
            right: 5px;
            font-size: 10px;
            padding: 4px 8px;
        }
    </style>
</head>
<body>
    <div id="mapContainer">
        <div id="map"></div>
        <div id="gpsStatus">GPS: Tidak aktif</div>
        <div id="directionInfo">Arah: Lurus</div>
        <button id="gpsButton">📍</button>
    </div>

    <script>
        let map;
        let userLocationMarker = null;
        let gpsWatchId = null;
        let isGPSActive = false;
        let hasAttemptedGPSStart = false; // Flag untuk mencegah multiple attempts

        // Variables for direction detection
        let previousPosition = null;
        let positionHistory = [];
        let currentBearing = 0;
        let previousBearing = 0;
        const HISTORY_SIZE = 5; // Number of positions to keep for smoothing
        const MIN_DISTANCE = 5; // Minimum distance in meters to consider movement
        const TURN_THRESHOLD = 15; // Degrees threshold to detect turn

        // Default position (Jakarta)
        const defaultLat = -6.200000;
        const defaultLng = 106.816666;

        // Car images for different directions (fallback to placeholder if images not available)
        const carImages = {
            straight: '/model/camry/camry-top.png',
            left: '/model/camry/camry-turn-left.png',
            right: '/model/camry/camry-turn-right.png'
        };

        // Initialize map
        function initMap() {
            map = L.map('map').setView([defaultLat, defaultLng], 18);

            // Add OpenStreetMap tiles
            L.tileLayer('https://a.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap contributors',
                maxZoom: 19 // Allow maximum zoom for street-level detail
            }).addTo(map);

            // Add initial marker at default location
            addUserLocationMarker(defaultLat, defaultLng, false);

            // Fix map size issues in iframe
            setTimeout(() => {
                map.invalidateSize();
            }, 100);
        }

        // Calculate bearing between two points
        function calculateBearing(lat1, lng1, lat2, lng2) {
            const dLng = (lng2 - lng1) * Math.PI / 180;
            const lat1Rad = lat1 * Math.PI / 180;
            const lat2Rad = lat2 * Math.PI / 180;

            const y = Math.sin(dLng) * Math.cos(lat2Rad);
            const x = Math.cos(lat1Rad) * Math.sin(lat2Rad) - Math.sin(lat1Rad) * Math.cos(lat2Rad) * Math.cos(dLng);

            let bearing = Math.atan2(y, x) * 180 / Math.PI;
            return (bearing + 360) % 360; // Normalize to 0-360
        }

        // Calculate distance between two points (Haversine formula)
        function calculateDistance(lat1, lng1, lat2, lng2) {
            const R = 6371000; // Earth's radius in meters
            const dLat = (lat2 - lat1) * Math.PI / 180;
            const dLng = (lng2 - lng1) * Math.PI / 180;

            const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
                      Math.sin(dLng/2) * Math.sin(dLng/2);

            const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
            return R * c;
        }

        // Detect turn direction
        function detectTurnDirection(currentBearing, previousBearing) {
            let bearingDiff = currentBearing - previousBearing;

            // Normalize bearing difference to -180 to 180
            if (bearingDiff > 180) bearingDiff -= 360;
            if (bearingDiff < -180) bearingDiff += 360;

            if (Math.abs(bearingDiff) < TURN_THRESHOLD) {
                return 'straight';
            } else if (bearingDiff > 0) {
                return 'right';
            } else {
                return 'left';
            }
        }

        // Update direction info display
        function updateDirectionInfo(direction, bearing) {
            const directionText = {
                'straight': 'Lurus',
                'left': 'Belok Kiri',
                'right': 'Belok Kanan'
            };

            document.getElementById('directionInfo').innerHTML =
                `Arah: ${directionText[direction]}<br>Bearing: ${Math.round(bearing)}°`;
        }

        function addUserLocationMarker(lat, lng, isRealLocation = true, direction = 'straight') {
            // Try to use custom car image, fallback to emoji if not available
            const carIconUrl = carImages[direction] || carImages.straight;

            // Create a function to handle image loading
            function createCarIcon(useImage = true) {
                if (useImage) {
                    return L.icon({
                        iconUrl: carIconUrl,
                        iconSize: [50, 100],
                        iconAnchor: [30, 60],
                        popupAnchor: [0, -60],
                    });
                } else {
                    // Fallback to emoji-based icon
                    const carIconHtml = `
                        <div style="
                            width: 30px;
                            height: 30px;
                            background: #4CAF50;
                            border: 3px solid white;
                            border-radius: 50%;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 16px;
                            box-shadow: 0 2px 10px rgba(0,0,0,0.3);
                            transform: translate(-50%, -50%);
                        ">🚗</div>
                    `;

                    return L.divIcon({
                        html: carIconHtml,
                        iconSize: [30, 30],
                        iconAnchor: [15, 15],
                        popupAnchor: [0, -15],
                        className: 'custom-car-icon'
                    });
                }
            }

            // Try to create icon with image first
            let carIcon;
            try {
                carIcon = createCarIcon(true);
            } catch (error) {
                // Fallback to emoji icon if image fails
                carIcon = createCarIcon(false);
            }

            // Update or create user location marker
            if (userLocationMarker) {
                userLocationMarker.setLatLng([lat, lng]);
                userLocationMarker.setIcon(carIcon);
            } else {
                userLocationMarker = L.marker([lat, lng], { icon: carIcon }).addTo(map);
            }

            // Set popup text based on whether it's real GPS location or default
            const popupText = isRealLocation ? 'Anda disini' : 'Lokasi Default';
            userLocationMarker.bindPopup(popupText);

            if (isRealLocation) {
                userLocationMarker.openPopup();
            }
        }

        // GPS Functions
        function checkGPSSupport() {
            if (!navigator.geolocation) {
                updateGPSStatus('GPS tidak didukung pada browser ini');
                document.getElementById('gpsButton').disabled = true;
                return false;
            }

            return true;
        }

        function updateGPSStatus(message) {
            document.getElementById('gpsStatus').textContent = `GPS: ${message}`;
        }

        function toggleGPS() {
            if (!checkGPSSupport()) return;

            if (isGPSActive) {
                stopGPS();
            } else {
                startGPS();
            }
        }

        function startGPS() {
            updateGPSStatus('Meminta izin lokasi...');

            const options = {
                enableHighAccuracy: true,
                timeout: 10000,
                maximumAge: 0
            };

            navigator.geolocation.getCurrentPosition(
                (position) => {
                    updateGPSStatus('GPS aktif');
                    isGPSActive = true;
                    document.getElementById('gpsButton').style.background = '#f44336';
                    document.getElementById('gpsButton').textContent = '⏹️';

                    // Reset direction tracking
                    previousPosition = null;
                    positionHistory = [];
                    currentBearing = 0;
                    previousBearing = 0;

                    gpsWatchId = navigator.geolocation.watchPosition(
                        updateUserLocation,
                        handleGPSError,
                        options
                    );
                },
                handleGPSError,
                options
            );
        }

        function stopGPS() {
            if (gpsWatchId !== null) {
                navigator.geolocation.clearWatch(gpsWatchId);
                gpsWatchId = null;
            }

            isGPSActive = false;
            updateGPSStatus('GPS dimatikan');
            document.getElementById('gpsButton').style.background = '#4CAF50';
            document.getElementById('gpsButton').textContent = '📍';

            // Reset direction tracking
            previousPosition = null;
            positionHistory = [];
            updateDirectionInfo('straight', 0);

            // Kembali ke lokasi default
            addUserLocationMarker(defaultLat, defaultLng, false);
            map.setView([defaultLat, defaultLng], 18);
        }

        function updateUserLocation(position) {
            const latitude = position.coords.latitude;
            const longitude = position.coords.longitude;
            const accuracy = position.coords.accuracy;

            updateGPSStatus(`Akurasi: ${Math.round(accuracy)}m`);

            const currentPosition = { lat: latitude, lng: longitude, timestamp: Date.now() };

            // Add to position history
            positionHistory.push(currentPosition);
            if (positionHistory.length > HISTORY_SIZE) {
                positionHistory.shift();
            }

            let direction = 'straight';

            if (previousPosition) {
                const distance = calculateDistance(
                    previousPosition.lat, previousPosition.lng,
                    latitude, longitude
                );

                // Only calculate bearing if we've moved significantly
                if (distance > MIN_DISTANCE) {
                    currentBearing = calculateBearing(
                        previousPosition.lat, previousPosition.lng,
                        latitude, longitude
                    );

                    // Detect turn direction
                    if (previousBearing !== 0) {
                        direction = detectTurnDirection(currentBearing, previousBearing);
                    }

                    previousBearing = currentBearing;
                    previousPosition = currentPosition;
                }
            } else {
                previousPosition = currentPosition;
            }

            // Update direction info
            updateDirectionInfo(direction, currentBearing);

            // Update user location marker with appropriate car image
            addUserLocationMarker(latitude, longitude, true, direction);

            // Move map to user location with street-level zoom
            map.setView([latitude, longitude], 19);
        }

        function handleGPSError(error) {
            let message = '';
            switch (error.code) {
                case error.PERMISSION_DENIED:
                    message = 'Izin lokasi ditolak';
                    break;
                case error.POSITION_UNAVAILABLE:
                    message = 'Lokasi tidak tersedia';
                    break;
                case error.TIMEOUT:
                    message = 'Timeout mencari lokasi';
                    break;
                default:
                    message = 'Error GPS tidak diketahui';
                    break;
            }

            updateGPSStatus(message);
            isGPSActive = false;
            document.getElementById('gpsButton').style.background = '#4CAF50';
            document.getElementById('gpsButton').textContent = '📍';
        }

        // Auto-start GPS function (tanpa alert)
        function autoStartGPS() {
            // Hanya coba auto-start jika belum pernah dicoba dan GPS support
            if (!hasAttemptedGPSStart && checkGPSSupport()) {
                hasAttemptedGPSStart = true;

                // Coba start GPS secara silent
                updateGPSStatus('Mencoba mengaktifkan GPS...');

                const options = {
                    enableHighAccuracy: true,
                    timeout: 5000, // Timeout lebih pendek untuk auto-start
                    maximumAge: 300000 // 5 menit cache
                };

                navigator.geolocation.getCurrentPosition(
                    (position) => {
                        // Berhasil mendapat lokasi, langsung start GPS
                        updateGPSStatus('GPS aktif');
                        isGPSActive = true;
                        document.getElementById('gpsButton').style.background = '#f44336';
                        document.getElementById('gpsButton').textContent = '⏹️';

                        // Reset direction tracking
                        previousPosition = null;
                        positionHistory = [];
                        currentBearing = 0;
                        previousBearing = 0;

                        gpsWatchId = navigator.geolocation.watchPosition(
                            updateUserLocation,
                            handleGPSError,
                            options
                        );
                    },
                    (error) => {
                        // Jika gagal, tampilkan pesan sesuai error tapi tidak menganggu
                        let message = '';
                        switch (error.code) {
                            case error.PERMISSION_DENIED:
                                message = 'Izin lokasi belum diberikan';
                                break;
                            case error.POSITION_UNAVAILABLE:
                                message = 'Lokasi tidak tersedia';
                                break;
                            case error.TIMEOUT:
                                message = 'GPS siap digunakan';
                                break;
                            default:
                                message = 'GPS siap digunakan';
                                break;
                        }
                        updateGPSStatus(message);
                    },
                    options
                );
            }
        }

        // Check if in peek mode
        function checkPeekMode() {
            if (window.frameElement && window.frameElement.classList.contains('peek-mode')) {
                document.body.classList.add('peek-mode');
            }
        }

        // Initialize everything when page loads
        document.addEventListener('DOMContentLoaded', function() {
            checkPeekMode();
            initMap();

            // Add event listener for GPS button
            document.getElementById('gpsButton').addEventListener('click', toggleGPS);

            // Auto-start GPS setelah map siap (tanpa alert)
            setTimeout(() => {
                autoStartGPS();
            }, 1000);
        });

        // Handle resize for iframe
        window.addEventListener('resize', function() {
            if (map) {
                setTimeout(() => {
                    map.invalidateSize();
                }, 100);
            }
        });

        // Handle message from parent for modal open
        window.addEventListener('message', function(event) {
            if (event.data === 'modal-opened') {
                setTimeout(() => {
                    if (map) {
                        map.invalidateSize();
                    }
                }, 300);
            }
        });

        // Handle page visibility change untuk mencegah multiple GPS requests
        document.addEventListener('visibilitychange', function() {
            if (document.hidden) {
                // Halaman tersembunyi, tidak perlu melakukan apa-apa
            } else {
                // Halaman terlihat kembali, cek apakah perlu restart GPS
                if (!isGPSActive && hasAttemptedGPSStart) {
                    // Jangan auto-restart, biarkan user klik tombol GPS manual
                }
            }
        });
    </script>
</body>
</html>
