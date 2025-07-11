import sys
import yt_dlp
import re

# Run the Sript = python "c:\laragon\www\garuda-entertaint\scripts\download_music.py" "youtube url"
def clean_title(title):
    # Hilangkan tanda kurung dan isinya
    cleaned = re.sub(r'\(.*?\)', '', title).strip()

    # Cek apakah ada separator " - " untuk membalik urutan
    if ' - ' in cleaned:
        parts = cleaned.split(' - ', 1)  # Split hanya pada separator pertama
        if len(parts) == 2:
            artist = parts[0].strip()
            song = parts[1].strip()
            # Balik urutan: dari "Artist - Song" jadi "Song - Artist"
            return f"{song} - {artist}"

    # Jika tidak ada separator, kembalikan title asli yang sudah dibersihkan
    return cleaned

def sanitize_filename(filename):
    # Hilangkan karakter yang tidak diperbolehkan dalam nama file
    return re.sub(r'[<>:"/\\|?*]', '', filename)

def download_playlist(url):
    # Setup awal untuk ambil info playlist/album
    ydl_opts_info = {
        'quiet': True,
        'extract_flat': False, 
        'force_generic_extractor' : True,
    }

    with yt_dlp.YoutubeDL(ydl_opts_info) as ydl:
        info_dict = ydl.extract_info(url, download=False)

        # Cek apakah ini playlist/album atau single video
        if 'entries' in info_dict:
            # Ini playlist/album, process tiap lagu
            print(f"Found playlist/album with {len(info_dict['entries'])} tracks")

            for i, entry in enumerate(info_dict['entries']):
                if entry is None:
                    continue

                original_title = entry['title']
                flipped_title = clean_title(original_title)
                safe_filename = sanitize_filename(flipped_title)

                print(f"Track {i+1}: {original_title} -> {flipped_title}")

                # Setup download untuk lagu individual
                ydl_opts_download = {
                    'format': 'bestaudio/best',
                    'outtmpl': f'public/media/musics/{safe_filename}.%(ext)s',
                    'postprocessors': [{
                        'key': 'FFmpegExtractAudio',
                        'preferredcodec': 'mp3',
                        'preferredquality': '192',
                    }],
                    'force_generic_extractor' : True,
                }

                # Download lagu individual
                with yt_dlp.YoutubeDL(ydl_opts_download) as ydl_download:
                    try:
                        ydl_download.download([entry['webpage_url']])
                        print(f"✓ Downloaded: {safe_filename}.mp3")
                    except Exception as e:
                        print(f"✗ Failed to download: {original_title} - {str(e)}")
        else:
            # Ini single video
            original_title = info_dict['title']
            flipped_title = clean_title(original_title)
            safe_filename = sanitize_filename(flipped_title)

            print(f"Single track: {original_title} -> {flipped_title}")

            ydl_opts_download = {
                'format': 'bestaudio/best',
                'outtmpl': f'public/media/musics/{safe_filename}.%(ext)s',
                'postprocessors': [{
                    'key': 'FFmpegExtractAudio',
                    'preferredcodec': 'mp3',
                    'preferredquality': '192',
                }],
            }

            with yt_dlp.YoutubeDL(ydl_opts_download) as ydl_download:
                ydl_download.download([url])
                print(f"✓ Downloaded: {safe_filename}.mp3")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        download_playlist(sys.argv[1])
    else:
        print("No URL provided.")
