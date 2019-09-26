import socket from './socket';

const positionSuccess = (channel) => (position) => {
  channel.push("update", {
    latitude: position.coords.latitude,
    longitude: position.coords.longitude,
    accuracy: position.coords.accuracy
  })
}

const positionError = (channel) => (e) => {
  channel.push("update", {
    latitude: 39.10,
    longitude: -84.51
  })
}

const geoOptions = {
  enableHighAccuracy: true,
  timeout: 5000
};

export class GeoLocation {
  constructor(channelIdentifier) {
    this.channelIdentifier = channelIdentifier;
    this.connectToLocationChannel();
    this.watchLocation();
  }

  connectToLocationChannel() {
    if (!socket.isConnected()) {
      socket.connect();
    }

    this.channel = socket.channel(`location:${this.channelIdentifier}`, {});
    this.channel.join()
      .receive("ok", () => {
        this.watchLocation();
      });
  }

  watchLocation() {
    navigator.geolocation.watchPosition(positionSuccess(this.channel), positionError(this.channel), geoOptions);
  }
}