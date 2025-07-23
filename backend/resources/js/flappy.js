// resources/js/games/flappy.js
import Phaser from "phaser";

class FlappyBirdScene extends Phaser.Scene {
    constructor() {
        super("FlappyBird");
    }

    create() {
        this.add.image(200, 300, "bird");
    }

    create() {
        // Add background
        this.add.image(400, 300, "background");

        // Add bird sprite
        this.bird = this.physics.add.sprite(100, 300, "bird").setScale(1.2);
        this.bird.setCollideWorldBounds(true);

        // Add input for bird flap
        this.input.on("pointerdown", this.flap, this);

        // Add pipes group
        this.pipes = this.physics.add.group();
        this.time.addEvent({
            delay: 1500,
            callback: this.spawnPipes,
            callbackScope: this,
            loop: true,
        });

        // Add collision detection
        this.physics.add.collider(
            this.bird,
            this.pipes,
            this.gameOver,
            null,
            this
        );
    }

    update() {
        // Rotate bird slightly downward
        if (this.bird.angle < 20) this.bird.angle += 1;

        // Check if bird is out of bounds
        if (this.bird.y > 600 || this.bird.y < 0) {
            this.gameOver();
        }
    }

    flap() {
        // Make bird flap upward
        this.bird.setVelocityY(-250);
        this.bird.angle = -15;
    }

    spawnPipes() {
        const gap = 150;
        const topHeight = Phaser.Math.Between(100, 400);
        const bottomY = topHeight + gap;

        // Create top pipe
        const topPipe = this.pipes
            .create(800, topHeight - 320, "pipe")
            .setOrigin(0, 0)
            .setFlipY(true);

        // Create bottom pipe
        const bottomPipe = this.pipes
            .create(800, bottomY, "pipe")
            .setOrigin(0, 0);

        // Set pipes velocity
        this.pipes.setVelocityX(-200);
    }

    gameOver() {
        // Restart scene on game over
        this.scene.restart();
    }
}

const config = {
    type: Phaser.AUTO,
    width: 800,
    height: 600,
    physics: {
        default: "arcade",
        arcade: {
            gravity: { y: 500 },
            debug: false,
        },
    },
    scene: FlappyBirdScene,
    scale: {
        mode: Phaser.Scale.FIT,
        autoCenter: Phaser.Scale.CENTER_BOTH,
    },
    parent: "game-container",
};

window.addEventListener("DOMContentLoaded", () => {
    new Phaser.Game(config);
});
