import webbrowser
from googleapiclient.discovery import build
import yt_dlp

# yt-dlp to music app/files script

# Filter for creative commons 

# Set up YouTube API client
youtube = build("youtube", "v3", developerKey="YOUR_API_KEY")

Link: https://www.youtube.com/results?search_query=history&sp=EgIwAQ%253D%253D

[BOT GENERATED]

The sp parameter is used to filter the search results based on specific features. It is base64-encoded, and when decoded, it specifies what kind of filtering or sorting YouTube should apply.

Decoded value of sp=EgIwAQ%253D%253D:

When decoded from Base64, the value EgIwAQ%253D%253D becomes EgIwAQ==. This corresponds to the filter for Creative Commons (CC) videos.

    EgIwAQ== is a specific YouTube filter code that tells YouTube to show only videos uploaded under a Creative Commons license. The specific encoding ensures that the search results will show only videos that are marked by the uploader as being Creative Commons licensed.

    https://www.youtube.com/results?search_query=<your_search_term>&sp=EgIwAQ%253D%253D

2. Use the YouTube API to Check Each Video's License:

You can use the YouTube Data API v3 to get information about each video in a playlist, including its license. Here's how you could do it programmatically:

Step 1: Use the API to retrieve the playlist videos.
Step 2: For each video, use the API to check the license field in the video's metadata.

If the license is creativeCommon, it’s a Creative Commons video.
