((exports) => {
  const $ = exports.$; // eslint-disable-line

  $(() => {
    const $form = $("form.export_plans_to_budgets");
    const $componentSelect = $("#budgets_export_target_component_id", $form);

    $componentSelect.on("change.decidim-plans init.decidim-plans", () => {
      const selectedComponent = $componentSelect.val();

      $(".target-details-fields").each((_i, details) => {
        const $details = $(details);
        $details.addClass("hide");
        $("select", $details).removeAttr("required");
      });

      const $targetDetails = $(`.target-details-fields[data-component-id="${selectedComponent}"]`);
      $("select", $targetDetails).attr("required", "required");
      $targetDetails.removeClass("hide");
    }).trigger("init.decidim-plans");
  });
})(window);
