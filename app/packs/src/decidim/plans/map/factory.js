import PlansMapController from "src/decidim/plans/map/controller/plans";
import PlanFormMapController from "src/decidim/plans/map/controller/plan_form";

const createMapController = (mapId, config) => {
  if (config.type === "plan-form") {
    return new PlanFormMapController(mapId, config);
  }

  return new PlansMapController(mapId, config);
}

window.Decidim.createMapController = createMapController;
