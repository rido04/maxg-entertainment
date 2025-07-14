@extends('layouts.app')

@section('content')
<div class="about-page">
    <!-- Hero Section - Penjelasan Aplikasi Kolaborasi dan Company Profile -->
    <section class="hero-section">
        <div class="container">
            <div class="collaboration-logos">
                <div class="logo-container">
                    <div class="main-logo-wrapper">
                        <img src="{{asset('images/logo/Maxg-ent_green.gif')}}" alt="maxg logo" class="maxg-logo">
                        <div class="by-logo">
                            <span class="by-text">By:</span>
                            <img src="{{asset('images/logo/logo mcm color.png')}}" alt="mcm logo" class="mcm-logo">
                        </div>
                    </div>
                </div>
            </div>

            <div class="content-wrapper">
                <div class="unified-content">
                    <p class="description">
                        <span class="text-green-600">MaxG Entertainment </span>adalah sebuah aplikasi hiburan yang lahir dari kolaborasi antara <span class="text-blue-600">MCMMedianetworks</span> dan <span class="text-green-700">Grab </span>Indonesia.
                        Diciptakan untuk menghadirkan pengalaman hiburan digital yang imersif, MaxG memanfaatkan kekuatan teknologi terkini dan jangkauan luas ekosistem Grab untuk menyajikan konten hiburan berkualitas tinggi, langsung di genggaman pengguna.

                        Melalui MaxG, pengguna dapat menikmati beragam konten mulai dari film, musik, game, hingga informasi interaktif yang dikurasi khusus untuk menemani perjalanan mereka.
                        Kami percaya bahwa hiburan tidak hanya tentang mengisi waktu luang, tetapi juga menciptakan momen yang menyenangkan dan berkesan di setiap perjalanan Anda.
                    </p>

                    <p class="description">
                        <span class="text-blue-600">MCMMedianetworks</span> adalah perusahaan yang bergerak di bidang media dan periklanan, dengan spesialisasi dalam penyediaan solusi kreatif dan strategis untuk kebutuhan promosi brand di berbagai platform, baik offline maupun digital. Kami percaya bahwa setiap brand memiliki cerita yang unik, dan tugas kami adalah membantu menyampaikannya dengan cara yang paling berdampak.

                        Dengan beragam layanan yang saling terintegrasi, kami hadir untuk membantu klien membangun kepercayaan, memperluas jangkauan, dan menciptakan keterlibatan yang nyata dengan audiens mereka. Tim kreatif kami yang berpengalaman siap memberikan solusi inovatif untuk setiap tantangan komunikasi brand modern.

                        Dengan semangat inovasi dan komitmen terhadap kualitas, MaxG Entertainment Hub hadir sebagai solusi hiburan masa kini — mudah diakses, relevan, dan dirancang untuk memberikan pengalaman terbaik bagi seluruh pengguna Grab di seluruh Indonesia.
                    </p>
                </div>
            </div>
        </div>
    </section>
</div>

<style>
    .about-page {
        min-height: 100vh;
        background: #f8fafc;
    }

    .container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 20px;
    }

    /* Hero Section */
    .hero-section {
        background: white;
        padding: 60px 0 80px 0;
        border-bottom: 1px solid #e5e7eb;
    }

    .collaboration-logos {
        display: flex;
        justify-content: center;
        margin-bottom: 40px;
    }

    .logo-container {
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .main-logo-wrapper {
        display: flex;
        align-items: center;
        gap: 20px;
    }

    .maxg-logo {
        width: auto;
        height: 96px; /* equivalent to h-24 */
    }

    .by-logo {
        margin-top: 40px;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .by-text {
        font-size: 16px;
        color: #6b7280;
        font-weight: 500;
    }

    .mcm-logo {
        width: auto;
        height: 35px; /* equivalent to h-10 */
    }

    .main-title {
        font-family: Arial, Helvetica, sans-serif;
        font-size: 2.5rem;
        color: #1e3a8a;
        margin-bottom: 10px;
        text-align: center;
        font-weight: 700;
    }

    .subtitle {
        font-size: 1.2rem;
        color: #6b7280;
        text-align: center;
        margin-bottom: 40px;
    }

    .content-wrapper {
        padding: 20px;
        margin-bottom: 40px;
    }

    .unified-content {
        max-width: 1000px;
        margin: 0 auto;
    }

    .description {
        font-size: 1.15rem;
        line-height: 1.8;
        color: #374151;
        text-align: justify;
    }

    /* Responsive Design */
    @media (max-width: 768px) {
        .main-title {
            font-size: 2rem;
        }

        .description {
            text-align: left;
            font-size: 1.1rem;
        }

        .main-logo-wrapper {
            flex-direction: column;
            gap: 15px;
            align-items: center;
        }

        .maxg-logo {
            height: 80px;
        }

        .mcm-logo {
            height: 32px;
        }

        .by-text {
            font-size: 14px;
        }
    }

    @media (max-width: 480px) {
        .description {
            text-align: left;
            font-size: 1rem;
        }

        .main-logo-wrapper {
            gap: 10px;
        }

        .maxg-logo {
            height: 70px;
        }

        .mcm-logo {
            height: 28px;
        }

        .by-logo {
            gap: 6px;
        }
    }
</style>
@endsection
