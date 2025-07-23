<!-- filepath: c:\laragon\www\garuda-entertaint\resources\views\components\navbar.blade.php -->
<div class="sticky top-0 z-50 px-8 py-6 border-b border-slate-700/50 bg-gradient-to-b from-teal-800 to-slate-800 text-white">
    <div class="flex items-center justify-between">
        <!-- Branding Section -->
        <div class="flex items-center space-x-3">
            <div class="w-10 h-10 bg-gradient-to-r from-teal-400 to-teal-600 rounded-lg flex items-center justify-center">
                <img src="{{ asset('logo_garuda.png') }}" alt="Garuda Airlines">
            </div>
            <div>
                <h1 class="text-white text-xl font-bold">Garuda Indonesia</h1>
                <p class="text-teal-300 text-sm">Entertainment Hub</p>
            </div>
        </div>
        <!-- Time Section -->
        <div class="text-right">
            <p class="text-slate-300 text-sm">Origin Time</p>
            <p class="text-white font-bold text-xl" id="realtime-clock"></p>
            <p class="text-slate-400 text-sm">WIB</p>
        </div>
    </div>
</div>

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {
    function updateClock() {
        const now = new Date();
        const options = { timeZone: 'Asia/Jakarta', hour: '2-digit', minute: '2-digit', hour12: true };
        const timeString = now.toLocaleTimeString('en-US', options).replace(/^0/, '');
        document.getElementById('realtime-clock').textContent = timeString;
    }
    updateClock();
    setInterval(updateClock, 1000);
});
</script>
@endpush
