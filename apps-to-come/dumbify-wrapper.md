# Dumb Music Streaming Service Wrapper
## aka skibuffle-streamer

**GO WITH APPLE MUSIC/MusicKit** - no requirement for official client install

Thesis statement: music is not a visual medium. It has no interface.

- same concept as skibuffle (the album art, name, etc. are hidden except in metadata)

- app accesses local DB that stores user playlists and queries streaming service per-song based on the local DB contents to play each song in the playlist
- allows users to search songs (the song name and artist will not be obscured here)
- see other users' containing a given song - also hide data for the songs in the playlist, but show the playlist name and creator
- allow adding to playlist from another playlist
- non-algorithm playlists shown to user sourced from articles, music news outlets, etc.

- The UI should be minimal to an extreme - think touchscreen ipod shuffle
- But do allow playlist selection/curation/import/programmatic access

- do in kotlin

- Users should be able to generate a link to share with people who use spotify  - it will create a playlist on real-spotify that can be shared
