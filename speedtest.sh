wget "https://bintray.com/ookla/download/download_file?file_path=ookla-speedtest-1.0.0-x86_64-linux.tgz" -O speedtest.tgz
tar -xf speedtest.tgz
rm speedtest.tgz speedtest.5 speedtest.md
mv speedtest /usr/local/bin
