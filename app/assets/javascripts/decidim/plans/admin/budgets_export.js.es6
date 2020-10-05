((exports) => {
  const $ = exports.$; // eslint-disable-line

  $(() => {
    const $form = $("form.export_plans_to_budgets");
    const $componentSelect = $("#budgets_export_target_component_id", $form);

    $componentSelect.on("change.decidim-plans init.decidim-plans", () => {
      const selectedComponent = $componentSelect.val();

      $(".target-details-fields").addClass("hide");
      $(`.target-details-fields[data-component-id="${selectedComponent}"]`).removeClass("hide");
    }).trigger("init.decidim-plans");
  });
})(window);
