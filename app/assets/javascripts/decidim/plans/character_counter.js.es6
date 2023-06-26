((exports) => {
  const DEFAULT_MESSAGES = {
    charactersUsed: "%count%/%total% characters used",
    charactersMin: "(at least %count characters required)"
  };
  const DEFAULT_OPTIONS = {
    messages: DEFAULT_MESSAGES
  };
  let OPTIONS = DEFAULT_OPTIONS;

  class Options {
    static configure(options) {
      OPTIONS = $.extend(DEFAULT_OPTIONS, options);
    }

    static getMessage(message) {
      return OPTIONS.messages[message];
    }
  }

  class InputCharacterCounter {
    constructor(input, counterElement) {
      this.$input = input;
      this.$target = counterElement;
      this.minCharacters = parseInt(this.$input.attr("minlength"), 10);
      this.maxCharacters = parseInt(this.$input.attr("maxlength"), 10);

      if (this.maxCharacters > 0 || this.minCharacters > 0) {
        this.bindEvents();
      }
    }

    bindEvents() {
      this.$input.on("keyup", () => {
        this.updateStatus();
      });
      this.updateStatus();
    }

    updateStatus() {
      const numCharacters = this.$input.val().length;
      const showMessages = [];

      if (this.maxCharacters > 0) {
        let message = Options.getMessage("charactersUsed");

        showMessages.push(
          message.replace(
            "%count%",
            numCharacters
          ).replace(
            "%total%",
            this.maxCharacters
          )
        );
      }
      if (this.minCharacters > 0 && this.minCharacters > numCharacters) {
        let message = Options.getMessage("charactersMin");

        showMessages.push(
          message.replace(
            "%count%",
            this.minCharacters
          )
        );
      }
      this.$target.html(showMessages.join("<br>"));
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.DecidimPlansCharacters = exports.DecidimPlansCharacters || {};

  exports.DecidimPlansCharacters.configure = (options) => {
    Options.configure(options);
  };

  exports.DecidimPlansCharacters.bindCharacterCounter = ($input, $message) => {
    const counter = new InputCharacterCounter($input, $message);
    $input.data("characters-counter", counter)
  };
})(window)
