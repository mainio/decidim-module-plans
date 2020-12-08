((exports) => {
  const $ = exports.$; // eslint-disable-line

  $(() => {
    const $form = $("form.new_filter");

    $form.on("reset.ideas", () => {
      $('input[type="search"]').trigger("change");
    });
  });
})(window);
