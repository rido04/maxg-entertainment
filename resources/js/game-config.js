const config = {
    type: Phaser.AUTO,
    parent: "game-container",
    width: 800,
    height: 600,
    scene: [MyGameScene],
    scale: {
        mode: Phaser.Scale.FIT,
        autoCenter: Phaser.Scale.CENTER_BOTH,
    },
    input: {
        activePointers: 3, // Bisa pakai lebih dari 1 jari
    },
};

const game = new Phaser.Game(config);
