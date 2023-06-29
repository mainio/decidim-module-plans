((exports) => {
  const bindResetInputs = () => {
    exports.$(".reset-input").on("click.decidim-plans-form", (ev) => {
      ev.preventDefault();

      let $target = $($(ev.target).data("target"));
      if ($target.length < 1 && (/^#/).test($target.attr("href")) && $target.attr("href").length > 1) {
        $target = $($(ev.target).data("target"));
      }
      if ($target.length < 1) {
        return;
      }

      let $input = $target;
      if (!$target.is("input, textarea, select")) {
        $input = $("input, textarea, select", $target).first();
      }
      if ($input.length < 1) {
        return;
      }

      $input.val("").trigger("change");
    });
  }

  exports.$(() => {
    bindResetInputs();
  });
})(window);
