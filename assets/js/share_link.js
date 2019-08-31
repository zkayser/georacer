
export const setupShareLinks = () => {
  const shareLink = document.querySelector('#share-link-btn');
  if (shareLink) {
    shareLink.addEventListener('click', (e) => {
      const link = shareLink.getAttribute('data-share-link');
      navigator.permissions.query({ name: "clipboard-write" }).then(result => {
        if (result.state == "granted" || result.state == "prompt") {
          navigator.clipboard.writeText(link);
        }
      });
      e.preventDefault();
    });
  }
}