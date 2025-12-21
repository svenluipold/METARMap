# METARMap
Raspberry Pi project for visualizing flight conditions on a map using WS8211 LEDs adressed wia NeoPixel and https://aviationweather.gov databse.

Forked from https://github.com/prueker/METARMap on 5.12.2025.


# Installation (updated)
## Software Setup
* Install Raspberry Pi OS Lite x64 on SD Card
* Use `Raspberry Pi Imager` (https://www.raspberrypi.com/software/) and configure settings like `user`, `password`, `hostname` and `wifi`
* SSH into Raspberry with set credentials

* Update system
  * `sudo apt-get update`
  * `sudo apt-get upgrade`

* Install python, venv and git (auto yes)
  * `sudo apt install python3-full python3-venv git -y`

* Create virutal python environment (required)
  * Note in this case it will be called `neopixel-env`
  * `python3 -m venv neopixel-env`   

* Activate created environment and install further packages:
  * `source neopixel-env/bin/activate`
  * (Optional) Update paket-manager `python -m pip install --upgrade pip setuptools wheel`
  * Install neopixel `pip install rpi_ws281x adafruit-blinka adafruit-circuitpython-neopixel`
  * Install astral (optional) `pip install astral`
  * `deactivate`

* Test LEDs:
*  Note: to test LEDs and use the Neopixel library correctly, python mus be executed under sudo permissions within venv.
*  To do so: `sudo ~/neopixel-env/bin/python`
*  Execute test-code:
    ```
    import board
    import neopixel
    
    pixels = neopixel.NeoPixel(board.D18, 30, auto_write=True, brightness=0.5)
    pixels.fill((255, 0, 0))
    ```
 
* Clone this repositiory into your desired folder on the Raspberry Pi.


## Hardware Setup
* Attatch WS8211 or WD8212 LEDs to Raspberry Pi (up to 25 should be no problem without external power supply).
* In this case GPIO18 was used. This may be changed by editing **`LED_PIN`**
* You can find [more details about wiring here](https://learn.adafruit.com/neopixels-on-raspberry-pi/raspberry-pi-wiring).



## Completing Software Setup and Running Script
* Add your airports in the **[airports](airports)** file (ICAO)-lettering

* Set the following parameter in the **[metar.py](metar.py)** and **[pixelsoff.py](pixelsoff.py)** file: 
  * **`LED_COUNT`**: your amount of LEDs used including "blanks"

* Edit (set correct paths) and grant read/write persissions to following files:
  * **[refresh.sh](refresh.sh)** file
  * **[lightsoff.sh](lightsoff.sh)** file
  by using:
  * `chmod +x filename` will grant execute permissions
  * `chmod +r filename` will grant write permissions

* To have the script start up automatically and refresh in regular intervals, use crontab and set the appropriate interval. For an example you can refer to the [crontab-example](crontab-example) file in the GitHub repo (note: file execute permissions must be granted beforehand to the **[refresh.sh](refresh.sh)** and **[lightsoff.sh](lightsoff.sh)** file).
* To edit crontab type: **`crontab -e`**, after you are done with the edits, exit out by pressing **ctrl+x** and confirm the write operation
  * Be sure to set the correct paths
  * The sample crontab will run the script every 5 minutes (the */5) between the hours of 7 to 21, which includes the 21 hour, so it means it will run until 21:55
  * Then at 22:05 it will run the lightsoff.sh script, which will turn all the lights off



## Additions
These following additions can be configured in the **[metar.py](metar.py)** file.


### LED dimming based on time
This optional functionality enabled running the LEDs at a dimmed lower level between a certain time of the day.

If you want to this extra functionality, set the **`ACTIVATE_DAYTIME_DIMMING`** to **True**.
Set the **`LED_BRIGHTNESS_DIM`** setting to the level you want to run when dimmed.

For time timings of the dimming there are two options:

* Fixed time of day dimming:
  * **`BRIGHT_TIME_START`** - Set this to the beginning of the day when you want to run at the normal **`LED_BRIGHTNESS`** level
  * **`DIM_TIME_START`** - Set this to the time where you want to run at a different **`LED_BRIGHTNESS_DIM`** level


### Using Astral (Dimming LEDs based on sunrise/sunset)
* Dimming based on local sunrise/sunset:
  * For this to work, you need to install an additional library, run:
    * Activate environment `source /.../.../activate`
    * `sudo pip3 install astral`
    * `deactivate`
  * `USE_SUNRISE_SUNSET` - Set this to **True** to use the dimming based on sunrise and sunset
  * `LOCATION` - set this to the city you want to use for sunset/sunrise timings
    * Use the closest city from the list of supported cities from https://astral.readthedocs.io/en/latest/#cities



### Using light sensor
A external light sensor may be used to dim the LEDs according to the prevailing brighness in the room. Recommended: `Adafruit BH1750`

* Attatch to I2C bus (SDA and SDC)
* Activate I2C bus in raspi settings:
  * `sudo raspi-config`
  * → Interface Options → activate I2C → reboot

* Install packages:
  * Activate environment `source /.../.../activate`
  * Install bh1750 light sensor `pip install adafruit-circuitpython-bh1750`
  * `deactivate`

* Check function:
  * `sudo apt install i2c-tools -y`
  * `i2cdetect -y 1`
  * --> 0x23 oder 0x5C in scan-table

* Set custom thresholds for LUX-values (may vary depending on sensors used):
```python
LUX_THRESHOLD_LOW 		= 2
LUX_THRESHOLD_LOW_MED 	= 10
LUX_THRESHOLD_MED 		= 25
LUX_THRESHOLD_MED_HIGH 	= 50
LUX_THRESHOLD_HIGH 		= 100
```

* Set according LED-brightness levels:
```python
LED_BRIGHTNESS_LOW		= LED_BRIGHTNESS_DIM		# Lowest brightness (from settings LED_BRIGHTNESS_DIM)
LED_BRIGHTNESS_LOW_MED	= 0.015
LED_BRIGHTNESS_MED		= 0.02
LED_BRIGHTNESS_MED_HIGH = 0.05
LED_BRIGHTNESS_HIGH		= 0.075
LED_BRIGHTNESS_HIGH_HIGH= LED_BRIGHTNESS			# Max brightness (from settings LED_BRIGHTNESS)
```


## Legend
If you want an interactive Legend to illustrate the possible behaviors you can do so by adding an additional up to 7 LEDs after the last LED based on your number of LEDs of the airports in the **airports** file

* Set `SHOW_LEGEND` to **True** to use this feature
* If you want to skip some LEDs after your last airport before the legend, you can set `OFFSET_LEGEND_BY` to the number of LEDs to skip
* **Note**: The Lightning and Wind Condition LEDs will only show if you are actually using these features based on the `ACTIVATE_LIGHTNING_ANIMATION`, `ACTIVATE_WINDCONDITION_ANIMATION` and `HIGH_WINDS_THRESHOLD` variables.
  * If you are not using any of these, then you only need 4 LEDs for the basic flight conditions for the Legend
  * If you are only using the Wind condition feature, but not the Lightning, you will still need the total of 7 LEDs (but the 5th LED for Lightning will just stay blank) or you'd have to change the order in the code



## Detailed instructions

I've created detailed instructions about the setup and parts used here: https://slingtsi.rueker.com/making-a-led-powered-metar-map-for-your-wall/



## Additional Wind condition blinking/fading functionality

I recently expanded the script to also take wind condition into account and if the wind exceeds a certain threshold, or if it is gusting, make the LED for that airport either blink on/off or to fade between  two shades of the current flight category color.

If you want to use this extra functionality, then inside the **[metar.py](metar.py)** file set the **`ACTIVATE_WINDCONDITION_ANIMATION`** parameter to **True**.

* There are a few additional parameters in the script you can configure to your liking:
  * `FADE_INSTEAD_OF_BLINK` - set this to either **True** or **False** to switch between fading or blinking for the LEDs when conditions are windy
  * `WIND_BLINK_THRESHOLD` - in Knots for normal wind speeds currently at the airport
  * `ALWAYS_BLINK_FOR_GUSTS` - If you always want the blinking/fading to happen for gusts, regardless of the wind speed
  * `BLINKS_SPEED` - How fast the blinking happens, I found 1 second to be a happy medium so it's not too busy, but you can also make it faster, for example every half a second by using 0.5
  * `BLINK_TOTALTIME_SECONDS` = How long do you want the script to run. I have this set to 300 seconds as I have my crontab setup to re-run the script every 5 minutes to get the latest weather information
  * `HIGH_WINDS_THRESHOLD` - If you want LEDs to flash to Yellow for particularly high winds beyond the normal `WIND_BLINK_THRESHOLD` then set this variable in knots. If you only want normal blinking/fading based on `WIND_BLINK_THRESHOLD` then set the value for `HIGH_WINDS_THRESHOLD` to **`-1`**

## Additional Lightning in the vicinity blinking functionality

After the recent addition for wind condition animation, I got another request from someone if I could add a white blinking animation to represent lightning in the area.
Please note that due to the nature of the METAR system, this means that the METAR for this airport reports that there is Lightning somewhere in the vicinity of the airport, but not necessarily right at the airport.

If you want to use this extra functionality, then inside the **[metar.py](metar.py)** file set the **`ACTIVATE_LIGHTNING_ANIMATION`** parameter to **True**.

* This shares two configuration parameters together with the wind animation that you can modify as you like:
  * `BLINKS_SPEED` - How fast the blinking happens, I found 1 second to be a happy medium so it's not too busy, but you can also make it faster, for example every half a second by using 0.5
  * `BLINK_TOTALTIME_SECONDS` = How long do you want the script to run. I have this set to 300 seconds as I have my crontab setup to re-run the script every 5 minutes to get the latest weather information


## Additional mini display to show METAR information functionality

This optional functionality allows you to connect a small mini LED display to show the METAR information of the airports.

For this functionality to work, you will need to buy a compatible LED display and enable and install a few additional things.

I've written up some details on the display I used and the wiring here: https://slingtsi.rueker.com/adding-a-mini-display-to-show-metar-information-to-the-metar-map/

To support the display you need to enable a few new libraries and settings on the raspberry pi.

* [Enable I2C](https://learn.adafruit.com/adafruits-raspberry-pi-lesson-4-gpio-setup/configuring-i2c)
* `sudo raspi-config`
* Interface Options
* I2C
* reboot the Reboot the Raspberry Pi `sudo reboot`
* Verify your wiring is working and I2C is enabled
  * `sudo apt-get install i2c-tools`
  * `sudo i2cdetect -y 1` - this should show something connected at **3C**
* install python library for the display
  * `sudo pip3 install adafruit-circuitpython-ssd1306`
  * `sudo pip3 install pillow`
* install additional libraries needed to fill the display
  * `sudo apt-get install fonts-dejavu`
  * `sudo apt-get install libjpeg-dev -y`
  * `sudo apt-get install zlib1g-dev -y`
  * `sudo apt-get install libfreetype6-dev -y`
  * `sudo apt-get install liblcms1-dev -y`
  * `sudo apt-get install libopenjp2-7 -y`
  * `sudo apt-get install libtiff5 -y`
* copy new file **[displaymetar.py](displaymetar.py)** into the same folder as **[metar.py](metar.py)**
* Use the latest version of **[metar.py](metar.py)** and **[pixelsoff.py](pixelsoff.py)** for the new functionality
* Configure **[metar.py](metar.py)** and set **`ACTIVATE_EXTERNAL_METAR_DISPLAY`** parameter to **True**.
* Configure the `DISPLAY_ROTATION_SPEED` to your desired timing, I'm using 5 seconds for mine.
* If you want to only show a subset of the airports on the display, create a new file in the folder called **displayairports** and add the airports that you want to be shown on the display to it


## Changelist

To see a list of changes to the metar script over time, refer to [CHANGELIST.md](CHANGELIST.md)





