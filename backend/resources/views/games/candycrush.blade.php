@extends('layouts.app') {{-- atau sesuai layout kamu --}}

@section('title', 'Candy Crush Game')

@section('content')
    <div style="text-align: center;">
        <iframe
            src="{{ asset('game/candy-crush-master/index.html') }}"
            width="100%"
            height="700"
            frameborder="0"
            style="border: 2px solid #ccc; border-radius: 12px;">
        </iframe>
    </div>
@endsection
