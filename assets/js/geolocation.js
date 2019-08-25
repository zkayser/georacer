import socket from './socket';

const positionSuccess = (channel) => (position) => {
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
      .receive("ok", resp => console.log('joined location channel successfully', resp));
  }

  watchLocation() {
    navigator.geolocation.watchPosition(positionSuccess(this.channel), positionError, geoOptions);
  }
}