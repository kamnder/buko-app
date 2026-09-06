const encoder = new TextEncoder();
const decoder = new TextDecoder();
const PBKDF2_ITERATIONS = 60000;
const TOKEN_TTL_SECONDS = 3600;

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'cache-control': 'no-store',
      'access-control-allow-origin': '*',
      'access-control-allow-headers': 'content-type',
      'access-control-allow-methods': 'POST, OPTIONS',
    },
  });
}

function normalizePhone(value) {
  let p = String(value ?? '').trim().replace(/[^0-9+]/g, '');
  if (p.startsWith('00249')) p = `+${p.slice(2)}`;
  if (p.startsWith('249')) p = `+${p}`;
  if (p.startsWith('0') && p.length === 10) p = `+249${p.slice(1)}`;
  if (!/^\+249\d{9}$/.test(p)) throw new Error('invalid-phone');
  return p;
}

function b64url(bytes) {
  let binary = '';
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/g, '');
}

function b64urlDecode(text) {
  const padded = text.replace(/-/g, '+').replace(/_/g, '/') + '==='.slice((text.length + 3) % 4);
  const binary = atob(padded);
  return Uint8Array.from(binary, c => c.charCodeAt(0));
}

function randomBytes(length) {
  const bytes = new Uint8Array(length);
  crypto.getRandomValues(bytes);
  return bytes;
}

async function hashPassword(password, saltBytes) {
  const baseKey = await crypto.subtle.importKey('raw', encoder.encode(password), 'PBKDF2', false, ['deriveBits']);
  const bits = await crypto.subtle.deriveBits(
    { name: 'PBKDF2', salt: saltBytes, iterations: PBKDF2_ITERATIONS, hash: 'SHA-256' },
    baseKey,
    256,
  );
  return new Uint8Array(bits);
}

async function encodePassword(password) {
  const salt = randomBytes(16);
  const hash = await hashPassword(password, salt);
  return `pbkdf2$${PBKDF2_ITERATIONS}$${b64url(salt)}$${b64url(hash)}`;
}

async function verifyPassword(password, stored) {
  const parts = String(stored).split('$');
  if (parts.length !== 4 || parts[0] !== 'pbkdf2') return false;
  const iterations = Number(parts[1]);
  if (!Number.isInteger(iterations) || iterations < 10000 || iterations > 500000) return false;
  const salt = b64urlDecode(parts[2]);
  const expected = b64urlDecode(parts[3]);
  const baseKey = await crypto.subtle.importKey('raw', encoder.encode(password), 'PBKDF2', false, ['deriveBits']);
  const bits = await crypto.subtle.deriveBits(
    { name: 'PBKDF2', salt, iterations, hash: 'SHA-256' },
    baseKey,
    expected.length * 8,
  );
  const actual = new Uint8Array(bits);
  if (actual.length !== expected.length) return false;
  let diff = 0;
  for (let i = 0; i < actual.length; i++) diff |= actual[i] ^ expected[i];
  return diff === 0;
}

function pemToArrayBuffer(pem) {
  const clean = String(pem).replace(/\\n/g, '\n').replace(/-----BEGIN PRIVATE KEY-----/g, '').replace(/-----END PRIVATE KEY-----/g, '').replace(/\s/g, '');
  const binary = atob(clean);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes.buffer;
}

async function createFirebaseCustomToken(env, uid, claims = {}) {
  if (!env.FIREBASE_CLIENT_EMAIL || !env.FIREBASE_PRIVATE_KEY) throw new Error('firebase-server-config-missing');
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: 'RS256', typ: 'JWT' };
  const payload = {
    iss: env.FIREBASE_CLIENT_EMAIL,
    sub: env.FIREBASE_CLIENT_EMAIL,
    aud: 'https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit',
    iat: now,
    exp: now + TOKEN_TTL_SECONDS,
    uid,
    claims,
  };
  const encodedHeader = b64url(encoder.encode(JSON.stringify(header)));
  const encodedPayload = b64url(encoder.encode(JSON.stringify(payload)));
  const unsigned = `${encodedHeader}.${encodedPayload}`;
  const key = await crypto.subtle.importKey(
    'pkcs8',
    pemToArrayBuffer(env.FIREBASE_PRIVATE_KEY),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const signature = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', key, encoder.encode(unsigned));
  return `${unsigned}.${b64url(new Uint8Array(signature))}`;
}

function validateCredentials(password) {
  if (typeof password !== 'string' || password.length < 6 || password.length > 128) throw new Error('invalid-password');
}

async function createSession(env, user) {
  const token = await createFirebaseCustomToken(env, user.uid, {
    admin: user.role === 'admin',
    phone: user.phone,
  });
  return { token, uid: user.uid, name: user.name, role: user.role, phone: user.phone };
}

async function register(env, body) {
  const phone = normalizePhone(body.phone);
  const password = String(body.password ?? '');
  const name = String(body.name ?? '').trim();
  validateCredentials(password);
  if (!name || name.length > 80) throw new Error('name-required');

  const existing = await env.DB.prepare('SELECT uid FROM users WHERE phone = ?1').bind(phone).first();
  if (existing) throw new Error('phone-already-registered');

  const uid = `phone_${phone.slice(1)}`;
  const passwordHash = await encodePassword(password);
  const now = Date.now();
  await env.DB.prepare(
    'INSERT INTO users (phone, uid, name, password_hash, role, failed_attempts, locked_until, created_at) VALUES (?1, ?2, ?3, ?4, ?5, 0, 0, ?6)',
  ).bind(phone, uid, name, passwordHash, 'buyer', now).run();

  return createSession(env, { phone, uid, name, role: 'buyer' });
}

async function login(env, body) {
  const phone = normalizePhone(body.phone);
  const password = String(body.password ?? '');
  validateCredentials(password);

  const user = await env.DB.prepare('SELECT phone, uid, name, password_hash, role, failed_attempts, locked_until FROM users WHERE phone = ?1').bind(phone).first();
  if (!user) throw new Error('invalid-credentials');

  const now = Date.now();
  if (Number(user.locked_until ?? 0) > now) throw new Error('too-many-attempts');

  const ok = await verifyPassword(password, user.password_hash);
  if (!ok) {
    const failed = Number(user.failed_attempts ?? 0) + 1;
    const lockedUntil = failed >= 5 ? now + 15 * 60 * 1000 : 0;
    await env.DB.prepare('UPDATE users SET failed_attempts = ?1, locked_until = ?2 WHERE phone = ?3').bind(lockedUntil ? 0 : failed, lockedUntil, phone).run();
    throw new Error('invalid-credentials');
  }

  await env.DB.prepare('UPDATE users SET failed_attempts = 0, locked_until = 0 WHERE phone = ?1').bind(phone).run();
  return createSession(env, { phone: user.phone, uid: user.uid, name: user.name, role: user.role });
}

async function bootstrapAdmin(env, body) {
  if (!env.ADMIN_BOOTSTRAP_SECRET || body.secret !== env.ADMIN_BOOTSTRAP_SECRET) throw new Error('forbidden');
  const phone = normalizePhone(body.phone);
  const password = String(body.password ?? '');
  const name = String(body.name ?? 'BUKO Admin').trim() || 'BUKO Admin';
  validateCredentials(password);

  const uid = `phone_${phone.slice(1)}`;
  const passwordHash = await encodePassword(password);
  await env.DB.prepare(
    `INSERT INTO users (phone, uid, name, password_hash, role, failed_attempts, locked_until, created_at)
     VALUES (?1, ?2, ?3, ?4, 'admin', 0, 0, ?5)
     ON CONFLICT(phone) DO UPDATE SET uid=excluded.uid, name=excluded.name, password_hash=excluded.password_hash, role='admin', failed_attempts=0, locked_until=0`,
  ).bind(phone, uid, name, passwordHash, Date.now()).run();

  return { ok: true, phone, uid, role: 'admin' };
}

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') return json({ ok: true });
    if (request.method !== 'POST') return json({ error: 'method-not-allowed' }, 405);

    try {
      const url = new URL(request.url);
      const body = await request.json();
      if (url.pathname === '/auth/register') return json(await register(env, body));
      if (url.pathname === '/auth/login') return json(await login(env, body));
      if (url.pathname === '/auth/bootstrap-admin') return json(await bootstrapAdmin(env, body));
      return json({ error: 'not-found' }, 404);
    } catch (error) {
      const code = error instanceof Error ? error.message : 'server-error';
      const status = code === 'forbidden' ? 403 : code === 'phone-already-registered' || code === 'invalid-credentials' || code === 'invalid-phone' || code === 'invalid-password' || code === 'name-required' || code === 'too-many-attempts' ? 400 : 500;
      return json({ error: code }, status);
    }
  },
};
