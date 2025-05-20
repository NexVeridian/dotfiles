# yt-dlp
https://github.com/yt-dlp/yt-dlp

# Docker
https://github.com/jauderho/dockerfiles/tree/main/yt-dlp

cd /mnt/disk1/main/Video

docker run -d --name yt-dlp --rm -it -v "$(pwd):/downloads:rw" jauderho/yt-dlp:latest -c -i -4 --output "%(uploader)s - %(title)s.%(ext)s" -r 1M --min-sleep-interval 900 --max-sleep-interval 1800 --merge-output-format mkv --playlist-start 1 --playlist-end 4 --sponsorblock-mark all --sponsorblock-remove all --embed-chapters -f "bestvideo[height<=1080]+bestaudio/best" -U https://youtu.be/Eq3bUFgEcb4?si=p3cMcj76vg21IRmm

docker attach yt-dlp

then detach with ctrl p then ctrl q
docker exec

# Mac
cd /Users/elijahmcmorris/Downloads

# Download best format available
yt-dlp -c -i -4 --output "%(uploader)s - %(title)s.%(ext)s" -r 1M --min-sleep-interval 600 --max-sleep-interval 1200 --merge-output-format mkv --playlist-start 1 --sponsorblock-mark all --sponsorblock-remove all --embed-chapters -f bestvideo+bestaudio/best https://youtu.be/1R97tphpD_M

yt-dlp -c -i -4 --output "%(uploader)s - %(title)s.%(ext)s" -r 1M --min-sleep-interval 60 --max-sleep-interval 300 --merge-output-format mkv --playlist-start 1 --sponsorblock-mark all --sponsorblock-remove all --embed-chapters --cookies C:\Users\Owner\Desktop\Stuff\!!Random\cookies.txt -f bestvideo+bestaudio/best https://www.youtube.com/c/hyojinbestfriends/videos

yt-dlp -c -i -4 --output "%(uploader)s - %(title)s.%(ext)s" -r 1M --min-sleep-interval 600 --max-sleep-interval 1200 --merge-output-format mkv --playlist-start 1 --sponsorblock-mark all --sponsorblock-remove all --embed-chapters -f "bestvideo[height<=1080]+bestaudio/best" https://youtu.be/bqeuFiAUU4o

yt-dlp -c -i -4 --output "%(uploader)s - %(title)s.%(ext)s" -r 1M --min-sleep-interval 600 --max-sleep-interval 1200 --merge-output-format mkv --playlist-start 1 --sponsorblock-mark all --sponsorblock-remove all --embed-chapters -f "bestvideo[height<=720]+bestaudio/best" https://youtu.be/bqeuFiAUU4o

yt-dlp -c -i -4 --output "%(uploader)s - %(title)s.%(ext)s" -r 1M --min-sleep-interval 600 --max-sleep-interval 1200 --merge-output-format mkv --playlist-start 1 --sponsorblock-mark all --sponsorblock-remove all --embed-chapters -f "bestvideo[height<=480]+bestaudio/best" https://youtu.be/_f6JvcPG8xU

yt-dlp -c -i -4 --output "%(uploader)s - %(title)s.%(ext)s" -r 1M --min-sleep-interval 150 --max-sleep-interval 600 --merge-output-format mkv --playlist-start 1 --sponsorblock-mark all --sponsorblock-remove all --embed-chapters -f "bestvideo[height<=480]+bestaudio/best" --force-keyframes https://youtu.be/_f6JvcPG8xU
