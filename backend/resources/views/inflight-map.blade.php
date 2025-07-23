<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>In-flight Navigation - Enhanced</title>
  <script src="https://cesium.com/downloads/cesiumjs/releases/1.100/Build/Cesium/Cesium.js"></script>
  <link href="https://cesium.com/downloads/cesiumjs/releases/1.100/Build/Cesium/Widgets/widgets.css" rel="stylesheet" />
  <style>
    html, body, #cesiumContainer {
      width: 100%;
      height: 100%;
      margin: 0;
      overflow: hidden;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }

    .flight-info {
      position: absolute;
      top: 10px;
      left: 10px;
      background: rgba(0, 0, 0, 0.8);
      color: white;
      padding: 15px;
      border-radius: 8px;
      font-size: 14px;
      z-index: 1000;
      box-shadow: 0 4px 8px rgba(0,0,0,0.3);
    }

    .flight-phase {
      color: #00ff00;
      font-weight: bold;
      margin-bottom: 5px;
    }

    .controls {
      position: absolute;
      bottom: 20px;
      left: 50%;
      transform: translateX(-50%);
      background: rgba(0, 0, 0, 0.8);
      padding: 10px 20px;
      border-radius: 25px;
      z-index: 1000;
    }

    .control-btn {
      background: #4CAF50;
      border: none;
      color: white;
      padding: 8px 16px;
      margin: 0 5px;
      border-radius: 4px;
      cursor: pointer;
      font-size: 12px;
    }

    .control-btn:hover {
      background: #45a049;
    }

    .control-btn.pause {
      background: #ff9800;
    }

    .control-btn.reset {
      background: #f44336;
    }
  </style>
</head>
<body>
<div id="cesiumContainer"></div>

<div class="flight-info" id="flightInfo">
  <div class="flight-phase" id="flightPhase">GROUND</div>
  <div>Altitude: <span id="altitude">0</span> ft</div>
  <div>Speed: <span id="speed">0</span> kts</div>
  <div>Distance: <span id="distance">0</span> km</div>
</div>

<div class="controls">
  <button class="control-btn" onclick="playFlight()">▶ Play</button>
  <button class="control-btn pause" onclick="pauseFlight()">⏸ Pause</button>
  <button class="control-btn reset" onclick="resetFlight()">⏹ Reset</button>
  <button class="control-btn" onclick="changeSpeed(0.5)">0.5x</button>
  <button class="control-btn" onclick="changeSpeed(1)">1x</button>
  <button class="control-btn" onclick="changeSpeed(2)">2x</button>
  <button class="control-btn" onclick="changeSpeed(5)">5x</button>
</div>

<script>
  Cesium.Ion.defaultAccessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI2NWNjNTBlNC1mZWJjLTRlOTgtYTYwNy0xYzllMjc0Y2U0MDAiLCJpZCI6MzE1NDE2LCJpYXQiOjE3NTA4MjQ0MTd9.S6b1RlD-mXEVRJGtStRCYCCU2Rnuha9mNFWnPDKtaMA';

  const viewer = new Cesium.Viewer('cesiumContainer', {
    terrain: Cesium.createWorldTerrain(),
    baseLayerPicker: false,
    shouldAnimate: true,
    animation: false,
    timeline: false
  });

  viewer.scene.globe.enableLighting = true;
  viewer.scene.skyAtmosphere.show = true;
  viewer.scene.fog.enabled = true;
  viewer.scene.fog.density = 0.0001;

  // Enhanced flight route with smooth takeoff and landing
  const flightRoute = [
    // Ground phase - Jakarta Soekarno-Hatta
    { lat: -6.1256, lng: 106.6559, alt: 0, phase: "GROUND" },

    // Taxi and takeoff preparation
    { lat: -6.1250, lng: 106.6565, alt: 0, phase: "TAXI" },
    { lat: -6.1240, lng: 106.6580, alt: 0, phase: "TAXI" },

    // Takeoff roll - gradual acceleration
    { lat: -6.1230, lng: 106.6600, alt: 0, phase: "TAKEOFF" },
    { lat: -6.1220, lng: 106.6620, alt: 50, phase: "TAKEOFF" },
    { lat: -6.1210, lng: 106.6640, alt: 150, phase: "TAKEOFF" },
    { lat: -6.1200, lng: 106.6660, alt: 300, phase: "TAKEOFF" },

    // Initial climb - smooth ascent
    { lat: -6.1180, lng: 106.6700, alt: 500, phase: "CLIMB" },
    { lat: -6.1150, lng: 106.6750, alt: 800, phase: "CLIMB" },
    { lat: -6.1100, lng: 106.6850, alt: 1200, phase: "CLIMB" },
    { lat: -6.1000, lng: 106.7000, alt: 1800, phase: "CLIMB" },
    { lat: -6.0800, lng: 106.7200, alt: 2500, phase: "CLIMB" },

    // Continued climb
    { lat: -6.0500, lng: 106.7500, alt: 3500, phase: "CLIMB" },
    { lat: -6.0000, lng: 106.8000, alt: 5000, phase: "CLIMB" },
    { lat: -5.9000, lng: 106.9000, alt: 8000, phase: "CLIMB" },
    { lat: -5.8000, lng: 107.0000, alt: 12000, phase: "CLIMB" },
    { lat: -5.7000, lng: 107.2000, alt: 18000, phase: "CLIMB" },
    { lat: -5.6000, lng: 107.5000, alt: 25000, phase: "CLIMB" },
    { lat: -5.5000, lng: 108.0000, alt: 32000, phase: "CLIMB" },

    // Cruise altitude
    { lat: -5.4000, lng: 108.5000, alt: 35000, phase: "CRUISE" },
    { lat: -5.3000, lng: 109.0000, alt: 35000, phase: "CRUISE" },
    { lat: -5.2000, lng: 109.5000, alt: 35000, phase: "CRUISE" },
    { lat: -5.1000, lng: 110.0000, alt: 35000, phase: "CRUISE" },
    { lat: -5.0000, lng: 110.5000, alt: 35000, phase: "CRUISE" },
    { lat: -4.9000, lng: 111.0000, alt: 35000, phase: "CRUISE" },
    { lat: -4.8000, lng: 111.5000, alt: 35000, phase: "CRUISE" },
    { lat: -4.7000, lng: 112.0000, alt: 35000, phase: "CRUISE" },
    { lat: -4.6000, lng: 112.5000, alt: 35000, phase: "CRUISE" },
    { lat: -4.5000, lng: 113.0000, alt: 35000, phase: "CRUISE" },
    { lat: -4.4000, lng: 113.5000, alt: 35000, phase: "CRUISE" },
    { lat: -4.3000, lng: 114.0000, alt: 35000, phase: "CRUISE" },
    { lat: -4.2000, lng: 114.5000, alt: 35000, phase: "CRUISE" },
    { lat: -4.1000, lng: 115.0000, alt: 35000, phase: "CRUISE" },
    { lat: -4.0000, lng: 115.5000, alt: 35000, phase: "CRUISE" },
    { lat: -3.9000, lng: 116.0000, alt: 35000, phase: "CRUISE" },
    { lat: -3.8000, lng: 116.5000, alt: 35000, phase: "CRUISE" },
    { lat: -3.7000, lng: 117.0000, alt: 35000, phase: "CRUISE" },
    { lat: -3.6000, lng: 117.5000, alt: 35000, phase: "CRUISE" },
    { lat: -3.5000, lng: 118.0000, alt: 35000, phase: "CRUISE" },
    { lat: -3.4000, lng: 118.5000, alt: 35000, phase: "CRUISE" },
    { lat: -3.3000, lng: 119.0000, alt: 35000, phase: "CRUISE" },

    { lat: -3.2000, lng: 119.3000, alt: 32000, phase: "DESCENT" },
    { lat: -3.1000, lng: 119.5000, alt: 28000, phase: "DESCENT" },
    { lat: -3.0000, lng: 119.7000, alt: 24000, phase: "DESCENT" },
    { lat: -2.9000, lng: 119.8500, alt: 20000, phase: "DESCENT" },
    { lat: -2.8000, lng: 119.9000, alt: 16000, phase: "DESCENT" },
    { lat: -2.7000, lng: 119.9200, alt: 12000, phase: "DESCENT" },
    { lat: -2.6000, lng: 119.9300, alt: 8000, phase: "DESCENT" },
    { lat: -2.5500, lng: 119.9350, alt: 6000, phase: "DESCENT" },
    { lat: -2.5000, lng: 119.9400, alt: 4000, phase: "DESCENT" },

    { lat: -2.4800, lng: 119.9420, alt: 3000, phase: "APPROACH" },
    { lat: -2.4600, lng: 119.9440, alt: 2200, phase: "APPROACH" },
    { lat: -2.4400, lng: 119.9460, alt: 1600, phase: "APPROACH" },
    { lat: -2.4200, lng: 119.9480, alt: 1200, phase: "APPROACH" },
    { lat: -2.4000, lng: 119.9500, alt: 800, phase: "APPROACH" },
    { lat: -2.3850, lng: 119.9510, alt: 500, phase: "APPROACH" },
    { lat: -2.3700, lng: 119.9520, alt: 300, phase: "APPROACH" },

    // Final approach and landing
    { lat: -2.3600, lng: 119.9525, alt: 200, phase: "LANDING" },
    { lat: -2.3550, lng: 119.9527, alt: 100, phase: "LANDING" },
    { lat: -2.3500, lng: 119.9530, alt: 50, phase: "LANDING" },
    { lat: -2.3480, lng: 119.9532, alt: 20, phase: "LANDING" },
    { lat: -2.3470, lng: 119.9533, alt: 5, phase: "LANDING" },
    { lat: -2.3465, lng: 119.9534, alt: 0, phase: "LANDING" },

    // Ground roll and taxi
    { lat: -2.3460, lng: 119.9535, alt: 0, phase: "GROUND" },
    { lat: -2.3455, lng: 119.9536, alt: 0, phase: "TAXI" }
  ];

  let airplaneEntity;
  let startTime;

  function createFlightPath() {
    const airplanePosition = new Cesium.SampledPositionProperty();
    startTime = Cesium.JulianDate.now();

    flightRoute.forEach((point, index) => {
      const time = Cesium.JulianDate.addSeconds(startTime, index * 8, new Cesium.JulianDate());
      const position = Cesium.Cartesian3.fromDegrees(point.lng, point.lat, point.alt * 3.28084);
      airplanePosition.addSample(time, position);
    });

    // Interpolation
    airplanePosition.setInterpolationOptions({
      interpolationDegree: 3,
      interpolationAlgorithm: Cesium.HermitePolynomialApproximation
    });

    return airplanePosition;
  }

  function initializeFlight() {
    const airplanePosition = createFlightPath();

    //  airplane model
    airplaneEntity = viewer.entities.add({
      name: "Garuda Indonesia GA-123",
      position: airplanePosition,
      orientation: new Cesium.VelocityOrientationProperty(airplanePosition),
      model: {
        uri: "{{ asset('model/airplane_crj-900_cityjet.glb') }}",
        minimumPixelSize: 128,
        maximumScale: 5000,
        scale: 2.0
      },
      path: {
        resolution: 1,
        material: new Cesium.PolylineGlowMaterialProperty({
          glowPower: 0.1,
          color: Cesium.Color.YELLOW.withAlpha(0.8)
        }),
        width: 5,
        leadTime: 0,
        trailTime: 300
      }
    });

    // Set up camera tracking
    viewer.trackedEntity = airplaneEntity;

    // Configure clock
    viewer.clock.startTime = startTime.clone();
    viewer.clock.stopTime = Cesium.JulianDate.addSeconds(startTime, flightRoute.length * 8, new Cesium.JulianDate());
    viewer.clock.currentTime = startTime.clone();
    viewer.clock.clockRange = Cesium.ClockRange.CLAMPED;
    viewer.clock.multiplier = 1;

    // Start animation
    viewer.clock.shouldAnimate = true;

    // Update flight info
    updateFlightInfo();
  }

  function updateFlightInfo() {
    viewer.clock.onTick.addEventListener(function(clock) {
      if (!airplaneEntity) return;

      const currentTime = clock.currentTime;
      const position = airplaneEntity.position.getValue(currentTime);

      if (position) {
        const cartographic = Cesium.Cartographic.fromCartesian(position);
        const altitude = Math.round(cartographic.height * 3.28084); // Convert to feet

        // Calculate elapsed time to determine flight phase
        const elapsedSeconds = Cesium.JulianDate.secondsDifference(currentTime, startTime);
        const routeIndex = Math.min(Math.floor(elapsedSeconds / 8), flightRoute.length - 1);
        const currentPhase = flightRoute[routeIndex]?.phase || "CRUISE";

        // Calculate approximate speed based on phase
        let speed = 0;
        switch(currentPhase) {
          case "TAXI": speed = 15; break;
          case "TAKEOFF": speed = 180; break;
          case "CLIMB": speed = 280; break;
          case "CRUISE": speed = 480; break;
          case "DESCENT": speed = 320; break;
          case "APPROACH": speed = 200; break;
          case "LANDING": speed = 160; break;
          case "GROUND": speed = 0; break;
        }

        const distance = Math.round(elapsedSeconds * 0.133);

        document.getElementById('flightPhase').textContent = currentPhase;
        document.getElementById('altitude').textContent = altitude.toLocaleString();
        document.getElementById('speed').textContent = speed;
        document.getElementById('distance').textContent = distance;

        // Change phase color
        const phaseElement = document.getElementById('flightPhase');
        switch(currentPhase) {
          case "GROUND":
          case "TAXI":
            phaseElement.style.color = "#ffff00"; break;
          case "TAKEOFF":
          case "CLIMB":
            phaseElement.style.color = "#00ff00"; break;
          case "CRUISE":
            phaseElement.style.color = "#00ffff"; break;
          case "DESCENT":
          case "APPROACH":
            phaseElement.style.color = "#ff8800"; break;
          case "LANDING":
            phaseElement.style.color = "#ff0000"; break;
        }
      }
    });
  }

  // Control functions
  function playFlight() {
    viewer.clock.shouldAnimate = true;
  }

  function pauseFlight() {
    viewer.clock.shouldAnimate = false;
  }

  function resetFlight() {
    viewer.clock.currentTime = startTime.clone();
    viewer.clock.shouldAnimate = false;
  }

  function changeSpeed(multiplier) {
    viewer.clock.multiplier = multiplier;
  }

  // Initialize on load
  initializeFlight();

  // Add departure and arrival airports
  viewer.entities.add({
    name: "Jakarta (CGK)",
    position: Cesium.Cartesian3.fromDegrees(106.6559, -6.1256, 0),
    billboard: {
      image: 'data:image/svg+xml;base64,' + btoa('<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><circle cx="12" cy="12" r="8" fill="green"/><text x="12" y="16" text-anchor="middle" fill="white" font-size="10">CGK</text></svg>'),
      scale: 1.5
    }
  });

  viewer.entities.add({
    name: "Makassar (UPG)",
    position: Cesium.Cartesian3.fromDegrees(119.9534, -2.3465, 0),
    billboard: {
      image: 'data:image/svg+xml;base64,' + btoa('<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><circle cx="12" cy="12" r="8" fill="red"/><text x="12" y="16" text-anchor="middle" fill="white" font-size="10">UPG</text></svg>'),
      scale: 1.5
    }
  });
</script>
</body>
</html>
