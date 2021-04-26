apt install unzip -y && \
wget https://cdn.ipip.net/17mon/besttrace4linux.zip && \
unzip besttrace4linux.zip && \
rm -rf besttrace32 besttrace4linux.txt besttrace4linux.zip besttracearm besttracebsd besttracebsd32 besttracemac && \
chmod +x besttrace && \
mv besttrace /usr/local/bin
