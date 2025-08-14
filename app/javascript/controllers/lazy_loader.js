import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["link"]

    connect() {
        this.#connectObserver();
    }

    #connectObserver() {
        const options = {
            threshold: null,
            rootMargin: "0px",
        }

        const observer = new IntersectionObserver((entries, observer) => {
            entries.forEach((entry) => {
                if (entry.isIntersecting) {
                    this.#followLink();

                    observer.unobserve(entry.target);
                }
            });
        }, options)

        observer.observe(this.element);
    }

    #followLink() {
        this.linkTarget.click();
    }
}