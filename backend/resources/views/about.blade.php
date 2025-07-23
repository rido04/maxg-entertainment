@extends('layouts.app')

@section('content')
<div class="min-h-screen bg-gray-50">
    <!-- Hero Section - Penjelasan Aplikasi Kolaborasi dan Company Profile -->
    <section class="bg-white py-16 md:py-20 border-b border-gray-200">
        <div class="max-w-6xl mx-auto px-5">
            <div class="flex justify-center mb-10">
                <div class="flex items-center justify-center">
                    <div class="flex flex-col sm:flex-row items-center gap-4 md:gap-5">
                        <img src="{{asset('images/logo/Maxg-ent_green.gif')}}" alt="maxg logo" class="w-auto h-20 md:h-20 lg:h-24">
                        <div class="flex items-center gap-2 mt-6 md:mt-10">
                            <span class="text-sm md:text-base text-gray-500 font-medium">By:</span>
                            <img src="{{asset('images/logo/logo mcm color.png')}}" alt="mcm logo" class="w-auto h-7 md:h-8 lg:h-9">
                        </div>
                    </div>
                </div>
            </div>

            <div class="px-5 mb-10">
                <div class="max-w-4xl mx-auto space-y-6">
                    <p class="text-base sm:text-2xl md:text-lg leading-relaxed text-gray-700 text-justify md:text-justify">
                        <span class="text-green-600">MaxG Entertainment </span>adalah sebuah aplikasi hiburan yang lahir dari kolaborasi antara <span class="text-blue-600">MCMMedianetworks</span> dan <span class="text-green-700">Grab </span>Indonesia.
                        Diciptakan untuk menghadirkan pengalaman hiburan digital yang imersif, MaxG memanfaatkan kekuatan teknologi terkini dan jangkauan luas ekosistem Grab untuk menyajikan konten hiburan berkualitas tinggi, langsung di genggaman pengguna.
                    </p>

                    <p class="text-base sm:text-2xl md:text-lg leading-relaxed text-gray-700 text-justify md:text-justify">
                        Melalui MaxG, pengguna dapat menikmati beragam konten mulai dari film, musik, game, hingga informasi interaktif yang dikurasi khusus untuk menemani perjalanan mereka.
                        Kami percaya bahwa hiburan tidak hanya tentang mengisi waktu luang, tetapi juga menciptakan momen yang menyenangkan dan berkesan di setiap perjalanan Anda.
                    </p>

                    <p class="text-base sm:text-2xl md:text-lg leading-relaxed text-gray-700 text-justify md:text-justify">
                        <span class="text-blue-600">MCMMedianetworks</span> adalah perusahaan yang bergerak di bidang media dan periklanan, dengan spesialisasi dalam penyediaan solusi kreatif dan strategis untuk kebutuhan promosi brand di berbagai platform, baik offline maupun digital. Kami percaya bahwa setiap brand memiliki cerita yang unik, dan tugas kami adalah membantu menyampaikannya dengan cara yang paling berdampak.
                    </p>

                    <p class="text-base sm:text-2xl md:text-lg leading-relaxed text-gray-700 text-justify md:text-justify">
                        Dengan beragam layanan yang saling terintegrasi, kami hadir untuk membantu klien membangun kepercayaan, memperluas jangkauan, dan menciptakan keterlibatan yang nyata dengan audiens mereka. Tim kreatif kami yang berpengalaman siap memberikan solusi inovatif untuk setiap tantangan komunikasi brand modern.
                    </p>

                    <p class="text-base sm:text-2xl md:text-lg leading-relaxed text-gray-700 text-justify md:text-justify">
                        Dengan semangat inovasi dan komitmen terhadap kualitas, MaxG Entertainment Hub hadir sebagai solusi hiburan masa kini — mudah diakses, relevan, dan dirancang untuk memberikan pengalaman terbaik bagi seluruh pengguna Grab di seluruh Indonesia.
                    </p>
                </div>
            </div>
        </div>
    </section>
</div>
@endsection
