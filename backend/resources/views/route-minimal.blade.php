<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Route Map - Enhanced</title>
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

        #speedInfo {
            position: absolute;
            top: 130px;
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

        .peek-mode #speedInfo {
            top: 65px;
            right: 5px;
            font-size: 10px;
            padding: 4px 8px;
        }

        /* Smooth car animation */
        .smooth-car-icon {
            transition: transform 0.5s cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        /* Car trail/path */
        .car-trail {
            stroke: #2196F3;
            stroke-width: 3;
            fill: none;
            stroke-dasharray: 5,5;
            opacity: 0.7;
        }
    </style>
</head>
<body>
    <div id="mapContainer">
        <div id="map"></div>
        <div id="gpsStatus">GPS: Tidak aktif</div>
        <div id="directionInfo">Arah: Lurus</div>
        <div id="speedInfo">Kecepatan: 0 km/h</div>
        <button id="gpsButton">📍</button>
    </div>

    <script>
        let map;
        let userLocationMarker = null;
        let gpsWatchId = null;
        let isGPSActive = false;
        let hasAttemptedGPSStart = false;

        // Enhanced variables for direction detection
        let previousPosition = null;
        let positionHistory = [];
        let currentBearing = 0;
        let previousBearing = 0;
        let smoothedBearing = 0;
        let currentSpeed = 0;
        let lastUpdateTime = Date.now();

        // Configuration constants
        const HISTORY_SIZE = 8; // Increased for better smoothing
        const MIN_DISTANCE = 3; // Increased for more stable detection
        const TURN_THRESHOLD = 15; // Increased for more stable turn detection
        const BEARING_SMOOTHING = 0.2; // Reduced for more stable bearing
        const MIN_SPEED_FOR_DIRECTION = 1.0; // Minimum speed to update direction (km/h)
        const SIGNIFICANT_TURN_THRESHOLD = 30; // Threshold for significant turn
        const COMPASS_OFFSET = 0; // No offset - 0° is North (up)

        // Default position (Jakarta)
        const defaultLat = -6.200000;
        const defaultLng = 106.816666;

        // Car images for different directions
        const carImages = {
            straight: '/model/camry/camry-top.png',
            left: '/model/camry/camry-turn-left.png',
            right: '/model/camry/camry-turn-right.png'
        };

        // Path tracking
        let pathPoints = [];
        let pathPolyline = null;

        // Initialize map
        function initMap() {
            map = L.map('map').setView([defaultLat, defaultLng], 18);

            L.tileLayer('https://a.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap contributors',
                maxZoom: 19
            }).addTo(map);

            addUserLocationMarker(defaultLat, defaultLng, false);

            setTimeout(() => {
                map.invalidateSize();
            }, 100);
        }

        // Calculate bearing between two points with improved accuracy
        function calculateBearing(lat1, lng1, lat2, lng2) {
            const dLng = (lng2 - lng1) * Math.PI / 180;
            const lat1Rad = lat1 * Math.PI / 180;
            const lat2Rad = lat2 * Math.PI / 180;

            const y = Math.sin(dLng) * Math.cos(lat2Rad);
            const x = Math.cos(lat1Rad) * Math.sin(lat2Rad) - Math.sin(lat1Rad) * Math.cos(lat2Rad) * Math.cos(dLng);

            let bearing = Math.atan2(y, x) * 180 / Math.PI;
            return (bearing + 360) % 360;
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

        // Calculate speed
        function calculateSpeed(distance, timeDiff) {
            // Speed in km/h
            return (distance / timeDiff) * 3.6;
        }

        // Smooth bearing using exponential smoothing
        function smoothBearing(newBearing, oldBearing, factor) {
            let diff = newBearing - oldBearing;

            // Handle bearing wrap-around
            if (diff > 180) diff -= 360;
            if (diff < -180) diff += 360;

            return (oldBearing + diff * factor + 360) % 360;
        }

        // Enhanced turn direction detection with stability
        function detectTurnDirection(currentBearing, previousBearing, speed) {
            // Only detect turns if moving fast enough
            if (speed < MIN_SPEED_FOR_DIRECTION) {
                return 'straight';
            }

            let bearingDiff = currentBearing - previousBearing;

            // Handle bearing wrap-around
            if (bearingDiff > 180) bearingDiff -= 360;
            if (bearingDiff < -180) bearingDiff += 360;

            const absDiff = Math.abs(bearingDiff);

            // Add hysteresis to prevent flickering
            const currentDirection = getCurrentDirection();
            if (currentDirection !== 'straight') {
                // If already turning, use lower threshold to continue
                if (absDiff < TURN_THRESHOLD * 0.7) {
                    return 'straight';
                }
            } else {
                // If going straight, use higher threshold to start turning
                if (absDiff < TURN_THRESHOLD * 1.3) {
                    return 'straight';
                }
            }

            if (absDiff > SIGNIFICANT_TURN_THRESHOLD) {
                // Significant turn
                return bearingDiff > 0 ? 'right' : 'left';
            } else {
                // Minor turn
                return bearingDiff > 0 ? 'right' : 'left';
            }
        }

        // Get current direction from UI
        function getCurrentDirection() {
            const directionText = document.getElementById('directionInfo').textContent;
            if (directionText.includes('Kiri')) return 'left';
            if (directionText.includes('Kanan')) return 'right';
            return 'straight';
        }

        // Get average bearing from position history with better filtering
        function getAverageBearing() {
            if (positionHistory.length < 3) return currentBearing;

            let validBearings = [];
            let totalDistance = 0;

            for (let i = 2; i < positionHistory.length; i++) {
                const prev = positionHistory[i-2];
                const curr = positionHistory[i];

                const distance = calculateDistance(prev.lat, prev.lng, curr.lat, curr.lng);
                if (distance > MIN_DISTANCE) {
                    const bearing = calculateBearing(prev.lat, prev.lng, curr.lat, curr.lng);
                    validBearings.push({ bearing, distance });
                    totalDistance += distance;
                }
            }

            if (validBearings.length === 0) return currentBearing;

            // Weighted average based on distance
            let totalX = 0, totalY = 0;
            validBearings.forEach(item => {
                const weight = item.distance / totalDistance;
                const radians = item.bearing * Math.PI / 180;
                totalX += Math.cos(radians) * weight;
                totalY += Math.sin(radians) * weight;
            });

            const avgRadians = Math.atan2(totalY, totalX);
            return (avgRadians * 180 / Math.PI + 360) % 360;
        }

        // Update direction info display
        function updateDirectionInfo(direction, bearing, speed) {
            const directionText = {
                'straight': 'Lurus',
                'left': 'Belok Kiri',
                'right': 'Belok Kanan'
            };

            document.getElementById('directionInfo').innerHTML =
                `Arah: ${directionText[direction]}<br>Bearing: ${Math.round(bearing)}°`;

            document.getElementById('speedInfo').innerHTML =
                `Kecepatan: ${speed.toFixed(1)} km/h`;
        }

        // Update path tracking
        function updatePath(lat, lng) {
            pathPoints.push([lat, lng]);

            // Keep only last 50 points to avoid memory issues
            if (pathPoints.length > 50) {
                pathPoints.shift();
            }

            if (pathPolyline) {
                map.removeLayer(pathPolyline);
            }

            if (pathPoints.length > 1) {
                pathPolyline = L.polyline(pathPoints, {
                    color: '#2196F3',
                    weight: 3,
                    opacity: 0.7,
                    dashArray: '5, 5'
                }).addTo(map);
            }
        }

        function addUserLocationMarker(lat, lng, isRealLocation = true, direction = 'straight', bearing = 0) {
            const carIconUrl = carImages[direction] || carImages.straight;

            function createOptimizedCarIcon() {
                let iconHtml;
                let iconSize, iconAnchor;

                if (direction === 'left') {
                    // Left turn image
                    iconSize = [70, 40];
                    iconAnchor = [35, 20];
                    iconHtml = `
                        <div class="smooth-car-icon" style="
                            width: ${iconSize[0]}px;
                            height: ${iconSize[1]}px;
                            background-image: url('${carIconUrl}');
                            background-size: contain;
                            background-repeat: no-repeat;
                            background-position: center;
                            transform: translate(-50%, -50%);
                            filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));
                        "></div>
                    `;
                } else if (direction === 'right') {
                    // Right turn image
                    iconSize = [70, 40];
                    iconAnchor = [35, 20];
                    iconHtml = `
                        <div class="smooth-car-icon" style="
                            width: ${iconSize[0]}px;
                            height: ${iconSize[1]}px;
                            background-image: url('${carIconUrl}');
                            background-size: contain;
                            background-repeat: no-repeat;
                            background-position: center;
                            transform: translate(-50%, -50%);
                            filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));
                        "></div>
                    `;
                } else {
                    // Straight image with proper rotation
                    iconSize = [40, 70];
                    iconAnchor = [20, 35];
                    // Bearing 0° = North (up), so we don't need offset
                    // The car image should have front pointing up (North)
                    const rotation = bearing;
                    iconHtml = `
                        <div class="smooth-car-icon" style="
                            width: ${iconSize[0]}px;
                            height: ${iconSize[1]}px;
                            background-image: url('${carIconUrl}');
                            background-size: contain;
                            background-repeat: no-repeat;
                            background-position: center;
                            transform: translate(-50%, -50%) rotate(${rotation}deg);
                            filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));
                        "></div>
                    `;
                }

                return L.divIcon({
                    html: iconHtml,
                    iconSize: iconSize,
                    iconAnchor: iconAnchor,
                    popupAnchor: [0, -iconAnchor[1]],
                    className: 'custom-car-icon'
                });
            }

            function createFallbackIcon() {
                // Bearing 0° = North (up), no offset needed
                const rotation = bearing;
                const carIconHtml = `
                    <div class="smooth-car-icon" style="
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
                        transform: translate(-50%, -50%) rotate(${rotation}deg);
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

            let carIcon;
            try {
                carIcon = createOptimizedCarIcon();
            } catch (error) {
                carIcon = createFallbackIcon();
            }

            // Update or create user location marker
            if (userLocationMarker) {
                userLocationMarker.setLatLng([lat, lng]);
                userLocationMarker.setIcon(carIcon);
            } else {
                userLocationMarker = L.marker([lat, lng], { icon: carIcon }).addTo(map);
            }

            const popupText = isRealLocation ? 'Anda disini' : 'Lokasi Default';
            userLocationMarker.bindPopup(popupText);

            if (isRealLocation) {
                userLocationMarker.openPopup();
            }

            // Update path if real location
            if (isRealLocation) {
                updatePath(lat, lng);
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

                    // Reset tracking variables
                    resetTracking();

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

            // Reset tracking and clear path
            resetTracking();
            if (pathPolyline) {
                map.removeLayer(pathPolyline);
                pathPolyline = null;
            }
            pathPoints = [];

            addUserLocationMarker(defaultLat, defaultLng, false);
            map.setView([defaultLat, defaultLng], 18);
        }

        function resetTracking() {
            previousPosition = null;
            positionHistory = [];
            currentBearing = 0;
            previousBearing = 0;
            smoothedBearing = 0;
            currentSpeed = 0;
            lastUpdateTime = Date.now();
            updateDirectionInfo('straight', 0, 0);
        }

        function updateUserLocation(position) {
            const latitude = position.coords.latitude;
            const longitude = position.coords.longitude;
            const accuracy = position.coords.accuracy;
            const timestamp = Date.now();

            // Filter out low accuracy readings
            if (accuracy > 50) {
                updateGPSStatus(`Akurasi rendah: ${Math.round(accuracy)}m`);
                return;
            }

            updateGPSStatus(`Akurasi: ${Math.round(accuracy)}m`);

            const currentPosition = {
                lat: latitude,
                lng: longitude,
                timestamp: timestamp,
                accuracy: accuracy
            };

            // Add to position history
            positionHistory.push(currentPosition);
            if (positionHistory.length > HISTORY_SIZE) {
                positionHistory.shift();
            }

            let direction = 'straight';
            let newBearing = currentBearing;
            let speed = 0;

            if (previousPosition && positionHistory.length >= 3) {
                const distance = calculateDistance(
                    previousPosition.lat, previousPosition.lng,
                    latitude, longitude
                );

                const timeDiff = (timestamp - previousPosition.timestamp) / 1000; // seconds
                speed = calculateSpeed(distance, timeDiff);

                if (distance > MIN_DISTANCE && timeDiff > 0.5) {
                    // Use averaged bearing for better accuracy
                    newBearing = getAverageBearing();

                    // Smooth the bearing only if there's a significant change
                    if (currentBearing !== 0) {
                        const bearingDiff = Math.abs(newBearing - currentBearing);
                        if (bearingDiff > 5 && bearingDiff < 355) { // Avoid wrapping issues
                            smoothedBearing = smoothBearing(newBearing, currentBearing, BEARING_SMOOTHING);
                        } else {
                            smoothedBearing = newBearing;
                        }
                    } else {
                        smoothedBearing = newBearing;
                    }

                    if (previousBearing !== 0) {
                        direction = detectTurnDirection(smoothedBearing, previousBearing, speed);
                    }

                    currentBearing = smoothedBearing;
                    previousBearing = smoothedBearing;
                    previousPosition = currentPosition;
                }
            } else if (positionHistory.length >= 2) {
                previousPosition = currentPosition;
            }

            currentSpeed = speed;

            // Update direction info
            updateDirectionInfo(direction, currentBearing, speed);

            // Update user location marker
            addUserLocationMarker(latitude, longitude, true, direction, currentBearing);

            // Smooth map movement
            map.panTo([latitude, longitude]);
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

        function autoStartGPS() {
            if (!hasAttemptedGPSStart && checkGPSSupport()) {
                hasAttemptedGPSStart = true;

                updateGPSStatus('Mencoba mengaktifkan GPS...');

                const options = {
                    enableHighAccuracy: true,
                    timeout: 5000,
                    maximumAge: 300000
                };

                navigator.geolocation.getCurrentPosition(
                    (position) => {
                        updateGPSStatus('GPS aktif');
                        isGPSActive = true;
                        document.getElementById('gpsButton').style.background = '#f44336';
                        document.getElementById('gpsButton').textContent = '⏹️';

                        resetTracking();

                        gpsWatchId = navigator.geolocation.watchPosition(
                            updateUserLocation,
                            handleGPSError,
                            options
                        );
                    },
                    (error) => {
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

        function checkPeekMode() {
            if (window.frameElement && window.frameElement.classList.contains('peek-mode')) {
                document.body.classList.add('peek-mode');
            }
        }

        // Initialize everything when page loads
        document.addEventListener('DOMContentLoaded', function() {
            checkPeekMode();
            initMap();

            document.getElementById('gpsButton').addEventListener('click', toggleGPS);

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

        // Handle page visibility change
        document.addEventListener('visibilitychange', function() {
            if (document.hidden) {
                // Halaman tersembunyi
            } else {
                // Halaman terlihat kembali
                if (!isGPSActive && hasAttemptedGPSStart) {
                    // Biarkan user klik tombol GPS manual
                }
            }
        });
    </script>
</body>
</html>
