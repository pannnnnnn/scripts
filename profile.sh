(echo 'if [ "`id -u`" -eq 0 ]; then' && echo -e "    PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"\nfi\nexport PATH" && cat /etc/profile) > temp && mv temp /etc/profile
