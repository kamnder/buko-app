const { onRequest } = require('firebase-functions/v2/https');
const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const bcrypt = require('bcryptjs');

initializeApp();
const db = getFirestore();

function normalizePhone(value) {
  let p = String(value || '').trim().replace(/[^0-9+]/g, '');
  if (p.startsWith('00249')) p = '+' + p.substring(2);
  if (p.startsWith('249')) p = '+' + p;
  if (p.startsWith('0') && p.length === 10) p = '+249' + p.substring(1);
  return p;
}

function validPhone(p) {
  return /^\+249\d{9}$/.test(p);
}

function userDocId(phone) {
  return phone.replace('+', '');
}

exports.phonePasswordAuth = onRequest(
  { region: 'us-central1', cors: true, maxInstances: 10 },
  async (req, res) => {
    if (req.method !== 'POST') return res.status(405).json({ error: 'method-not-allowed' });

    try {
      const { action, phone, password, name } = req.body || {};
      const normalized = normalizePhone(phone);
      if (!validPhone(normalized)) return res.status(400).json({ error: 'invalid-phone' });
      if (typeof password !== 'string' || password.length < 6 || password.length > 128) {
        return res.status(400).json({ error: 'invalid-password' });
      }

      const ref = db.collection('phoneAccounts').doc(userDocId(normalized));
      const snap = await ref.get();

      if (action === 'register') {
        if (snap.exists) return res.status(409).json({ error: 'phone-already-registered' });
        if (typeof name !== 'string' || !name.trim()) return res.status(400).json({ error: 'name-required' });

        const uid = `phone_${userDocId(normalized)}`;
        const passwordHash = await bcrypt.hash(password, 12);
        await getAuth().createUser({ uid, displayName: name.trim() });
        await ref.set({
          uid,
          phone: normalized,
          name: name.trim(),
          passwordHash,
          createdAt: FieldValue.serverTimestamp(),
        });
        await db.collection('users').doc(uid).set({
          name: name.trim(),
          phone: normalized,
          role: 'buyer',
          createdAt: FieldValue.serverTimestamp(),
        }, { merge: true });
        const token = await getAuth().createCustomToken(uid, { role: 'buyer' });
        return res.json({ token });
      }

      if (action === 'login') {
        if (!snap.exists) return res.status(401).json({ error: 'invalid-credentials' });
        const account = snap.data();
        const ok = await bcrypt.compare(password, account.passwordHash);
        if (!ok) return res.status(401).json({ error: 'invalid-credentials' });
        const token = await getAuth().createCustomToken(account.uid, { role: 'buyer' });
        return res.json({ token });
      }

      return res.status(400).json({ error: 'invalid-action' });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ error: 'server-error' });
    }
  }
);
