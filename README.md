# Livewall
A simple live wallpaper setter for linux written in bash 

#### Dependencies :
* ffmpeg
* feh

#### Usage :
```
wget https://raw.githubusercontent.com/Creator54/livewall/main/livewall
chmod +x livewall

./livewall start <path to video> <image type: jpg/png> <frame interval: greater than 20 is slow>
./livewall extract video.mp4 <path where to keep images>  <jpg/png> <frame interval>
./livewall set <images folder>
./livewall stop
```

#### Preview:
![Preview](./preview.gif)

#### License: 
```
The MIT License (MIT)

Copyright (c) 2022 Creator54<hi.creator54@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
