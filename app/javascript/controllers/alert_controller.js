import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.hideAlert();
    }, 6000);
  }

  hideAlert() {
    this.element.style.transition = 'opacity 0.5s ease-out';
    this.element.style.opacity = '0';
    setTimeout(() => {
      this.element.remove();
    }, 500);
  }
}
