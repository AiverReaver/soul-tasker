/**
 * The web page Google Play asks for: delete an account without the app
 * (Stage 7 plan D17). Google Identity Services signs the person in and hands
 * the page a fresh ID token, which is POSTed in the body with a confirm. No
 * cookie and no server session, so there is nothing ambient to forge.
 */
export const deletePage = (clientId: string) => `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Delete your Hearthrise account</title>
<style>
  body { font: 18px/1.5 system-ui, sans-serif; max-width: 34rem; margin: 2rem auto; padding: 0 1rem; color: #1b1b1b; }
  h1 { font-size: 1.5rem; }
  button { font: inherit; padding: 0.75rem 1.25rem; min-height: 48px; }
  #status { margin-top: 1rem; }
</style>
</head>
<body>
<h1>Delete your Hearthrise account</h1>
<p>This removes your account and everything backed up to it: bosses, tasks, attempts, lessons, relics and settings. Data on your phone is not touched. This cannot be undone.</p>
<p>Sign in with the Google account you used in the app to confirm it is you.</p>
<div id="signin"></div>
<div id="confirm" hidden>
  <p>Signed in. Delete the account and everything backed up to it?</p>
  <button id="delete" type="button">Delete my account</button>
</div>
<p id="status" role="status"></p>
<script src="https://accounts.google.com/gsi/client" async defer></script>
<script>
  let idToken = null;
  const status = document.getElementById('status');
  window.onload = function () {
    google.accounts.id.initialize({
      client_id: ${JSON.stringify(clientId)},
      callback: function (response) {
        idToken = response.credential;
        document.getElementById('signin').hidden = true;
        document.getElementById('confirm').hidden = false;
      },
    });
    google.accounts.id.renderButton(document.getElementById('signin'), { theme: 'outline', size: 'large' });
  };
  document.getElementById('delete').addEventListener('click', async function () {
    status.textContent = 'Deleting...';
    try {
      const res = await fetch('/account/delete', {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ idToken: idToken, confirm: true }),
      });
      if (res.ok) {
        const body = await res.json();
        status.textContent = body.deleted
          ? 'Your account and its backed up data are deleted.'
          : 'There is no account for this Google sign-in. Nothing was deleted.';
        document.getElementById('confirm').hidden = true;
      } else {
        status.textContent = 'Sign-in expired. Please sign in again.';
        document.getElementById('confirm').hidden = true;
        document.getElementById('signin').hidden = false;
      }
    } catch (e) {
      status.textContent = 'Could not reach the server. Try again.';
    }
  });
</script>
</body>
</html>
`;
