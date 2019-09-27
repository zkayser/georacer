# Geo Racer

Ready, set, race! With [GeoRacer.io](https://georacer.io/), you’ll set up a course of custom waypoints to race your friends! The game’s hot/cold meter will guide you as you rush to your next waypoint. Competition getting a little too close? Wanna keep your lead? Hit racers with one of the in game hazards. Find all the waypoints first to be the champ. There will be many GeoChasers, but only one GeoRacer. 

Geo Racer was created by a small, mighty team at [Gaslight](https://teamgaslight.com/), using [Phoenix](https://phoenixframework.org/) and [LiveView](https://github.com/phoenixframework/phoenix_live_view) for [Phoenix Phrenzy](https://phoenixphrenzy.com)

<img src="/assets/static/images/georacer-screens.png"  alt="Geo Racer App" width="550px" />

## Start your Phoenix server

### PostGIS Extensions
GeoRacer has a dependency on the PostGIS extensions for Postgres, so you will need to make sure you install those for your operating system. Take a look [at the official installation page] (https://postgis.net/install/) for instructions specific to your machine. Once you have the extensions installed, you should be able to run `mix ecto.setup` (make sure you've fetched your dependencies first with `mix deps.get`!) from the root directory and the Ecto migrations will take care of _enabling_ the extensions for you.

### Environment Variables
GeoRacer also requires you to have a `SECRET_KEY_BASE` environment variable set to run locally. If you don't have one already, you can generate one with:
```bash
export SECRET_KEY_BASE="$(mix phx.gen.secret)"
```

### Client-side Dependencies
Don't forget to install your client-side assets before running the app: `cd ./assets && npm install`

### Local Development
Run `mix phx.server` now and you can visit [`localhost:4000`](http://localhost:4000) the app in your browser.
Since the app was designed specifically for mobile devices, it is best to expose a portal or a way to access
the local server running on your machine from your mobile phone. One quick and easy option is to use [ngrok](https://ngrok.com/download).
Install `ngrok` on your machine and then `/path/to/ngrok http 4000`. This should print out two links, one that uses https.
You will want to use the secure https link to get the geolocation services to work on your device (browsers will not send
geolocation information over non-secure http connections).

## License
    All rights to Geo Racer Brand and design assets are reserved.

    Copyright (C) 2019  Gaslight LLC, Zack Kayser, Robert Heubach, Scott Wiggins

    Geo Racer is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Geo Racer is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    [GNU General Public License] (/LICENSE) for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
