## Notes on the Twelve app (built-in LineageOS music app)

- AFAIK there is no good way to bulk-add or programmatically populate "true" playlists in this app - you would have to click all the songs you want to add to it individually or use m3u files

HOWEVER

- Any mp3 file within a given subdirectory of /Music is treated as belonging to an album named {subdirectory}, but only if the mp3 file's "Album" metadata field is empty

- So, stripping mp3 files of their "Album" metadata before copying them to a folder within /Music allows "Albums" on the phone to effectively function as playlists (they are consolidated, curated, have shuffle, etc.)
    - Try exiftool

- Not a problem with yt-dlp sourced mp3s since they don't download w/ that metadata
