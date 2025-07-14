<!DOCTYPE html>
<html>
<head>
    <title>3D Nav</title>
    <script src="https://cesium.com/downloads/cesiumjs/releases/1.115/Build/Cesium/Cesium.js"></script>
    <link href="https://cesium.com/downloads/cesiumjs/releases/1.115/Build/Cesium/Widgets/widgets.css" rel="stylesheet">
    <style>
        #cesiumContainer { width: 100vw; height: 100vh; }
    </style>
</head>
<body>
<div id="cesiumContainer"></div>

<script>
Cesium.Ion.defaultAccessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI2NWNjNTBlNC1mZWJjLTRlOTgtYTYwNy0xYzllMjc0Y2U0MDAiLCJpZCI6MzE1NDE2LCJpYXQiOjE3NTA4MjQ0MTd9.S6b1RlD-mXEVRJGtStRCYCCU2Rnuha9mNFWnPDKtaMA';

(async () => {
    const viewer = new Cesium.Viewer('cesiumContainer', {
        terrainProvider: await Cesium.createWorldTerrainAsync(),
        shouldAnimate: true,
        imageryProvider: new Cesium.UrlTemplateImageryProvider({
        url : 'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png',
        credit : '© OpenStreetMap contributors'
    }),
    });

    // Zoom kamera ke Jakarta
    viewer.camera.flyTo({
        destination: Cesium.Cartesian3.fromDegrees(106.816666, -6.200000, 3000),
        duration: 2
    });

    // Tambahkan model
    viewer.entities.add({
        name: "Mobil",
        position: Cesium.Cartesian3.fromDegrees(106.816666, -6.200000, 30),
        model: {
            uri: '/model/Grab_Briocar.glb',
            scale: 0.5,
            minimumPixelSize: 64
        }
    });
})();
</script>
</body>
</html>
