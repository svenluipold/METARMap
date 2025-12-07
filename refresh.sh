/usr/bin/sudo pkill -F /home/atc/METARMap/offpid.pid
/usr/bin/sudo pkill -F /home/atc/METARMap/metarpid.pid

# user        |             venv path           |      script to execute     |      log output
/usr/bin/sudo  /home/atc/neopixel-env/bin/python /home/atc/METARMap/metar.py & echo $! > /home/atc/METARMap/metarpid.pid
