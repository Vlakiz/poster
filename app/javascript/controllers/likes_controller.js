import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="likes"
export default class extends Controller {
  static targets = ["likeButton", "likeCount"]
  static values = {
    isLiked: { type: Boolean, default: false },
    isAuthorized: { type: Boolean, default: false },
    collectionName: String,
    resourceId: Number
  }

  connect() {
    this.#refreshHeart();
  }

  like() {
    if (!this.isAuthorizedValue || this.#isLiking()) return;

    this.isLikedValue = !this.isLikedValue;
    this.#refreshHeart();
    if (this.isLikedValue) {
      this.likeCountTarget.textContent = +this.likeCountTarget.textContent + 1
      this.#setLiking();
    } else {
      this.likeCountTarget.textContent = +this.likeCountTarget.textContent - 1
    }

    fetch(`/${this.collectionNameValue}/${this.resourceIdValue}/like`, {
      method: this.isLikedValue == false ? 'DELETE' : 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
      }
    });
  }

  #setLiking() {
    this.likeButtonTarget.classList.add('liking');

    setTimeout(() => {
      this.likeButtonTarget.classList.remove('liking');
    }, 200);
  }

  #isLiking() {
    this.likeButtonTarget.classList.contains('liking');
  }

  #refreshHeart() {
    if (this.isLikedValue === true) {
      this.#fillHeart();
    } else {
      this.#unfillHeart();
    }
  }

  #fillHeart() {
      this.likeButtonTarget.classList.add('bi-heart-fill');
      this.likeButtonTarget.classList.remove('bi-heart');
  }

  #unfillHeart() {
      this.likeButtonTarget.classList.add('bi-heart');
      this.likeButtonTarget.classList.remove('bi-heart-fill');
  }
}
