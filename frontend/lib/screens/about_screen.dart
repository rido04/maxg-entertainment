// lib/screens/about_screen.dart
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section - Company Profile
            Container(
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 64.0,
                  horizontal: 20.0,
                ),
                child: Column(
                  children: [
                    // Logo Section
                    Container(
                      margin: const EdgeInsets.only(bottom: 40.0),
                      child: Column(
                        children: [
                          // Main Logo Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // MaxG Logo - menggunakan Image.asset
                              Image.asset(
                                'assets/images/logo/Maxg-ent_green.gif',
                                height: 120, // Diperbesar dari 80 ke 100
                                width: 150, // Diperbesar dari 120 ke 150
                                // Fallback jika gambar tidak ditemukan
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height:
                                        100, // Sesuaikan dengan ukuran Image.asset
                                    width:
                                        150, // Sesuaikan dengan ukuran Image.asset
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'MaxG\nEntertainment',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 10),
                              // "By:" text and MCM logo
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Text(
                                        'By:',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // MCM Logo - menggunakan Image.asset
                                      Image.asset(
                                        'assets/images/logo/logo mcm color.png',
                                        height: 32,
                                        width: 80,
                                        fit: BoxFit.contain,
                                        // Fallback jika gambar tidak ditemukan
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                height: 32,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[100],
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'MCM',
                                                    style: TextStyle(
                                                      color: Colors.blue[700],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Content Section
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          // Paragraph 1
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: RichText(
                              textAlign: TextAlign.justify,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: Colors.grey[700],
                                ),
                                children: [
                                  TextSpan(
                                    text: 'MaxG Entertainment ',
                                    style: TextStyle(
                                      color: Colors.green[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        'adalah sebuah aplikasi hiburan yang lahir dari kolaborasi antara ',
                                  ),
                                  TextSpan(
                                    text: 'MCMMedianetworks',
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const TextSpan(text: ' dan '),
                                  TextSpan(
                                    text: 'Grab ',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        'Indonesia. Diciptakan untuk menghadirkan pengalaman hiburan digital yang imersif, MaxG memanfaatkan kekuatan teknologi terkini dan jangkauan luas ekosistem Grab untuk menyajikan konten hiburan berkualitas tinggi, langsung di genggaman pengguna.',
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Paragraph 2
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Text(
                              'Melalui MaxG, pengguna dapat menikmati beragam konten mulai dari film, musik, game, hingga informasi interaktif yang dikurasi khusus untuk menemani perjalanan mereka. Kami percaya bahwa hiburan tidak hanya tentang mengisi waktu luang, tetapi juga menciptakan momen yang menyenangkan dan berkesan di setiap perjalanan Anda.',
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),

                          // Paragraph 3
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: RichText(
                              textAlign: TextAlign.justify,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: Colors.grey[700],
                                ),
                                children: [
                                  TextSpan(
                                    text: 'MCMMedianetworks',
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        ' adalah perusahaan yang bergerak di bidang media dan periklanan, dengan spesialisasi dalam penyediaan solusi kreatif dan strategis untuk kebutuhan promosi brand di berbagai platform, baik offline maupun digital. Kami percaya bahwa setiap brand memiliki cerita yang unik, dan tugas kami adalah membantu menyampaikannya dengan cara yang paling berdampak.',
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Paragraph 4
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Text(
                              'Dengan beragam layanan yang saling terintegrasi, kami hadir untuk membantu klien membangun kepercayaan, memperluas jangkauan, dan menciptakan keterlibatan yang nyata dengan audiens mereka. Tim kreatif kami yang berpengalaman siap memberikan solusi inovatif untuk setiap tantangan komunikasi brand modern.',
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),

                          // Paragraph 5
                          Text(
                            'Dengan semangat inovasi dan komitmen terhadap kualitas, MaxG Entertainment Hub hadir sebagai solusi hiburan masa kini — mudah diakses, relevan, dan dirancang untuk memberikan pengalaman terbaik bagi seluruh pengguna Grab di seluruh Indonesia.',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
