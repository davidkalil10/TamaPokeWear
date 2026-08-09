import urllib.request, re
url = 'https://downloads.khinsider.com/search?search=littleroot+town'
html = urllib.request.urlopen(urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})).read().decode('utf-8')
for match in re.finditer(r'href="(/game-soundtracks/album/[^"]*?littleroot[^"]*?\.mp3)"', html, re.I):
    print(match.group(1))
