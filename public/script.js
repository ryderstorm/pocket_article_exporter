const copyTokenBtn = document.querySelector("#copy-token-btn");
if (copyTokenBtn) {
  tippy(copyTokenBtn, { content: "Copy access token to clipboard" });
  copyTokenBtn.addEventListener("click", () => {
    navigator.clipboard.writeText("<%= access_token %>").then(() => {
      const copiedTooltip = tippy(copyTokenBtn, { content: "Copied!" });
      copiedTooltip.show();
      setTimeout(() => {
        copiedTooltip.hide();
        setTimeout(() => {
          copiedTooltip.destroy();
        }, 500);
      }, 1500);
    });
  });
}
const fetchArticlesBtn = document.querySelector("#fetch-articles-btn");
if (fetchArticlesBtn) {
  fetchArticlesBtn.addEventListener("click", () => {
    const modal = document.querySelector("#modal");
    modal.querySelector("p").textContent =
      "Fetching the articles from the Pocket API could take a few minutes. Please wait...";
    modal.style.display = "flex";
  });
}
const manualAuthBtn = document.querySelector("#manual-auth-btn");
if (manualAuthBtn) {
  manualAuthBtn.addEventListener("click", () => {
    startManualAuth();
  });
}
function startManualAuth() {
  console.log("Start manual auth");
  const manualAuthForm = document.querySelector("#manual-auth-form");
  manualAuthForm.style.display = "flex";
  document.querySelectorAll(".auth-buttons").forEach((el) => {
    el.style.display = "none";
  });
}
