// = require_self

/**
 * When switching tabs in i18n fields, autofocus on the input to save clicks
 *
 * Similar to:
 * decidim-admin/app/assets/javascripts/decidim/admin/tab_focus.js.es6
 */
$(() => {
  // Event launched by foundation
  $("[data-tabs]").on("change.zf.tabs", (event) => {
    const $container = $(event.target).parent().next(".tabs-content");
    const $panel = $(".tabs-panel.is-active", $container);

    const $content = $("input, textarea", $panel).first();
    if ($content.length > 0) {
      $content.focus();
    }
  });
});
