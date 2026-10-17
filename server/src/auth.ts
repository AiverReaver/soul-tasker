import { createHash, randomBytes } from 'node:crypto';
import { createRemoteJWKSet, jwtVerify } from 'jose';
import type { JWTVerifyGetKey } from 'jose';

/** Google signs ID tokens with either issuer string. */
export const GOOGLE_ISSUERS = ['https://accounts.google.com', 'accounts.google.com'];

/** A session lasts this long and is renewed on every use (D4). */
export const SESSION_DAYS = 60;

/** Google's live signing keys, fetched and cached by jose. */
export const googleJwks = (): JWTVerifyGetKey =>
  createRemoteJWKSet(new URL('https://www.googleapis.com/oauth2/v3/certs'));

export type GoogleIdentity = { sub: string; email: string; issuedAt: Date };

/**
 * Checks a Google ID token: signature, audience, issuer, expiry and a
 * verified email. Returns null for any failure, so callers answer 401.
 */
export async function verifyGoogleIdToken(
  idToken: string,
  opts: { jwks: JWTVerifyGetKey; audience: string; now: Date },
): Promise<GoogleIdentity | null> {
  try {
    const { payload } = await jwtVerify(idToken, opts.jwks, {
      audience: opts.audience,
      issuer: GOOGLE_ISSUERS,
      algorithms: ['RS256'],
      currentDate: opts.now,
      requiredClaims: ['sub', 'exp', 'iat'],
    });
    if (!payload.sub || typeof payload.email !== 'string') return null;
    if (payload.email_verified !== true) return null;
    return { sub: payload.sub, email: payload.email, issuedAt: new Date(payload.iat! * 1000) };
  } catch {
    return null;
  }
}

/** 32 random bytes, sent once to the phone and never stored. */
export const newSessionToken = () => randomBytes(32).toString('base64url');

export const hashToken = (token: string) => createHash('sha256').update(token).digest();

export const sessionExpiry = (now: Date) => new Date(now.getTime() + SESSION_DAYS * 86_400_000);
