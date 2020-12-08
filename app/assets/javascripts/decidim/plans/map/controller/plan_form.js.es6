((exports) => {
  const L = exports.L; // eslint-disable-line

  exports.Decidim = exports.Decidim || {};

  const MapController = exports.Decidim.MapController;

  class PlanFormMapController extends MapController {
    start() {
      this.eventHandlers = {};
      this.marker = null;

      const zoom = parseInt(this.config.zoom, 10) || 11;

      if (this.config.centerCoordinates) {
        this.map.setView(this.config.centerCoordinates, zoom);
      } else {
        this.map.setZoom(zoom);
      }

      this.map.on("click", (ev) => {
        this.addOrMoveMarker(ev.latlng.lat, ev.latlng.lng);
        this.triggerEvent("coordinates", [ev.latlng]);
      });
    }

    triggerEvent(eventName, payload) {
      const handler = this.eventHandlers[eventName];
      if (typeof handler === "function") {
        return Reflect.apply(handler, this, payload);
      }
      return null;
    }

    setEventHandler(name, callback) {
      this.eventHandlers[name] = callback;
    }

    getMarker() {
      return this.marker;
    }

    addOrMoveMarker(latitude, longitude) {
      if (this.marker) {
        this.marker.setLatLng([latitude, longitude]);
      } else {
        this.marker = L.marker([latitude, longitude], {
          icon: this.createIcon(),
          draggable: true
        }).addTo(this.map);

        this.marker.on("move", (ev) => {
          this.triggerEvent("specify", [ev.latlng]);
        });
      }

      return this.marker;
    }

    createIcon() {
      return new L.DivIcon.SVGIcon.DecidimIcon({
        fillColor: this.config.markerColor,
        iconSize: L.point(28, 36)
      });
    }

    removeMarker() {
      if (this.marker) {
        this.marker.remove();
        this.marker = null;
      }
    }

    receiveCoordinates(latitude, longitude) {
      this.map.panTo([latitude, longitude]);
      return this.addOrMoveMarker(latitude, longitude);
    }
  }

  exports.Decidim.PlanFormMapController = PlanFormMapController;
})(window);
