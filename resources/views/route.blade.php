@extends('layouts.app', ['title' => 'Peta'])

@section('content')
    <style>
        #map {
            height: 100vh;
            width: 100%;
        }

        .map-controls {
            position: absolute;
            top: 10px;
            right: 10px;
            z-index: 1000;
        }

        .control-btn {
            background: white;
            border: none;
            padding: 8px 12px;
            margin: 2px;
            border-radius: 5px;
            cursor: pointer;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
            font-size: 12px;
        }

        .control-btn:hover {
            background: #f0f0f0;
        }

        .status-info {
            position: absolute;
            bottom: 10px;
            left: 10px;
            z-index: 1000;
            background: rgba(0,0,0,0.8);
            color: white;
            padding: 12px;
            border-radius: 8px;
            font-size: 12px;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            backdrop-filter: blur(10px);
            max-width: 300px;
        }

        .speed-display {
            position: absolute;
            top: 10px;
            left: 10px;
            z-index: 1000;
            background: rgba(0,0,0,0.8);
            color: white;
            padding: 10px 15px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: bold;
            backdrop-filter: blur(10px);
        }

        .zoom-controls {
            position: absolute;
            bottom: 120px;
            right: 10px;
            z-index: 1000;
        }

        .zoom-btn {
            background: white;
            border: none;
            width: 40px;
            height: 40px;
            margin: 2px;
            border-radius: 50%;
            cursor: pointer;
            box-shadow: 0 2px 8px rgba(0,0,0,0.3);
            font-size: 16px;
            font-weight: bold;
            display: block;
        }

        .zoom-btn:hover {
            background: #f0f0f0;
        }

        .recenter-btn {
            position: absolute;
            bottom: 60px;
            right: 10px;
            z-index: 1000;
            background: #00C853;
            color: white;
            border: none;
            width: 50px;
            height: 50px;
            border-radius: 50%;
            cursor: pointer;
            box-shadow: 0 2px 8px rgba(0,0,0,0.3);
            font-size: 20px;
        }

        .recenter-btn:hover {
            background: #00A047;
        }
    </style>

    <div style="position: relative;">
        <div id="map"></div>

        <div class="speed-display" id="speedDisplay">
            0 km/h
        </div>

        <div class="map-controls">
            <button id="getCurrentLocationBtn" class="control-btn">Lokasi Saya</button>
            <button id="startTrackingBtn" class="control-btn">Mulai Tracking</button>
            <button id="stopTrackingBtn" class="control-btn">Stop Tracking</button>
        </div>

        <div class="zoom-controls">
            <button id="zoomInBtn" class="zoom-btn">+</button>
            <button id="zoomOutBtn" class="zoom-btn">-</button>
        </div>

        <button id="recenterBtn" class="recenter-btn">🎯</button>

        <div id="statusInfo" class="status-info">
            <div><strong>Status:</strong> Menunggu GPS...</div>
            <div id="coordsInfo" style="margin-top: 5px; font-size: 11px; color: #ccc;"></div>
        </div>
    </div>
@endsection

@push('scripts')
<script>
    document.addEventListener('DOMContentLoaded', function() {
        console.log('DOM loaded');

        setTimeout(function() {
            let map, currentMarker, watchId;
            let isTracking = false;
            let lastPosition = null;
            let lastTimestamp = null;
            let currentSpeed = 0;
            let autoFollow = true;

            // Inisialisasi map dengan zoom level tinggi (mirip Grab)
            map = L.map('map', {
                zoomControl: false, // Disable default zoom control
                attributionControl: false
            }).setView([-6.2, 106.81], 18); // Zoom level 18 untuk detail tinggi

            // Gunakan tile layer yang lebih detail
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap contributors',
                maxZoom: 19
            }).addTo(map);

            // Icon mobil yang lebih besar dan jelas
            const carIcon = L.icon({
                iconUrl: 'https://cdn-icons-png.flaticon.com/512/854/854894.png',
                iconSize: [50, 50],
                iconAnchor: [25, 25],
                popupAnchor: [0, -25]
            });

            // Fungsi update status
            function updateStatus(message) {
                document.getElementById('statusInfo').innerHTML = `
                    <div><strong>Status:</strong> ${message}</div>
                    <div id="coordsInfo" style="margin-top: 5px; font-size: 11px; color: #ccc;"></div>
                `;
                console.log('Status:', message);
            }

            // Fungsi hitung kecepatan
            function calculateSpeed(position) {
                if (lastPosition && lastTimestamp) {
                    const distance = getDistance(
                        lastPosition.coords.latitude,
                        lastPosition.coords.longitude,
                        position.coords.latitude,
                        position.coords.longitude
                    );

                    const timeDiff = (position.timestamp - lastTimestamp) / 1000; // dalam detik

                    if (timeDiff > 0) {
                        const speed = (distance / timeDiff) * 3.6; // konversi m/s ke km/h
                        currentSpeed = Math.round(speed);

                        // Update display kecepatan
                        document.getElementById('speedDisplay').textContent = `🚗 ${currentSpeed} km/h`;
                    }
                }

                lastPosition = position;
                lastTimestamp = position.timestamp;
            }

            // Fungsi hitung jarak (Haversine formula)
            function getDistance(lat1, lon1, lat2, lon2) {
                const R = 6371000; // radius bumi dalam meter
                const φ1 = lat1 * Math.PI/180;
                const φ2 = lat2 * Math.PI/180;
                const Δφ = (lat2-lat1) * Math.PI/180;
                const Δλ = (lon2-lon1) * Math.PI/180;

                const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
                         Math.cos(φ1) * Math.cos(φ2) *
                         Math.sin(Δλ/2) * Math.sin(Δλ/2);
                const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

                return R * c;
            }

            // Fungsi update lokasi
            function updateLocation(position) {
                const lat = position.coords.latitude;
                const lng = position.coords.longitude;
                const accuracy = position.coords.accuracy;
                const timestamp = new Date(position.timestamp).toLocaleTimeString();

                console.log('Lokasi GPS:', { lat, lng, accuracy, timestamp });

                // Hitung kecepatan
                calculateSpeed(position);

                // Update atau buat marker baru
                if (currentMarker) {
                    currentMarker.setLatLng([lat, lng]);
                } else {
                    currentMarker = L.marker([lat, lng], { icon: carIcon }).addTo(map);
                }

                // Update popup dengan info detail
                currentMarker.bindPopup(`
                    <div style="font-family: 'Segoe UI', sans-serif;">
                        <b>Lokasi Real-time</b><br>
                        <strong>Kecepatan:</strong> ${currentSpeed} km/h<br>
                        <strong>Koordinat:</strong> ${lat.toFixed(6)}, ${lng.toFixed(6)}<br>
                        <strong>Akurasi:</strong> ${accuracy.toFixed(0)}m<br>
                        <strong>Waktu:</strong> ${timestamp}
                    </div>
                `);

                // Auto-follow jika aktif (mirip Grab)
                if (autoFollow) {
                    map.setView([lat, lng], 18, {
                        animate: true,
                        duration: 1 // Smooth animation
                    });
                }

                // Update status info
                updateStatus(`GPS Aktif - ${currentSpeed} km/h`);
                document.getElementById('coordsInfo').innerHTML = `
                    <div>Lat: ${lat.toFixed(6)} | Lng: ${lng.toFixed(6)}</div>
                    <div>Akurasi: ${accuracy.toFixed(0)}m | ${timestamp}</div>
                `;

                // Tambahkan circle akurasi yang lebih kecil
                if (window.accuracyCircle) {
                    map.removeLayer(window.accuracyCircle);
                }

                window.accuracyCircle = L.circle([lat, lng], {
                    color: '#00C853',
                    fillColor: '#00C853',
                    fillOpacity: 0.1,
                    radius: Math.max(accuracy, 10), // Minimum 10m radius
                    weight: 2
                }).addTo(map);
            }

            // Fungsi handle error GPS
            function handleLocationError(error) {
                console.error('GPS Error:', error);

                let errorMessage = 'Error GPS: ';
                switch(error.code) {
                    case error.PERMISSION_DENIED:
                        errorMessage += 'Izin akses lokasi ditolak';
                        break;
                    case error.POSITION_UNAVAILABLE:
                        errorMessage += 'Lokasi tidak tersedia';
                        break;
                    case error.TIMEOUT:
                        errorMessage += 'Timeout mendapatkan lokasi';
                        break;
                    default:
                        errorMessage += 'Error tidak diketahui';
                        break;
                }

                updateStatus(errorMessage);
                alert(errorMessage);
            }

            // Cek dukungan geolocation
            if (!navigator.geolocation) {
                updateStatus('Browser tidak mendukung GPS');
                alert('Browser tidak mendukung geolocation');
            } else {
                updateStatus('GPS tersedia - Klik tombol untuk mengaktifkan');
            }

            // Button: Get Current Location
            document.getElementById('getCurrentLocationBtn').addEventListener('click', function() {
                updateStatus('Mencari lokasi GPS...');

                navigator.geolocation.getCurrentPosition(
                    updateLocation,
                    handleLocationError,
                    {
                        enableHighAccuracy: true,
                        timeout: 10000,
                        maximumAge: 0
                    }
                );
            });

            // Button: Start Tracking
            document.getElementById('startTrackingBtn').addEventListener('click', function() {
                if (isTracking) {
                    alert('Tracking sudah aktif!');
                    return;
                }

                updateStatus('Memulai tracking GPS...');

                watchId = navigator.geolocation.watchPosition(
                    updateLocation,
                    handleLocationError,
                    {
                        enableHighAccuracy: true,
                        timeout: 15000,
                        maximumAge: 2000 // Cache 2 detik untuk update lebih sering
                    }
                );

                isTracking = true;
                document.getElementById('startTrackingBtn').textContent = '🟢 Tracking Aktif';
                console.log('Tracking dimulai, watchId:', watchId);
            });

            // Button: Stop Tracking
            document.getElementById('stopTrackingBtn').addEventListener('click', function() {
                if (!isTracking) {
                    alert('Tracking belum dimulai!');
                    return;
                }

                if (watchId) {
                    navigator.geolocation.clearWatch(watchId);
                    watchId = null;
                }

                isTracking = false;
                document.getElementById('startTrackingBtn').textContent = '🔴 Mulai Tracking';
                updateStatus('Tracking dihentikan');
                document.getElementById('speedDisplay').textContent = '🚗 0 km/h';

                // Remove accuracy circle
                if (window.accuracyCircle) {
                    map.removeLayer(window.accuracyCircle);
                }

                console.log('Tracking dihentikan');
            });

            // Zoom controls
            document.getElementById('zoomInBtn').addEventListener('click', function() {
                map.zoomIn();
            });

            document.getElementById('zoomOutBtn').addEventListener('click', function() {
                map.zoomOut();
            });

            // Recenter button
            document.getElementById('recenterBtn').addEventListener('click', function() {
                if (currentMarker) {
                    const pos = currentMarker.getLatLng();
                    map.setView(pos, 18, { animate: true });
                    autoFollow = true;
                    this.style.background = '#00C853';
                } else {
                    alert('Belum ada lokasi yang terdeteksi');
                }
            });

            // Disable auto-follow when user manually moves map
            map.on('dragstart', function() {
                autoFollow = false;
                document.getElementById('recenterBtn').style.background = '#FF5722';
            });

            // Cleanup saat page unload
            window.addEventListener('beforeunload', function() {
                if (watchId) {
                    navigator.geolocation.clearWatch(watchId);
                }
            });

            // Auto-start tracking (opsional)
            // Uncomment baris di bawah jika ingin auto-start
            document.getElementById('startTrackingBtn').click();

        }, 500);
    });
</script>
@endpush
