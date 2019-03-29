/**
 * Extends / overrides:
 * decidim/admin/dynamic_fields.component
 *
 * Fixes broken attachments in IE11 by overriding the `_addField` method in the
 *`DynamicFieldsComponent` coming from the `decidim-admin` component.
 *
 * For further details, see:
 * https://github.com/mainio/decidim-module-plans/issues/13
**/

((exports) => {
  const { DynamicFieldsComponent } = exports.DecidimAdmin;

  class DynamicFieldsComponentExtended extends DynamicFieldsComponent {
    _addField() {
      const $container = $(this.wrapperSelector).find(this.containerSelector);
      // START OVERRIDE
      const $template = $(this.wrapperSelector).children(".decidim-template");
      // END OVERRIDE
      const $newField = $($template.html()).template(this.placeholderId, this._getUID());

      $newField.find("ul.tabs").attr("data-tabs", true);

      $newField.appendTo($container);
      $newField.foundation();

      if (this.onAddField) {
        this.onAddField($newField);
      }
    }
  }

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.DynamicFieldsComponent = DynamicFieldsComponentExtended;
  exports.DecidimAdmin.createDynamicFields = (options) => {
    return new DynamicFieldsComponentExtended(options);
  };
})(window);
