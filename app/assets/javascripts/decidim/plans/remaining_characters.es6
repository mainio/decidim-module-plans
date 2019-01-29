$(function() {
  const COUNT_KEY = "%count%";

  $.fn.remainingCharacters = function() {
    return $(this).each(

      /**
       * @this HTMLElement
       * @returns {void}
       */
      function() {
        const $input = $(this);
        const $target = $($input.data("remaining-characters"));
        const maxCharacters = parseInt($(this).attr("maxlength"), 10);

        if ($target.length > 0 && maxCharacters > 0) {
          const messagesJson = $input.data("remaining-characters-messages");
          const messages = $.extend({
            one: `${COUNT_KEY} character left`,
            many: `${COUNT_KEY} characters left`
          }, messagesJson);

          const updateStatus = function() {
            const numCharacters = $input.val().length;
            const remaining = maxCharacters - numCharacters;
            let message = messages.many;
            if (remaining === 1) {
              message = messages.one;
            }

            $target.text(message.replace(COUNT_KEY, remaining));
          };

          $input.on("keyup focus", function() {
            updateStatus();
          });
          updateStatus();
        }
      }
    );
  };
});
