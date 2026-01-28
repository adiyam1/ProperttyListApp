
A Flutter property-listing app with **user roles**, **sign up / sign in**, and role-based features.  
Uses local assets (`assets/images/`) for property images.

---

## User roles

| Role  | Description |
|-------|-------------|
| **Admin** | Full access: add/edit/delete properties, view all inquiries, clear cache, edit profile, sign out. |
| **User**  | Browse properties, favorites, send inquiries, edit own profile, clear cache, sign out. |

---

## Sign up & sign in

- **Sign up**: Name, email, password (min 6 characters). New accounts get the **User** role.
- **Sign in**: Email and password. Session is stored via `SharedPreferences`.
- **Sign out**: Profile → “Sign out”. Returns to the auth screen.

**Seeded admin (fresh install):**

- Email: `admin@example.com`  
- Password: `Admin123`  

---

## Functionalities (by role)

### All users

- Browse property list (home).
- View property details (images, specs, description).
- Toggle favorites (heart icon).
- Send inquiries from property detail.
- Favorites tab: list of saved properties.
- Profile: edit name, email, avatar; offline mode, dark mode; clear offline cache; sign out.

### Admin only

- **Add property**: FAB on home → form (title, description, location, price, beds, baths, sqft, image URL).
- **Edit property**: Property detail → edit icon → same form.
- **Delete property**: Property detail → delete icon → confirm.
- **View inquiries**: Profile → “View Inquiries” → list of all inquiries with status (synced, queued, failed).

---

## Assets (material)

Property images use `assets/images/`:

- `villa1.png`, `villa2.png`, `villa3.png`
- `cozy_house1.png`, `cozy_house2.png`

Mock seed maps these to the sample properties (e.g. Luxury Villa, Cozy Cottage, Modern Family Home).  
Add/edit property supports either asset paths (`assets/images/...`) or network URLs.

---

## Getting started

```bash
flutter pub get
flutter run
```

## Tech

- **Flutter** + **Riverpod**
- **SQLite** 