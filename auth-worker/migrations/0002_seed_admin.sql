INSERT INTO users(phone, uid, name, password_hash, role, failed_attempts, locked_until, created_at)
VALUES (
  '+249909976346',
  'phone_249909976346',
  'BUKO Admin',
  'pbkdf2$60000$XSb_fT49FFIqXL9QWqzwcA$nPQ7Inl3cjc-BIEEToPOmw2sQPaw5ZFl3AdyiNmsnE4',
  'admin',
  0,
  0,
  strftime('%s','now') * 1000
)
ON CONFLICT(phone) DO UPDATE SET
  uid=excluded.uid,
  name=excluded.name,
  password_hash=excluded.password_hash,
  role='admin',
  failed_attempts=0,
  locked_until=0;