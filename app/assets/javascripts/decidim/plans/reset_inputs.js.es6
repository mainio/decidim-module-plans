((exports) => {
  const bindResetInputs = () => {
    exports.$(".reset-input").on("click.decidim-ideas-form", (ev) => {
      ev.preventDefault();

      let $target = $($(ev.target).data("target"));
      if ($target.length < 1 && (/^#/).test($target.attr("href")) && $target.attr("href").length > 1) {
        $target = $($(ev.target).data("target"));
      }
      if ($target.length < 1) {
        return;
      }

      $target.val("").trigger("change");
    });
  }

  exports.$(() => {
    bindResetInputs();
  });
})(window);
