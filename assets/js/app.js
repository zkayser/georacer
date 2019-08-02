// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import LiveSocket from "phoenix_live_view"
import socket from "./socket"

let liveSocket = new LiveSocket("/live")
liveSocket.connect()

socket.connect()

let channel = socket.channel("position:lobby", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

const positionSuccess = (position) => {
  channel.push("update", {
    latitude: position.coords.latitude,
    longitude: position.coords.longitude
  })
}

const positionError = () => {
  console.log('Error getting position...');
}

const geoOptions = {
  enableHighAccuracy: true,
  maximumAge: 10
}

navigator.geolocation.watchPosition(positionSuccess, positionError, geoOptions);
