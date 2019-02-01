// = require ./remaining_characters
// = require ./tab_focus
// = require ./multifield
// = require_self

$(() => {
  $("form.plans-form [data-remaining-characters]").remainingCharacters();
  $("form.plans-form .multifield-fields").multifield();
});
