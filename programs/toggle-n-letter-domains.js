/**
 * In Google Domains, one can choose which domains the interface should
 * show when you are searching. This micro-script allows you to filter
 * your desired domains by the number of letters.
 *
 * In other words, running this in Google Domain with the side bar
 * opened will allow you to toggle all domains that should be shown,
 * based on the number of characters that it has:
 *
 * Ex:
 *  - 3 letters: .CO, .CC
 *  - 4 letters: .COM, .APP, .DEV
 *  - etc
 */
function toggleNLetterDomains(n) {
  // For some reason, we need this adjustment: 3 letter domains show as `length === 5`.
  const realNumberOfDomainLetters = n + 2;
  
  Array.from(document
             .querySelectorAll("xap-picker-option")
             .entries())
    // x[1] is the actual HTML element.
    .filter(x => x[1].innerText.length === realNumberOfDomainLetters)
    // Clicking on it toggles the element.
    .map(x => x[1].click())
}
