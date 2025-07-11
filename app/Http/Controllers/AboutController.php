<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class AboutController extends Controller
{
    public function index()
    {
        // Data subsidiaries dalam chunks (per slide)
        $subsidiariesChunks = [
            [
                [
                    'name' => 'Citilink',
                    'logo' => 'images/anak-perusahaan/logo-citilink.png',
                    'description' => 'Citilink is a low-cost carrier (LCC) airline that is a subsidiary of Garuda Indonesia. Citilink operates with a focus on city-to-city flights.'
                ],
                [
                    'name' => 'GMF AeroAsia',
                    'logo' => 'images/anak-perusahaan/logo-gmf-aeroasia.png',
                    'description' => 'GMF AeroAsia, or PT Garuda Maintenance Facility Aero Asia Tbk, is an Indonesian company engaged in aircraft maintenance and repair (MRO)'
                ],
                [
                    'name' => 'Sabre Travel Network',
                    'logo' => 'images/anak-perusahaan/logo-sabre.png',
                    'description' => 'Sabre Travel Network Indonesia is the largest travel reservation system (Global Distribution System or GDS) provider in Indonesia.'
                ]
            ],
            [
                [
                    'name' => 'Aero Wisata',
                    'logo' => 'images/anak-perusahaan/logo-aerowisata.png',
                    'description' => 'Also known as Aerowisata, is a subsidiary of Garuda Indonesia engaged in tourism and logistics.'
                ],
                [
                    'name' => 'Aero System',
                    'logo' => 'images/anak-perusahaan/logo-asyst.png',
                    'description' => 'ASYST provide advanced IT solutions for transportation, travel and related industry.'
                ],
                [
                    'name' => 'Garuda Cargo',
                    'logo' => 'images/anak-perusahaan/logo-garuda-cargo.png',
                    'description' => 'Garuda Indonesia Cargo is a strategic business unit (SBU) of PT Garuda Indonesia that provides freight forwarding services.'
                ]
            ],
            [
                [
                    'name' => 'Garuda Holiday France',
                    'logo' => 'images/anak-perusahaan/logo-holiday-france.png',
                    'description' => 'Garuda Holiday France is a subsidiary of PT Garuda Indonesia (Persero) Tbk operating in France.'
                ],
                [
                    'name' => 'Gapura Angkasa',
                    'logo' => 'images/anak-perusahaan/logo-gapura-angkasa.png',
                    'description' => 'PT Gapura Angkasa is a company that provides ground handling services and flight support activities at the airport.'
                ]
            ]
        ];

        return view('about', compact('subsidiariesChunks'));
    }
}
