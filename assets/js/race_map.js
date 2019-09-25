import Mapbox from 'mapbox-gl';
import { GeoLocation } from './geolocation';

const INITIAL_ZOOM = 15;
const DEFAULT_CENTER = [-84.51, 39.10];

Mapbox.accessToken = 'pk.eyJ1IjoicmhldWJhY2giLCJhIjoiY2p6Y3AzY2I3MDJxZTNubWp5eG1kaGdkMCJ9.46xDflykdiyFyFHWa7j1IA';

class RaceMap extends HTMLElement {
  constructor() {
    super();
    if (!window.__SINGLETON_RACE_MAP_INSTANCE__) {
      window.__SINGLETON_RACE_MAP_INSTANCE__ = this;
    }
    if (window.__SINGLETON_RACE_MAP_INSTANCE__ === this) {
      new GeoLocation(this.identifier);
    }
  }

  attributeChangedCallback() {
    if (!(this.latitude && this.longitude) || !(this === global.__SINGLETON_RACE_MAP_INSTANCE__)) {
      return;
    }
    this.renderMap();
    this.renderPosition();
  }

  get latitude() {
    return parseFloat(this.getAttribute('latitude'));
  }

  get longitude() {
    return parseFloat(this.getAttribute('longitude'));
  }

  get bounds() {
    const swLng = parseFloat(this.getAttribute('swLng'));
    const swLat = parseFloat(this.getAttribute('swLat'));
    const neLng = parseFloat(this.getAttribute('neLng'));
    const neLat = parseFloat(this.getAttribute('neLat'));
    return new Mapbox.LngLatBounds(
      new Mapbox.LngLat(swLat, swLng),
      new Mapbox.LngLat(neLat, neLng)
    );
  }

  get height() {
    return this.getAttribute('height');
  }

  get identifier() {
    return this.getAttribute('identifier');
  }

  static get observedAttributes() {
    return ['latitude', 'longitude'];
  }

  renderMapContainer() {
    let shadow = this.attachShadow({ mode: 'open' });
    let div = document.createElement('div');
    div.setAttribute('id', 'raceMap');
    div.setAttribute('class', 'map');
    div.setAttribute('style', `height: ${this.height || '100%'}; max-width: 100%; margin: 0 auto; display: flex; align-items: center; justify-content: center; z-index: 25;`);
    shadow.innerHTML = '<link href="https://api.tiles.mapbox.com/mapbox-gl-js/v1.2.1/mapbox-gl.css" rel="stylesheet" />'
    shadow.appendChild(div);
  }

  renderMap() {
    const shadowDom = this.shadowRoot;
    if (!shadowDom) {
      this.renderMapContainer();
    }
    3
    if (!this.map) {
      const container = this.shadowRoot.querySelector('#raceMap');
      this.map = new Mapbox.Map({
        container: container,
        style: 'mapbox://styles/rheubach/cjzcqemj42em61cp9p9cbqllw',
        zoom: INITIAL_ZOOM,
        antialias: true
      });
      const canvas = shadowDom.querySelector('.mapboxgl-canvas');
      canvas.style.left = '0px';
      canvas.style.top = '0px';
    }

    if (!(this.latitude && this.longitude)) {
      this.map.setCenter(DEFAULT_CENTER);
      this.map.setZoom(INITIAL_ZOOM);
    } else {
      this.map.setCenter(this.bounds.getCenter());
      this.addBoundary();
      this.map.setZoom(INITIAL_ZOOM);
    }
  }

  renderCenterIcon() {
    if (!this.shadowRoot) {
      return;
    }
    if (!this.centerIcon) {
      let el = document.createElement('div');
      el.className = 'center-icon';
      el.style.width = '26px';
      el.style.height = '26px';
      el.style.border = '5px solid red';
      el.style.backgroundColor = 'red';
      el.style.opacity = '0.5';
      el.style.borderRadius = '50%';
      this.centerIcon = el;
      this.centerMarker = new Mapbox.Marker(this.centerIcon).setLngLat(this.bounds.getCenter());
      this.centerMarker.addTo(this.map);
    }
  }

  addBoundary() {
    if (!this.map.getLayer('boundary')) {
      const [southwest, northwest, northeast, southeast] = [
        this.bounds.getSouthWest(),
        this.bounds.getNorthWest(),
        this.bounds.getNorthEast(),
        this.bounds.getSouthEast()
      ]
      console.log('Maybe adding the boundary... \shruggy');
      this.map.addLayer({
        'id': 'boundary',
        'type': 'line',
        'source': {
          'type': 'geojson',
          'data': {
            'type': 'Feature',
            'geometry': {
              'type': 'Polygon',
              'coordinates': [[
                [southwest.lng, southwest.lat],
                [northwest.lng, northwest.lat],
                [northeast.lng, northeast.lat],
                [southeast.lng, southeast.lat]
              ]]
            }
          }
        },
        'layout': {},
        'paint': {
          'line-color': '#088',
          'line-opacity': 0.8,
          'line-width': 5
        }
      })
    }
  }

  renderPosition() {
    if (!this.shadowRoot) {
      return;
    }
    if (this.positionMarker) {
      this.positionMarker.setLngLat([this.longitude, this.latitude]);
    }
    if (!this.icon) {
      let el = document.createElement('div');
      el.className = 'position-marker';
      el.style.backgroundImage = `url(${document.location.protocol}//${window.location.host}/images/location-marker.svg)`;
      el.style.width = '55px';
      el.style.height = '55px';
      this.icon = el;
      this.positionMarker = new Mapbox.Marker(this.icon).setLngLat([this.longitude, this.latitude])
      this.positionMarker.addTo(this.map);
    }
  }

  connectedCallback() {
    if (!(this === global.__SINGLETON_RACE_MAP_INSTANCE__)) {
      return;
    }
    this.renderMapContainer();
    this.renderMap();
    this.renderCenterIcon();
  }
}

export default RaceMap;
