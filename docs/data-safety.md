# Play Console: Data safety draft (Stage 7)

Answers to enter under App content, Data safety. Review against the final build before submitting. The privacy policy URL and the account deletion URL are entered separately (Stage 7 plan step 12).

## Does the app collect or share user data?

Collects: yes, only when the user signs in (optional). Shares: no.

## Data types collected

| Section | Type | Collected | Shared | Required or optional | Purpose |
|---|---|---|---|---|---|
| Personal info | Email address | Yes | No | Optional (only with an account) | Account management |
| Personal info | User IDs (Google account id) | Yes | No | Optional | Account management |
| App activity | Other user-generated content (bosses, tasks, lessons, inscriptions) | Yes | No | Optional | App functionality (backup and sync) |

Not collected: location, financial info, health and fitness, messages, photos and videos, audio, files, contacts, calendar, web browsing, device or other IDs, crash logs or diagnostics, advertising data.

## Security practices

- Data is encrypted in transit: yes (HTTPS only; the app allows no cleartext traffic).
- Users can request that data is deleted: yes, in the app (Settings, "Delete account") and on the web page entered as the deletion URL.
- Independent security review: no.
- Follows the Families policy: no (adults only).

## Notes for the form

- "Optional" because the whole app works with no account and makes no network request before sign-in.
- Tester signals and the tester report stay on the phone and are not collected.
- Google Sign-In is Google's own SDK; Google's handling is covered by Google's policy.
