((exports) => {
  class InfoModal {
    constructor() {
      this.modal = $("#plans_info-modal");
      if (this.modal.length < 1) {
        this.modal = this._createModalContainer();
        this.modal.appendTo($("body"));
        this.modal.foundation();
      }
    }

    show(url) {
      $.ajax({url: url, dataType: "json"}).done((resp) => {
        let modalContent = $(".plans_info-modal-content", this.modal);
        modalContent.html(this._generateContent(resp));
        this.modal.foundation("open");
      });
    }

    _generateContent(data) {
      const $content = $("<div></div>");

      if (data.text) {
        $content.append(data.text);
      }

      return $content;
    }

    _createModalContainer() {
      return $(`
        <div class="small reveal" id="plans_info-modal" aria-hidden="true" aria-live="assertive" role="dialog" data-reveal data-multiple-opened="true">
          <div class="plans_info-modal-content"></div>
          <button class="close-button" data-close type="button" data-reveal-id="plans_info-modal"><span aria-hidden="true">&times;</span></button>
        </div>
      `);
    }
  }

  const bindInfoModalLinks = () => {
    const modal = new InfoModal();

    const $links = exports.$(".info-modal-link")
    $links.off("click.decidim-plans-info-modal")
    $links.on("click.decidim-plans-info-modal", (ev) => {
      ev.preventDefault();

      let $link = $(ev.target);
      if (!$link.is("a")) {
        $link = $link.closest("a")
      }
      modal.show($link.attr("href"));
    });
  }

  exports.$(() => {
    bindInfoModalLinks();
  });
})(window);
