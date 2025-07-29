import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="turbo-frame"
export default class extends Controller {
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
  
  makeSpinner(event) {
    const isButton = event.currentTarget.classList.contains('btn');
    const spinner = document.createElement('div');
    spinner.className = `spinner-border ${isButton ? 'mx-2 text-secondary' : 'spinner-border-sm'}`;
    spinner.role = 'status'

    event.currentTarget.classList.add('d-none');
    event.currentTarget.after(spinner);
  }
}
