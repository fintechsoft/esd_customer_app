# Push Notifications — backend contract (CodeIgniter 4)

The Flutter app is already wired. This is what the CI4 backend has to provide.

## 1. Device token storage

```sql
CREATE TABLE customer_devices (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id  INT UNSIGNED NOT NULL,
  token        VARCHAR(255) NOT NULL,
  platform     ENUM('ios','android') NOT NULL,
  created_at   DATETIME NOT NULL,
  updated_at   DATETIME NOT NULL,
  UNIQUE KEY uniq_token (token),
  KEY idx_customer (customer_id)
) ENGINE=InnoDB;
```

`token` is unique, not `(customer_id, token)` — the same handset must never stay
attached to a previous customer after someone else logs in on it.

## 2. Endpoints the app calls

Both require the customer bearer token (same auth filter as the rest of
`/api/customer/*`).

### `POST /api/customer/devices/register`

Sent right after OTP login, on every FCM token refresh, and at app start when a
session already exists.

```json
{ "token": "fEw2...long-fcm-token", "platform": "ios" }
```

Upsert on `token`, always overwriting `customer_id`. Respond `{"status": true}`.

### `POST /api/customer/devices/unregister`

Sent on logout and on account deletion, **before** the session is cleared.

```json
{ "token": "fEw2...long-fcm-token" }
```

Delete the row. Respond `{"status": true}`.

> The app never fails a login or logout because of these calls — errors are
> swallowed and logged. But if register is missing, nobody receives anything.

## 3. Sending

The legacy `fcm/send` server-key endpoint was **shut down in June 2024**. Use the
HTTP v1 API, which needs an OAuth2 access token minted from a service account
JSON (Firebase Console → Project Settings → Service Accounts → Generate new
private key). Install `google/auth` via Composer to mint it.

Endpoint:

```
POST https://fcm.googleapis.com/v1/projects/esd-customer-app/messages:send
Authorization: Bearer <oauth2-access-token>
```

### To ONE customer

Look up their tokens and send one request per token.

```json
{
  "message": {
    "token": "<device token>",
    "notification": { "title": "Bill ready", "body": "Your invoice #1043 is available." },
    "data": { "type": "product", "product_id": "42" },
    "android": { "priority": "high", "notification": { "channel_id": "esd_customer_default" } },
    "apns": { "headers": { "apns-priority": "10" } }
  }
}
```

### To ALL customers

Do not loop over every token. Have the app subscribe to a topic and send once.
Add this to `PushNotificationService.init()` when you're ready:

```dart
await _messaging.subscribeToTopic('all_customers');
```

Then swap `"token"` for `"topic": "all_customers"` in the payload above.

### WITH an image

Add the image URL in the platform blocks. It must be **HTTPS** and under ~1 MB.

```json
{
  "message": {
    "token": "<device token>",
    "notification": { "title": "Diwali Offer", "body": "Up to 40% off on washing machines." },
    "data": { "type": "product", "product_id": "42", "image": "https://esdmanagement.in/uploads/offer.jpg" },
    "android": {
      "priority": "high",
      "notification": {
        "channel_id": "esd_customer_default",
        "image": "https://esdmanagement.in/uploads/offer.jpg"
      }
    },
    "apns": {
      "headers": { "apns-priority": "10", "apns-push-type": "alert" },
      "payload": { "aps": { "mutable-content": 1 } },
      "fcm_options": { "image": "https://esdmanagement.in/uploads/offer.jpg" }
    }
  }
}
```

The `data.image` duplicate is deliberate: it is what the app reads when it draws
the notification itself in the foreground.

## 4. Where images actually appear

| | Android | iOS |
|---|---|---|
| App in foreground | ✅ big picture | ❌ title/body only |
| App backgrounded / closed | ✅ big picture | ❌ title/body only |

iOS shows images only through a **Notification Service Extension**, which this
build deliberately does not ship. Text notifications work on iOS today; adding
the extension is a separate Xcode target for a later release. Send the image
fields anyway — iOS ignores them harmlessly.

## 5. Payload keys the app understands

| Key | Effect |
|---|---|
| `product_id` | Tapping opens that product's detail screen |
| `image` / `image_url` | Used for the Android foreground big-picture style |

Anything else is passed through and ignored. Always include a `notification`
block — a data-only message shows no tray notification while the app is closed.
