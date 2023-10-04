const currentAllocationZero = () => {
  const $budgetSummary = $(".budget-summary__progressbox");
  return parseInt($budgetSummary.attr("data-current-allocation"), 10) === 0;
}

const isSafeUrl = (exitUrl) => {
  if (!exitUrl) {
    return false
  }

  const safeUrls = [];

  let safe = false;
  safeUrls.forEach((url) => {
    if (exitUrl.startsWith(url)) {
      safe =  true
    }
  });

  return safe;
}

const allowExitFrom = ($el) => {
  if (currentAllocationZero()) {
    return true
  } else if ($el.attr("target") === "_blank") {
    return true;
  } else if ($el.hasClass("info-modal-link")) {
    return true;
  } else if ($el.attr("id") === "exit-notification-link") {
    return true;
  } else if ($el.parents("[data-reveal]").length > 0) {
    return true;
  } else if (isSafeUrl($el.attr("href"))) {
    return true
  }

  return false;
}

$(() => {
  const $exitNotification = $("#exit-notification");
  const $exitLink = $("#exit-notification-link");
  const defaultExitUrl = $exitLink.attr("href");
  const defaultExitLinkText = $exitLink.text();
  let exitLinkText = defaultExitLinkText;
  let formChanged = false;

  if ($exitNotification.length < 1) {
    // Do not apply when not inside the voting pipeline
    return;
  }

  const openExitNotification = (url, method = null) => {
    if (method && method !== "get") {
      $exitLink.attr("data-method", method);
    } else {
      $exitLink.removeAttr("data-method");
    }

    $exitLink.attr("href", url);
    $exitLink.html(exitLinkText);
    $exitNotification.foundation("open");
  };

  $(document).on("click", "a", (event) => {
    exitLinkText = defaultExitLinkText;

    const $link = $(event.currentTarget);
    if (formChanged && !allowExitFrom($link)) {
      event.preventDefault();
      openExitNotification($link.attr("href"), $link.data("method"));
    }
  });

  $("input, textarea, select", ".plans-form").on("change", () => {
    formChanged = true;
  });

  // Custom handling for the header sign out so that it won't trigger the
  // logout form submit and so that it changes the exit link text. This does
  // not trigger the document link click listener because it has the
  // data-method attribute to trigger a form submit event.
  $(".header a.sign-out-link").on("click", (event) => {
    event.preventDefault();
    event.stopPropagation();

    const $link = $(event.currentTarget);
    exitLinkText = $link.text();
    openExitNotification($link.attr("href"), $link.data("method"));
  });
});
