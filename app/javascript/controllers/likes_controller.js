import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="likes"
export default class extends Controller {
  static targets = ["likeButton", "likeCount"]
  static values = {
    isLiked: { type: Boolean, default: false },
    postId: Number,
  }

  connect() {
    this.#refreshHeart();
  }

  like() {
    fetch(`/posts/${this.postIdValue}/like`, {
      method: this.isLikedValue == true ? 'DELETE' : 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
      }
    })
      .then(response => response.json())
      .then(data => {
        this.likeCountTarget.textContent = data.likesCount;
        this.isLikedValue = !this.isLikedValue;
        this.#refreshHeart();
      });
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
