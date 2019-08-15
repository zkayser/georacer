import Leaflet from 'leaflet';

const TILE_URL = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
const INITIAL_ZOOM = 16;
const DEFAULT_CENTER = [39.10, 84.51];

class GRMap extends HTMLElement {
  constructor() {
    super();
    this.hasSetBoundary = false;
  }

  attributeChangedCallback() {
    if (!(this.latitude && this.longitude)) {
      return;
    }
    this.renderMap();
    this.renderPosition();
    if (!this.hasSetBoundary) {
      this.renderBoundary();
    }
  }

  get latitude() {
    return parseFloat(this.getAttribute('latitude'));
  }

  get longitude() {
    return parseFloat(this.getAttribute('longitude'));
  }

  static get observedAttributes() {
    return ['latitude', 'longitude'];
  }

  renderMapContainer() {
    let shadow = this.attachShadow({ mode: 'open' });
    let div = document.createElement('div');
    div.setAttribute('id', 'raceMap');
    div.setAttribute('class', 'map');
    div.setAttribute('style', 'height: 67vh; width: 80vw; margin: 0 auto; display: flex; align-items: center; justify-content: center; border-radius: $border-radius; z-index: 25;');
    shadow.innerHTML = '<link rel="stylesheet" href="https://unpkg.com/leaflet@1.4.0/dist/leaflet.css" integrity="sha512-puBpdR0798OZvTTbP4A8Ix/l+A4dHDD0DGqYW6RQ+9jxkRFclaxxQb/SJAWZfWAkuyeQUytO7+7N4QKrDh+drA=="crossorigin=""/>';
    shadow.appendChild(div);
  }

  renderMap() {
    const shadowDom = this.shadowRoot;
    if (!shadowDom) {
      this.renderMapContainer();
    }

    if (!this.map) {
      this.map = Leaflet.map(this.shadowRoot.querySelector('#raceMap'), {
        scrollWheelZoom: false,
        zoomControl: false,
        dragging: false,
        attributionControl: false
      });
    }

    if (!(this.latitude && this.longitude)) {
      this.map.setView(DEFAULT_CENTER, INITIAL_ZOOM);
    } else {
      this.map.setView([this.latitude, this.longitude], INITIAL_ZOOM);
    }
    this.map.addLayer(Leaflet.tileLayer(TILE_URL, { detectRetina: true }));
  }

  renderPosition() {
    if (!this.shadowRoot) {
      return;
    }
    if (this.positionMarker) {
      this.positionMarker.remove();
    }
    this.positionMarker = Leaflet.circle([this.latitude, this.longitude], {
      color: 'red',
      fillColor: '#f03',
      fillOpacity: 0.5,
      radius: 10
    });
    this.positionMarker.addTo(this.map);
  }

  renderBoundary() {
    if (!this.shadowRoot) {
      return;
    }
    const bounds = [
      [this.latitude - 0.001, this.longitude - 0.001],
      [this.latitude + 0.001, this.longitude + 0.001],
    ]
    this.boundaryMarker = Leaflet.rectangle(bounds, {
      color: 'blue',
      fillColor: '#41b1f2',
      fillOpacity: 0.2,
      stroke: false
    });
    this.boundaryMarker.addTo(this.map);
    this.hasSetBoundary = true;
  }

  connectedCallback() {
    this.renderMapContainer();
    this.renderMap();
  }
}

export default GRMap;
