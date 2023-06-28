import "src/decidim/plans/map/controller/plans";
import "src/decidim/plans/map/controller/plan_form";

((exports) => {
  exports.Decidim = exports.Decidim || {};

  // const coreCreateMapController = exports.Decidim.createMapController;
  const PlansMapController = exports.Decidim.PlansMapController;
  const PlanFormMapController = exports.Decidim.PlanFormMapController;

  const createMapController = (mapId, config) => {
    if (config.type === "plan-form") {
      return new PlanFormMapController(mapId, config);
    }

    return new PlansMapController(mapId, config);
  }

  exports.Decidim.createMapController = createMapController;
})(window);
