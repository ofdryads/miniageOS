# "Dumb" Music Streaming Service Wrapper

**GO WITH APPLE MUSIC/MusicKit** - no requirement for official client install on the device, unlike Spotify API

music is not a visual medium - It has no interface.

(the album art, name, etc. are hidden except in metadata, until sought out by the user. 
Important to preserve all this info in some form or another for artists and listeners sake, but not have it bias or distract listener)

- app accesses local DB that stores user playlists, batch request to Apple music for playlist contents when first selected 
- allows users to search songs (the song name and artist will not be obscured here)
- see other users' containing a given song - also hide data for the songs in the playlist, but show the playlist name and creator
- allow adding to playlist from another playlist
- non-algorithm playlists shown to user sourced from:
    - people-made playlists - can get these as json or similar from other platforms using their APIs then use MusicKit for playback
    - people-written articles, music news outlets, etc.

- The UI should be minimal to an extreme - think touchscreen ipod shuffle
- But do allow playlist selection/curation/import

- do in kotlin

- Users should be able to generate a link to share with people who use spotify - it will create a playlist on real-spotify that can be shared