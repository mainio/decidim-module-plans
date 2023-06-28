((exports) => {
  // const L = exports.L; // eslint-disable-line

  exports.Decidim = exports.Decidim || {};

  const MapMarkersController = exports.Decidim.MapMarkersController;

  class PlansMapController extends MapMarkersController {
    start() {
      this.markerClusters = null;

      if (Array.isArray(this.config.markers) && this.config.markers.length > 0) {
        this.addMarkers(this.config.markers);

        if (this.config.markers.length < 10) {
          this.map.setZoom(10);
        }
      } else if (this.config.centerCoordinates) {
        this.map.panTo(this.config.centerCoordinates);
        this.map.setZoom(10);
      } else {
        this.map.fitWorld();
        this.map.panTo([0, 0]);
        this.map.setZoom(1)
      }
    }
  }

  exports.Decidim.PlansMapController = PlansMapController;
})(window);
