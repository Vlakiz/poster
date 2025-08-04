import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="turbo-frame"
export default class extends Controller {
  static targets = ["spinner"]

  connect() {
    this.element.addEventListener('turbo:before-prefetch', this.disablePreFetchEvent);
    this.element.addEventListener('turbo:before-fetch-request', this.disableAllInnerLinks);
  }

  disconnect() {
    this.element.removeEventListener('turbo:before-prefetch', this.disablePreFetchEvent);
    this.element.removeEventListener('turbo:before-fetch-request', this.disableAllInnerLinks);
  }

  disableAllInnerLinks(event) {
    event.target.querySelectorAll('input[type=submit]').forEach((element) => {
      element.disabled = true;
    });
  }

  disablePreFetchEvent(event) {
    event.preventDefault();
  }
  
  addSpinnerToLink(event) {
    const spinner = document.createElement('div');
    spinner.role = 'status';

    const isButton = event.currentTarget.classList.contains('btn');
    spinner.className = `spinner-border ${isButton ? 'mx-2 text-secondary' : 'spinner-border-sm'}`;

    event.currentTarget.classList.add('d-none');
    event.currentTarget.after(spinner);
  }

  replaceBySpinner(_event) {
    const spinner = document.createElement('div');
    spinner.role = 'status';spinner.className = 'spinner-border text-danger';

    const spinnerWrap = document.createElement('div');
    spinnerWrap.className = 'text-center';
    spinnerWrap.appendChild(spinner);

    this.spinnerTarget.classList.add('d-none');
    this.spinnerTarget.after(spinnerWrap);
  }
}
