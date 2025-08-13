import webbrowser
from googleapiclient.discovery import build
import yt_dlp

# yt-dlp to music app/files script

# Filter videos for creative commons license and download mp3 from video if this condition is met, writing directly to the phone's storage under /Music
# Will be good for history videos, documentaries etc to listen to