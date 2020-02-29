# Tootle [fork]

A simple [Mastodon](https://github.com/tootsuite/mastodon) client designed for elementary OS, originally developed by [@bleakgrey](https://github.com/bleakgrey/tootle).

![Tootle Screenshot](https://raw.githubusercontent.com/cleac/tootle/master/data/screenshot.png)

## Building and Installation

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/me.cleac.tootle)
<a href='https://flathub.org/apps/details/me.cleac.tootle'><img height='51' alt='Download on Flathub' src='https://flathub.org/assets/badges/flathub-badge-en.png'/></a>

First of all you'll need some dependencies to build and run the app:
* meson
* valac
* libgtk-3-dev
* libsoup2.4-dev
* libgranite-dev
* libjson-glib-dev

Then run these commands to build and install it:

    meson build --prefix=/usr
    cd build
    sudo ninja install
    me.cleac.tootle
    
## Contributing

If you feel like contributing, you're always welcome to help the project in many ways:
* Reporting any issues
* Suggesting ideas and functionality
* Submitting pull requests

## Credits
* Original project by [@bleakgrey](https://github.com/bleakgrey)
* Tootle Logo by [@CallMeFib3r](https://github.com/CallMeFib3r)
* Medel typeface by Ozan Karakoc
* French translation by [@Larnicone](https://github.com/Larnicone)
* Polish translation by [@m4sk1n](https://github.com/m4sk1n)
* German translation by [@koyuawsmbrtn](https://github.com/koyuawsmbrtn)
* Simplified Chinese translation by [@gloomy-ghost](https://github.com/gloomy-ghost)
