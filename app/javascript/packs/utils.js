export function getCurrentUserId() {
  const meta = document.querySelector('meta[name="current-user-id"]');
  return meta ? parseInt(meta.content, 10) : null;
}
