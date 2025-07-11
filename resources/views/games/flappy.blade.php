@extends('layouts.app')

@section('content')
<div class="min-h-screen bg-black flex justify-center items-center">
  <div id="game-container" class="w-full h-[600px]"></div>
</div>

@push('scripts')
<script type="module" src="{{ asset('js/flappy.js') }}"></script>
@endpush
@endsection
