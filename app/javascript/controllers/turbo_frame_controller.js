import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="turbo-frame"
export default class extends Controller {
  static targets = ["spinner", "content"]
  static values = {
    minHeight: { type: Number, default: 0 },
    preserveHeight: { type: Boolean, default: false }
  }

  connect() {
    this.element.addEventListener('turbo:before-prefetch', this.disablePreFetchEvent);
    this.element.addEventListener('turbo:before-fetch-request', this.replaceBySpinner.bind(this));
    this.preserveHeightValue && this.element.addEventListener('turbo:before-frame-render', this.returnHeight.bind(this));
  }

  disconnect() {
    this.element.removeEventListener('turbo:before-prefetch', this.disablePreFetchEvent);
    this.element.removeEventListener('turbo:before-fetch-request', this.disableAllInnerLinks);
  }

  replaceBySpinner(event) {
    const fetchFrameId = event.detail.fetchOptions?.headers?.["Turbo-Frame"]
    if (fetchFrameId !== event.currentTarget.id) return;

    const spinner = document.createElement('div');
    spinner.role = 'status';
    spinner.className = 'spinner-border text-danger';

    const spinnerWrap = document.createElement('div');
    spinnerWrap.className = 'text-center';
    spinnerWrap.appendChild(spinner);

    const target = this.hasSpinnerTarget ? this.spinnerTarget : event.currentTarget;

    const savedHeight = target.offsetHeight;
    target.innerHTML = '';

    if (this.preserveHeightValue) {
      target.style.height = `${Math.max(savedHeight, this.minHeightValue)}px`;
      target.classList.add('bg-blink-light', 'd-flex', 'align-items-center', 'justify-content-center', 'rounded-5');
    }

    target.appendChild(spinnerWrap);
  }

  returnHeight(event) {
    event.stopPropagation();
    const target = this.hasSpinnerTarget ? this.spinnerTarget : event.target;
    target.style.height = null;
    target.classList.remove('bg-blink-light', 'd-flex', 'align-items-center', 'justify-content-center', 'rounded-5');
  }

  disablePreFetchEvent(event) {
    event.preventDefault();
  }

  clearFrame(event) {
    event.preventDefault();
    this.contentTarget.innerHTML = '';
  }
}
