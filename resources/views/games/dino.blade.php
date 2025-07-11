@extends('layouts.app')

@push('styles')
<style>
    .game-wrapper {
        position: relative;
        max-width: 1200px;
        margin: 0 auto;
        padding: 20px;
    }

    .game-iframe {
        width: 100%;
        height: 500px;
        border: 3px solid #e2e8f0;
        border-radius: 15px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        transition: all 0.3s ease;
    }

    .game-iframe:hover {
        box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
        transform: translateY(-2px);
    }

    .back-btn {
        display: inline-flex;
        align-items: center;
        gap: 10px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border: none;
        padding: 12px 24px;
        border-radius: 50px;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        margin-top: 20px;
        transition: all 0.3s ease;
        box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        position: relative;
        overflow: hidden;
    }

    .back-btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
        transition: left 0.5s;
    }

    .back-btn:hover::before {
        left: 100%;
    }

    .back-btn:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
        background: linear-gradient(135deg, #5a67d8 0%, #6b46c1 100%);
    }

    .back-btn:active {
        transform: translateY(-1px);
        box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
    }

    .back-btn .emoji {
        font-size: 18px;
        transition: transform 0.3s ease;
    }

    .back-btn:hover .emoji {
        transform: translateX(-2px);
    }

    /* Alternative button styles - uncomment yang kamu suka */

    /* Style 2: Glassmorphism */
    /*
    .back-btn {
        background: rgba(255, 255, 255, 0.2);
        backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.3);
        color: #333;
        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
    }

    .back-btn:hover {
        background: rgba(255, 255, 255, 0.3);
        transform: translateY(-3px);
    }
    */

    /* Style 3: Neon */
    /*
    .back-btn {
        background: #000;
        color: #00ff88;
        border: 2px solid #00ff88;
        box-shadow: 0 0 20px rgba(0, 255, 136, 0.3);
        text-shadow: 0 0 10px #00ff88;
    }

    .back-btn:hover {
        background: #00ff88;
        color: #000;
        box-shadow: 0 0 30px rgba(0, 255, 136, 0.6);
        text-shadow: none;
    }
    */

    /* Style 4: Material Design */
    /*
    .back-btn {
        background: #2196F3;
        box-shadow: 0 2px 10px rgba(33, 150, 243, 0.3);
        border-radius: 8px;
    }

    .back-btn:hover {
        background: #1976D2;
        box-shadow: 0 6px 20px rgba(33, 150, 243, 0.4);
    }
    */

    /* Responsive */
    @media (max-width: 768px) {
        .game-wrapper {
            padding: 10px;
        }

        .game-iframe {
            height: 400px;
        }

        .back-btn {
            width: 100%;
            justify-content: center;
            margin-top: 15px;
        }
    }

    /* Loading animation untuk iframe */
    .game-iframe {
        background: linear-gradient(45deg, #f0f2f5, #e4e7ea);
        background-size: 400% 400%;
        animation: loadingShimmer 1.5s ease-in-out infinite;
    }

    @keyframes loadingShimmer {
        0% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
        100% { background-position: 0% 50%; }
    }

    /* Floating animation */
    .back-btn {
        animation: float 3s ease-in-out infinite;
    }

    @keyframes float {
        0%, 100% { transform: translateY(0px); }
        50% { transform: translateY(-2px); }
    }

    .back-btn:hover {
        animation: none;
    }

    /* Game title styling */
    .game-title {
        text-align: center;
        margin-bottom: 20px;
        font-size: 2.5rem;
        font-weight: bold;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }
</style>
@endpush

@section('content')
<div class="game-wrapper">
    <iframe src="{{ asset('dino/index.html') }}"
            class="game-iframe"
            frameborder="0"
            title="Dino Game">
    </iframe>

    <button onclick="history.back()" class="back-btn">
        back
    </button>
</div>
@endsection

@push('scripts')
<script>
// Optional: Add some interactive effects
document.addEventListener('DOMContentLoaded', function() {
    const backBtn = document.querySelector('.back-btn');

    // Add ripple effect
    backBtn.addEventListener('click', function(e) {
        const ripple = document.createElement('span');
        const rect = this.getBoundingClientRect();
        const size = Math.max(rect.width, rect.height);
        const x = e.clientX - rect.left - size / 2;
        const y = e.clientY - rect.top - size / 2;

        ripple.style.width = ripple.style.height = size + 'px';
        ripple.style.left = x + 'px';
        ripple.style.top = y + 'px';
        ripple.classList.add('ripple');

        this.appendChild(ripple);

        setTimeout(() => {
            ripple.remove();
        }, 600);
    });
});
</script>

<style>
/* Ripple effect */
.back-btn {
    position: relative;
    overflow: hidden;
}

.ripple {
    position: absolute;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.4);
    transform: scale(0);
    animation: rippleAnimation 0.6s linear;
    pointer-events: none;
}

@keyframes rippleAnimation {
    to {
        transform: scale(4);
        opacity: 0;
    }
}
</style>
@endpush
