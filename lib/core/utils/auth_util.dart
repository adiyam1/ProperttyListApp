// Simple password hashing for local demo. Use proper hashing (e.g. bcrypt) in production.
String hashPassword(String plain) {
  return (plain + 'prop_pal_salt').hashCode.toRadixString(16);
}

bool verifyPassword(String plain, String storedHash) {
  return hashPassword(plain) == storedHash;
}
