import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="read-more"
export default class extends Controller {
  static targets = ["textToHide", "showMoreButton"]
  static values = {
    maxHeight: { type: Number, default: 200 },
  }

  connect() {
    this.#setupButton();
    this.#spoilerText();
  }

  showMore() {
    this.#unspoilerText();
    this.#hideButton();
  }

  #setupButton() {
    if (this.#isSpoilerNeeded()) {
      this.#showButton();
    } else {
      this.#hideButton();
    }
  }

  #spoilerText() {
    if (this.#isSpoilerNeeded()) {
      this.textToHideTarget.style.overflow = 'hidden';
      this.textToHideTarget.style.height = `${this.maxHeightValue}px`;
    }
  }

  #unspoilerText() {
    this.textToHideTarget.style.height = null;
  }

  #hideButton() {
    this.showMoreButtonTarget.remove();
  }

  #showButton() {
    this.showMoreButtonTarget.hidden = false;
  }

  #isSpoilerNeeded() {
    const textHeight = this.textToHideTarget.offsetHeight;
    return textHeight > this.maxHeightValue;
  }
}