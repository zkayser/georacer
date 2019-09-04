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
import Hooks from './hooks/hooks';
import { setupShareLinks } from './share_link';
import GRMap from './grMap';

customElements.define('gr-map', GRMap);

setupShareLinks();
let liveSocket = new LiveSocket("/live", { hooks: Hooks });
liveSocket.connect();
