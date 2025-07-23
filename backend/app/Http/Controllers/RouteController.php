<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class RouteController extends Controller
{
    public function index()
    {
        return view('route'); // halaman existing kamu
    }

    // Method baru untuk modal/iframe
    public function minimal()
    {
        return view('route-minimal'); // view yang baru dibuat
    }
}
