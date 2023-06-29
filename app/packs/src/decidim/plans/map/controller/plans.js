import MapMarkersController from "src/decidim/map/controller/markers";

export default class PlansMapController extends MapMarkersController {
  start() {
    this.markerClusters = null;

    if (Array.isArray(this.config.markers) && this.config.markers.length > 0) {
      this.addMarkers(this.config.markers);

      if (this.config.markers.length < 10) {
        this.map.setZoom(10);
      }
    } else {
      this.map.fitWorld();

      if (this.config.centerCoordinates) {
        this.map.setZoom(10);
        this.map.panTo(this.config.centerCoordinates);
      } else {
        this.map.setZoom(1);
        this.map.panTo([0, 0]);
      }
    }
  }
}
