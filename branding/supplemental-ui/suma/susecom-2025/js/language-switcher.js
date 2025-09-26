// Find all alternate hreflang link elements
const hreflangLinks = document.querySelectorAll('link[rel="alternate"]');

const hreflangToLangMapping = {
  "en-us": "en",
  "de-de": "de",
  "fr-fr": "fr",
  "es-es": "es",
  "ja-jp": "ja",
  "pt-br": "pt_BR",
  "zh-cn": "zh_CN",
  "ko-kr": "ko_KR",
};

// Create an object to hold the languages
const languages = {};

hreflangLinks.forEach((link) => {
  const hreflang = link.getAttribute("hreflang");
  const href = link.getAttribute("href");

  if (hreflang && hreflang !== "x-default") {
    let label;
    switch (hreflang.toLowerCase()) {
      case "en-us":
        label = "English";
        break;
      case "de-de":
        label = "Deutsch";
        break;
      case "fr-fr":
        label = "Français";
        break;
      case "es-es":
        label = "Español";
        break;
      case "zh-cn":
        label = "中文";
        break;
      case "ja-jp":
        label = "日本語";
        break;
      case "ko-kr":
        label = "한국어";
        break;
      case "pt-br":
        label = "Português Brasileiro";
        break;
    }

    let lang = hreflangToLangMapping[hreflang.toLowerCase()];
    languages[lang] = {
      label: label,
      url: href,
    };
  }
});

// Get the current language
const currentLang = document.documentElement.lang || "en";

// Update the <shared-header> element
const sharedHeader = document.querySelector("shared-header");
if (sharedHeader) {
  sharedHeader.setAttribute("language", currentLang);
  sharedHeader.setAttribute("languages", JSON.stringify(languages));
}