import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="textarea-auto-resize"
export default class extends Controller {
  static targets = ["textarea"]

  connect() {
    this.resize();
  }

  resize() {
    if (this.textareaTarget.scrollHeight > 400) {
      return;
    }

    this.textareaTarget.style.height = 'auto';
    this.textareaTarget.style.height = this.textareaTarget.scrollHeight + 'px';
  }
}
